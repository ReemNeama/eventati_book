class MenuItem {
  final String name;
  final String description;
  final String category;
  final double? price;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.description,
    required this.category,
    this.price,
    this.imageUrl = '',
  });
}
