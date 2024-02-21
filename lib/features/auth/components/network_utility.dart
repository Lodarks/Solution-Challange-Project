import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final networkUtilityProvider = Provider<NetworkUtility>((ref) {
  return NetworkUtility();
});

class NetworkUtility {
  final String apiKey = 'AIzaSyCcftG9VCDPNpoDz4tJrNL_VATkfUO4074';

  Future<List<dynamic>> fetchPredictions(String input) async {
    const sessionToken = "";

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$sessionToken&types=establishment&components=country:tr'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['predictions'];
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<Map<String, dynamic>> getPlace(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;
    return results;
  }
}
