class RestaurantModel {
  final String restaurantAddress;
  final String restaurantMail;
  final String restaurantId;
  final double latitude;
  final double longitude;
  final String restaurantName;
  RestaurantModel({
    required this.restaurantAddress,
    required this.restaurantMail,
    required this.restaurantId,
    required this.latitude,
    required this.longitude,
    required this.restaurantName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'restaurantAddress': restaurantAddress,
      'restaurantMail': restaurantMail,
      'restaurantId': restaurantId,
      'latitude': latitude,
      'longitude': longitude,
      'restaurantName': restaurantName,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      restaurantAddress: map['restaurantAddress'] as String,
      restaurantMail: map['restaurantMail'] as String,
      restaurantId: map['restaurantId'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      restaurantName: map['restaurantName'] as String,
    );
  }
}
