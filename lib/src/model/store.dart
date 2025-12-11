class StoreItem {
  final String id;
  final String title, subtitle;
  final String description;
  final String image;
  final int price;
  final String currency;
  StoreItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.price,
    required this.currency,
  });

  static StoreItem fromMap(Map<String, dynamic> data) {
    
    return StoreItem(
      id: data['id'] as String,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String,
      description: data['description'] as String,
      image: data['image'] as String,
      price: data['price'] as int,
      currency: data['currency'] as String,
    );
  }
}

class CartItem {
  String? id;
  final StoreItem itemId;
  final String sellerId, buyerId;
  final DateTime addedAt;
  final int statusCode; // 0: added to cart, 1: payment made, 2: item delivered, 4: cancelled
  CartItem({
    this.id,
    required this.itemId,
    required this.sellerId,
    required this.buyerId,
    required this.addedAt,
    required this.statusCode,
  });

  //Define keys
  static String collectionName = "cartItems";
  static String itemIdKey = "itemId", sellerIdKey = "sellerId", buyerIdKey = "buyerId",
  addedAtKey = "addedAt", statusCodeKey = "statusCode";

  static CartItem fromDocSnapshot(String id, Map<String, dynamic>? data) {
    if(data == null) throw Exception("No data found for CartItem with id $id");

    return CartItem(
      id: id,
      itemId: data[itemIdKey],
      sellerId: data[sellerIdKey],
      buyerId: data[buyerIdKey],
      addedAt: DateTime.parse(data[addedAtKey]),
      statusCode: data[statusCodeKey] ?? 0,
    );
  }

  Map<String, dynamic> creationObj() {
    return {
      itemIdKey: itemId.id,
      sellerIdKey: sellerId,
      buyerIdKey: buyerId,
      addedAtKey: addedAt.toString(),
      statusCodeKey: statusCode,
    };
  }

  Map<String, dynamic> updateObj() {
    return {
      statusCodeKey: statusCode,
    };
  }

}