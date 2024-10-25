class Event {
  String id, title, description, by;
  DateTime time;
  String pic;
  bool donation;
  double price;
  Event({required this.id, required this.title, required this.description, required this.by, required this.time, this.pic = "assets/event_placeholder.jpeg", this.donation = false, this.price = 10});

  static dummy(DateTime when) => Event(
    id: "12345esefs", 
    title: "Event at FlashZone", 
    description: "This is a placeholder event to how the event will look in real. Users will be able to add any kind of description here including clickable links", 
    by: "Placeholder John Doe",
    time: when);
}