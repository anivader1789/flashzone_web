

enum PurchasedItemType {
  session,
  product,
  course,
}

class PurchasedItem {
  String? id;
  late PurchasedItemType type;
  int itemTypeIndex;
  String title;
  String description;
  String? pic;
  String buyerUserId;
  String? sellerUserId, sellerFamId;
  double price;
  String currency;
  int quantity;

  String? appointmentId;
  String? itemId;
  bool isPaid;
  PurchasedItem({
    this.id,
    required this.itemTypeIndex,
    required this.title,
    required this.description,
    required this.price,
    required this.buyerUserId,
    this.sellerUserId,
    this.sellerFamId,
    this.pic,
    this.currency = "USD",
    this.quantity = 1,
    this.isPaid = false,
    this.appointmentId,
    this.itemId,
  }) {
    switch (itemTypeIndex) {
      case 0:
        type = PurchasedItemType.session;
        break;
      case 1:
        type = PurchasedItemType.product;
        break;
      case 2:
        type = PurchasedItemType.course;
        break;
      default:
        throw Exception("Invalid itemTypeIndex: $itemTypeIndex");
    }
  }

  double get totalPrice => price * quantity;

  static const String collectionName = "checkout_items",
      fieldId = "id",
      fieldItemTypeIndex = "itemTypeIndex",
      fieldTitle = "title",
      fieldDescription = "description",
      fieldPrice = "price",
      fieldAppointmentId = "appointmentId",
      fieldItemId = "itemId",
      fieldBuyerUserId = "buyerUserId",
      fieldSellerUserId = "sellerUserId",
      fieldSellerFamId = "sellerFamId",
      fieldPic = "pic",
      fieldQuantity = "quantity",
      fieldIsPaid = "isPaid";

  Map<String, dynamic> toMap() {
    return {
      fieldItemTypeIndex: itemTypeIndex,
      fieldTitle: title,
      fieldDescription: description,
      fieldPrice: price,
      fieldQuantity: quantity,
      fieldIsPaid: isPaid,
      if (appointmentId != null) fieldAppointmentId: appointmentId,
      if (itemId != null) fieldItemId: itemId,
      fieldBuyerUserId: buyerUserId,
      if (sellerUserId != null) fieldSellerUserId: sellerUserId,
      if (sellerFamId != null) fieldSellerFamId: sellerFamId,
      if (pic != null) fieldPic: pic,
    };
  
  }

  factory PurchasedItem.fromMap(Map<String, dynamic> map, String documentId) {
    return PurchasedItem(
      id: documentId,
      itemTypeIndex: map[fieldItemTypeIndex],
      title: map[fieldTitle],
      description: map[fieldDescription],
      price: map[fieldPrice],
      quantity: map[fieldQuantity],
      isPaid: map[fieldIsPaid],
      appointmentId: map[fieldAppointmentId],
      itemId: map[fieldItemId],
      pic: map[fieldPic],
      buyerUserId: map[fieldBuyerUserId],
      sellerUserId: map[fieldSellerUserId],
      sellerFamId: map[fieldSellerFamId],
    );
  }



}