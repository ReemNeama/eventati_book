class VenuePackage {
  final String name;
  final String description;
  final double price;
  final int maxCapacity;
  final List<String> includedServices;
  final List<String> additionalFeatures;
  final String imageUrl;

  VenuePackage({
    required this.name,
    required this.description,
    required this.price,
    required this.maxCapacity,
    required this.includedServices,
    required this.additionalFeatures,
    this.imageUrl = '',
  });
}
