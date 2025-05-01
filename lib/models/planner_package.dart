class PlannerPackage {
  final String name;
  final String description;
  final double price;
  final List<String> includedServices;
  final List<String> additionalFeatures;
  final String imageUrl;

  PlannerPackage({
    required this.name,
    required this.description,
    required this.price,
    required this.includedServices,
    required this.additionalFeatures,
    this.imageUrl = '',
  });
}
