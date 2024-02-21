import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  final String apiKey =
      'AIzaSyCcftG9VCDPNpoDz4tJrNL_VATkfUO4074'; // Google Places API anahtarınızı buraya ekleyin

  Future<List<Map<String, dynamic>>> fetchSuggestions(String input) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['predictions']);
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}
