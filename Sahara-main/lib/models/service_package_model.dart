class ServicePackageModel {
  final String id;
  final String serviceType; // Dog Walking, Pet Sitting, Grooming, etc.
  final String packageName; // Basic, Standard, Premium
  final String description;
  final double price;
  final String duration; // e.g., "1 hour", "2 hours", "Full day"
  final List<String> features;
  final bool isPopular;
  final String? discount; // e.g., "10% off"

  ServicePackageModel({
    required this.id,
    required this.serviceType,
    required this.packageName,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceType': serviceType,
      'packageName': packageName,
      'description': description,
      'price': price,
      'duration': duration,
      'features': features,
      'isPopular': isPopular,
      'discount': discount,
    };
  }

  factory ServicePackageModel.fromMap(Map<String, dynamic> map, String id) {
    return ServicePackageModel(
      id: id,
      serviceType: map['serviceType'] ?? '',
      packageName: map['packageName'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      duration: map['duration'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      isPopular: map['isPopular'] ?? false,
      discount: map['discount'],
    );
  }
}

