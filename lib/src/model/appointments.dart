class Appointment {
  String? id;
  String providerId;
  String providerPictureUrl;
  String providerName;
  double price;
  int duration;
  String consumerId;
  DateTime startTime;
  DateTime endTime;
  String title, description;
  String meetingLink;
  DateTime createdAt;
  Appointment({
    this.id,
    required this.providerId,
    required this.providerPictureUrl,
    required this.providerName,
    required this.duration,
    required this.price,
    required this.consumerId,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    required this.meetingLink,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static const String collectionName = "appointments",
      fieldId = "id",
      fieldProviderId = "providerId",
      fieldProviderPictureUrl = "providerPictureUrl",
      fieldProviderNme = "providerName",
      fieldDuration = "duration",
      fieldPrice = "price",
      fieldConsumerId = "consumerId",
      fieldStartTime = "startTime",
      fieldEndTime = "endTime",
      fieldTitle = "title",
      fieldDescription = "description",
      fieldMeetingLink = "meetingLink",
      fieldCreatedAt = "createdAt";

  Map<String, dynamic> toMap() {
    return {
      fieldProviderId: providerId,
      fieldConsumerId: consumerId,
      fieldStartTime: startTime.toIso8601String(),
      fieldEndTime: endTime.toIso8601String(),
      fieldTitle: title,
      fieldDescription: description,
      fieldMeetingLink: meetingLink,
      fieldProviderPictureUrl: providerPictureUrl,
      fieldProviderNme: providerName,
      fieldDuration: duration,
      fieldPrice: price,
      fieldCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String documentId) {
    return Appointment(
      id: documentId,
      providerId: map[fieldProviderId],
      providerPictureUrl: map[fieldProviderPictureUrl],
      providerName: map[fieldProviderNme],
      duration: map[fieldDuration],
      price: map[fieldPrice],
      consumerId: map[fieldConsumerId],
      startTime: DateTime.parse(map[fieldStartTime]),
      endTime: DateTime.parse(map[fieldEndTime]),
      title: map[fieldTitle],
      description: map[fieldDescription],
      meetingLink: map[fieldMeetingLink],
      createdAt: DateTime.parse(map[fieldCreatedAt]),
    );
  }

  

}