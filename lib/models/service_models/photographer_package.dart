class PhotographerPackage {
  final String name;
  final String description;
  final double price;
  final List<String> includedServices;
  final List<String> additionalFeatures;
  final bool includesPhotography;
  final bool includesVideography;
  final bool includesTeam;

  PhotographerPackage({
    required this.name,
    required this.description,
    required this.price,
    required this.includedServices,
    required this.additionalFeatures,
    required this.includesPhotography,
    required this.includesVideography,
    required this.includesTeam,
  });
}
