import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:layout/ad_helper.dart';
import 'package:layout/api_service.dart';
import 'package:layout/detail_page.dart';
import 'package:layout/drink_data.dart';
import 'package:logger/logger.dart';

var testIds = ['7654D8B0C3F826F4DA1D51262310835A'];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: testIds);
  MobileAds.instance.updateRequestConfiguration(configuration);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppTitle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const int maxFailedLoadAttempts = 3;

class _MyHomePageState extends State<MyHomePage> {
  List drinkList = [];
  var apiService = ApiService();
  var log = Logger();

  int _interstitialLoadAttempts = 0;

  final _inlineAdIndex = 3;

  late BannerAd _bottomBannerAd;
  late BannerAd _inLineBannerAd;
  InterstitialAd? _interstitialAd;

  bool _isBottomBannerAdLoaded = false;
  bool _isInlineBannerAdLoaded = false;

  int _getListViewItemIndex(int index) {
    if (index >= _inlineAdIndex && _isInlineBannerAdLoaded) {
      return index - 1;
    }
    return index;
  }

  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(onAdLoaded: (_) {
        setState(() {
          _isBottomBannerAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
      }),
      request: const AdRequest(),
    );
    _bottomBannerAd.load();
  }

  void _createInlineBannerAd() {
    _inLineBannerAd = BannerAd(
        size: AdSize.mediumRectangle,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isInlineBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }),
        request: const AdRequest());
    _inLineBannerAd.load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _interstitialLoadAttempts += 1;
          if(_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            _createInterstitialAd();
          }

        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  void initState() {
    super.initState();
    _createBottomBannerAd();
    _createInterstitialAd();
    // _createInlineBannerAd();// - Creatings index error when refreshing add
  }

  @override
  void dispose() {
    super.dispose();
    _bottomBannerAd.dispose();
    _inLineBannerAd.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _isBottomBannerAdLoaded
          ? Container(
              height: _bottomBannerAd.size.height.toDouble(),
              width: _bottomBannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bottomBannerAd),
            )
          : null,
      appBar: AppBar(
        title: const Text('Drink Ad'),
      ),
      body: FutureBuilder(
          future: ApiService().getDrinks(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              drinkList.clear();
              drinkList = snapshot.data['drinks'];

              return ListView.builder(
                  itemCount:
                      drinkList.length + (_isInlineBannerAdLoaded ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isInlineBannerAdLoaded && index == _inlineAdIndex) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 10),
                        width: _inLineBannerAd.size.width.toDouble(),
                        height: _inLineBannerAd.size.height.toDouble(),
                        child: AdWidget(
                          ad: _inLineBannerAd,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            var selectedDrinkData = DrinkData(
                                name: drinkList[_getListViewItemIndex(index)]
                                    ['strDrink'],
                                imageUrl:
                                    drinkList[_getListViewItemIndex(index)]
                                        ['strDrinkThumb']);
                            //log.i('TAPPED: ${drinkList[index]['strDrinkThumb']}');

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                        drinkData: selectedDrinkData)));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: Colors.green,
                            elevation: 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        '${drinkList[_getListViewItemIndex(index)]['strDrinkThumb']}',
                                    height: 350,
                                    width: 340,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    drinkList[_getListViewItemIndex(index)]
                                        ['strDrink'],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  });
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
