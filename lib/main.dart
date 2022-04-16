import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:layout/ad_helper.dart';
import 'package:layout/api_service.dart';
import 'package:layout/detail_page.dart';
import 'package:layout/drink_data.dart';
import 'package:logger/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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

class _MyHomePageState extends State<MyHomePage> {
  List drinkList = [];
  var apiService = ApiService();
  var log = Logger();

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

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
      request: AdRequest(),
    );
    _bottomBannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    _createBottomBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomBannerAd.dispose();
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
                  itemCount: drinkList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 6.0),
                      child: GestureDetector(
                        onTap: () {
                          var selectedDrinkData = DrinkData(
                              name: drinkList[index]['strDrink'],
                              imageUrl: drinkList[index]['strDrinkThumb']);
                          log.i('TAPPED: ${drinkList[index]['strDrinkThumb']}');

                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DetailPage(drinkData: selectedDrinkData)));
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
                                      '${drinkList[index]['strDrinkThumb']}',
                                  height: 350,
                                  width: 340,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  drinkList[index]['strDrink'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
