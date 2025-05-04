class CateringService {
  final String name;
  final String description;
  final double rating;
  final List<String> cuisineTypes;
  final int minCapacity;
  final int maxCapacity;
  final double pricePerPerson;
  final String imageUrl;

  CateringService({
    required this.name,
    required this.description,
    required this.rating,
    required this.cuisineTypes,
    required this.minCapacity,
    required this.maxCapacity,
    required this.pricePerPerson,
    required this.imageUrl,
  });
}
