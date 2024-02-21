class FoodPostModel {
  final String foodName;
  final String imageUrl;
  final String restaurantId;
  final String restaurantName;
  final String adress;
  final int createdAt;
  FoodPostModel({
    required this.foodName,
    required this.imageUrl,
    required this.restaurantId,
    required this.restaurantName,
    required this.adress,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'foodName': foodName,
      'imageUrl': imageUrl,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'adress': adress,
      'createdAt': createdAt,
    };
  }

  factory FoodPostModel.fromMap(Map<String, dynamic> map) {
    return FoodPostModel(
      foodName: map['foodName'] as String,
      imageUrl: map['imageUrl'] as String,
      restaurantId: map['restaurantId'] as String,
      restaurantName: map['restaurantName'] as String,
      adress: map['adress'] as String,
      createdAt: map['createdAt'] as int,
    );
  }
}
