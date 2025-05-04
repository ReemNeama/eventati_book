class Photographer {
  final String name;
  final String description;
  final double rating;
  final List<String> styles;
  final double pricePerEvent;
  final String imageUrl;
  final List<String> equipment;
  final List<String> packages;

  Photographer({
    required this.name,
    required this.description,
    required this.rating,
    required this.styles,
    required this.pricePerEvent,
    required this.imageUrl,
    required this.equipment,
    required this.packages,
  });
}
