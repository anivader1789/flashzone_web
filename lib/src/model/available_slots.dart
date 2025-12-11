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
      fieldProviderUserId = "providerUserId",
      fieldProviderFamId = "providerFamId",
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
          (slotList) => List<int>.from(slotList as List<dynamic>),
        ),
      ),
    );
  }
}