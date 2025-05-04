class Planner {
  final String name;
  final String description;
  final double rating;
  final List<String> specialties;
  final int yearsExperience;
  final double pricePerEvent;
  final String imageUrl;
  final List<String> services;

  Planner({
    required this.name,
    required this.description,
    required this.rating,
    required this.specialties,
    required this.yearsExperience,
    required this.pricePerEvent,
    required this.imageUrl,
    required this.services,
  });
}
