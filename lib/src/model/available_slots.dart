class AvailableSlots {
  String? id;
  String providerUserId;
  String providerFamId;
  List<List<int>> slots; // List of slots per week
  AvailableSlots({
    this.id,
    required this.providerUserId,
    required this.providerFamId,
    required this.slots,
  });

  static const String collectionName = "available_slots",
      fieldId = "id",
      fieldProviderUserId = "providerUserId", // fOwEnnFnuRRpQH5DnjMbIh8tWh13
      fieldProviderFamId = "providerFamId", // IZRDrxOR4C7eOK8yJunW
      fieldSlots = "slots";

  Map<String, dynamic> toMap() {
    return {
      fieldProviderUserId: providerUserId,
      fieldProviderFamId: providerFamId,
      fieldSlots: slots,
    };
  }

  factory AvailableSlots.fromMap(Map<String, dynamic> map, String documentId) {
    return AvailableSlots(
      id: documentId,
      providerUserId: map[fieldProviderUserId],
      providerFamId: map[fieldProviderFamId],
      slots: List<List<int>>.from(
        (map[fieldSlots] as List<dynamic>).map(
          (slotList) {
            final slotStr = slotList.toString();
            return slotStr.trim().split(",").map((slot) => int.parse(slot)).toList();
          }
          // List<int>.from(slotList as List<dynamic>),
        ),
      ),
    );
  }
}