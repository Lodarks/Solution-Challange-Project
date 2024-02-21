import 'dart:async';
import 'package:food_share/features/auth/components/network_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_share/features/auth/repository/auth_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantAuth extends ConsumerStatefulWidget {
  static const String routeName = '/restaurant-auth';
  const RestaurantAuth({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantAuth> createState() => _RestaurantAuthState();
}

class _RestaurantAuthState extends ConsumerState<RestaurantAuth> {
  TextEditingController searchBusiness = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  bool _showPredictions = true;
  List<String> _predictions = [];
  List<String> _address = [];
  List<String> _placeId = [];

  Set<Marker> _markers = Set<Marker>();
  String restaurantAdress = '';
  String restaurantId = '';
  String restaurantName = '';
  double latitude = 0;
  double longitude = 0;

  void setMarker(LatLng point, [String? address]) {
    _markers.add(
      Marker(
          markerId: const MarkerId('marker'),
          position: point,
          infoWindow: InfoWindow(title: address),
          visible: true),
    );
    _predictions.clear();
    searchBusiness.clear();
  }

  void searchPlace(String input) async {
    final predictions =
        await ref.read(networkUtilityProvider).fetchPredictions(input);
    _predictions = predictions
        .map<String>((dynamic json) => json['description'].toString())
        .toList();
    _address = predictions
        .map<String>((dynamic json) =>
            json['structured_formatting']['main_text'].toString())
        .toList();
    _placeId = predictions
        .map<String>((dynamic json) => json['place_id'].toString())
        .toList();
  }

  Future goToPlace(Map<String, dynamic> place, String adress) async {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
    setMarker(LatLng(lat, lng), adress);
    latitude = lat;
    longitude = lng;
  }

  // void placeAutoComplete(String query) async {
  //   Uri uri =
  //       Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
  //     'input': query,
  //     'key': apiKey,
  //   });

  //   String? response = await NetworkUtility().fetchUrl(uri);

  //   if (response != null) {
  //     print(response);
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    searchBusiness.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 14.4746,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: height * 0.08),
                    child: Container(
                      width: width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        controller: searchBusiness,
                        onChanged: (value) {
                          setState(() {
                            _showPredictions = true;
                          });
                          searchPlace(value);
                        },
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Select your business',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            )),
                      ),
                    ),
                  ),
                ),
                if (_showPredictions && _predictions.isNotEmpty)
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: height * 0.8,
                      width: width * 0.9,
                      child: ListView.builder(
                        itemCount: _predictions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  onTap: () async {
                                    setState(() {
                                      restaurantAdress = _predictions[index];
                                      restaurantId = _placeId[index];
                                      restaurantName = _address[index];
                                    });
                                    var place = await ref
                                        .read(networkUtilityProvider)
                                        .getPlace(_placeId[index]);
                                    goToPlace(place, _address[index]);
                                    _showPredictions = false;
                                  },
                                  title: Text(_address[index]),
                                  subtitle: Text(_predictions[index]),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.05),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      minimumSize: const Size(200, 50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_markers.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select your business'),
                          ),
                        );
                      } else {
                        ref
                            .read(authRepositoryProvider)
                            .saveRestaurantDataToFirebase(
                              context,
                              restaurantAdress,
                              restaurantId,
                              restaurantName,
                              latitude,
                              longitude,
                            );
                      }
                    },
                    child: const Text('Continue'))),
          )
        ],
      ),
    );
  }
}
