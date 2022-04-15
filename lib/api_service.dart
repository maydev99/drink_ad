import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class ApiService {
  var log = Logger();

  Future getDrinks() async {
    final myUrl =
        Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Gin');
    final response = await http.get(myUrl);
    //log.i(response.statusCode);
   // log.i(response.body);
    return json.decode(response.body);
  }
}
