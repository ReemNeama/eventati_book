class CateringPackage {
  final String name;
  final String description;
  final double price;
  final List<String> includedItems;
  final List<String> additionalServices;
  final String imageUrl;

  CateringPackage({
    required this.name,
    required this.description,
    required this.price,
    required this.includedItems,
    required this.additionalServices,
    this.imageUrl = '',
  });
}
