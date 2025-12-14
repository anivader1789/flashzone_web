
import 'package:flashzone_web/src/model/appointments.dart';

enum CheckoutItemType {
  session,
  product,
  course,
}

class CheckoutItem {
  String? id;
  late CheckoutItemType type;
  int itemTypeIndex;
  String title;
  String description;
  double price;
  String currency;
  int quantity;

  Appointment? appointment;
  bool isPaid;
  CheckoutItem({
    this.id,
    required this.itemTypeIndex,
    required this.title,
    required this.description,
    required this.price,
    this.currency = "USD",
    this.quantity = 1,
    this.isPaid = false,
    this.appointment,
  }) {
    switch (itemTypeIndex) {
      case 0:
        type = CheckoutItemType.session;
        break;
      case 1:
        type = CheckoutItemType.product;
        break;
      case 2:
        type = CheckoutItemType.course;
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
    };
  
  }

  factory CheckoutItem.fromMap(Map<String, dynamic> map, String documentId) {
    return CheckoutItem(
      id: documentId,
      itemTypeIndex: map[fieldItemTypeIndex],
      title: map[fieldTitle],
      description: map[fieldDescription],
      price: map[fieldPrice],
      quantity: map[fieldQuantity],
      isPaid: map[fieldIsPaid],
    );
  }



}