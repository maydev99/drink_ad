import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:layout/drink_data.dart';

class DetailPage extends StatefulWidget {
  final DrinkData drinkData;

  const DetailPage({Key? key, required this.drinkData}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  //Variables and functions

  @override
  Widget build(BuildContext context) {
    var data = widget.drinkData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Drink'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CachedNetworkImage(imageUrl: data.imageUrl),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 32.0),
            child: Text(data.name,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}
