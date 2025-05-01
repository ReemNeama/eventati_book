class Venue {
  final String name;
  final String description;
  final double rating;
  final List<String> venueTypes;
  final int minCapacity;
  final int maxCapacity;
  final double pricePerEvent;
  final String imageUrl;
  final List<String> features;

  Venue({
    required this.name,
    required this.description,
    required this.rating,
    required this.venueTypes,
    required this.minCapacity,
    required this.maxCapacity,
    required this.pricePerEvent,
    required this.imageUrl,
    required this.features,
  });
}