class Course {
  final String id;
  final String title;
  final String description;
  final String? longDescription;
  final String image;
  final double price;
  final String currency;
  final String cta;
  final int durationDays;
  final int enrolledCount;
  final double? rating;
  final String? instructor;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.currency,
    required this.cta,
    required this.durationDays,
    this.longDescription,
    this.enrolledCount = 0,
    this.rating,
    this.instructor,
  });

  static Course fromMap(Map<String, dynamic> data) {
    return Course(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      longDescription: data['long_description'] as String?,
      image: data['image'] as String,
      price: (data['price'] as num).toDouble(),
      currency: data['currency'] as String,
      cta: data['cta'] as String? ?? 'Enroll Now',
      durationDays: data['duration_days'] as int? ?? 30,
      enrolledCount: data['enrolled_count'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble(),
      instructor: data['instructor'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'long_description': longDescription,
      'image': image,
      'price': price,
      'currency': currency,
      'cta': cta,
      'duration_days': durationDays,
      'enrolled_count': enrolledCount,
      'rating': rating,
      'instructor': instructor,
    };
  }
}
