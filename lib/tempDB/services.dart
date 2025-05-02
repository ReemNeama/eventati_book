/// Temporary database for service data
class ServiceDB {
  /// Get all catering services
  static List<Map<String, dynamic>> getCateringServices() {
    return [
      {
        'id': '1',
        'name': 'Gourmet Delights Catering',
        'description':
            'Premium catering service specializing in gourmet cuisine.',
        'priceRange': '\$\$\$',
        'rating': 4.8,
        'features': [
          'Custom Menus',
          'Dietary Accommodations',
          'Staff Included',
          'Bar Service',
        ],
        'imageUrls': [],
        'contactEmail': 'info@gourmetdelights.com',
        'contactPhone': '555-123-4567',
        'packages': [
          {
            'id': '1',
            'name': 'Bronze Package',
            'description':
                'Basic catering package with appetizers and main course.',
            'price': 45.0, // per person
            'items': [
              '3 appetizer options',
              '2 main course options',
              '1 dessert option',
              'Non-alcoholic beverages',
            ],
          },
          {
            'id': '2',
            'name': 'Silver Package',
            'description': 'Mid-tier catering package with more options.',
            'price': 65.0, // per person
            'items': [
              '5 appetizer options',
              '3 main course options',
              '2 dessert options',
              'Non-alcoholic beverages',
              'Basic bar service (beer and wine)',
            ],
          },
          {
            'id': '3',
            'name': 'Gold Package',
            'description': 'Premium catering package with full service.',
            'price': 85.0, // per person
            'items': [
              '7 appetizer options',
              '4 main course options',
              '3 dessert options',
              'Non-alcoholic beverages',
              'Full bar service',
              'Coffee and tea station',
              'Late night snack',
            ],
          },
        ],
        'menu': {
          'appetizers': [
            'Bruschetta',
            'Stuffed Mushrooms',
            'Shrimp Cocktail',
            'Mini Quiches',
            'Chicken Satay',
            'Vegetable Spring Rolls',
            'Smoked Salmon Canapés',
          ],
          'mainCourses': [
            'Grilled Salmon with Dill Sauce',
            'Beef Tenderloin with Red Wine Reduction',
            'Chicken Marsala',
            'Vegetable Lasagna',
            'Eggplant Parmesan',
            'Roasted Pork Loin with Apple Chutney',
          ],
          'desserts': [
            'Chocolate Mousse',
            'Tiramisu',
            'Cheesecake',
            'Fruit Tart',
            'Crème Brûlée',
          ],
        },
      },
      {
        'id': '2',
        'name': 'Taste of Elegance',
        'description':
            'Upscale catering service for elegant events and weddings.',
        'priceRange': '\$\$\$\$',
        'rating': 4.9,
        'features': [
          'Custom Menus',
          'Dietary Accommodations',
          'Staff Included',
          'Bar Service',
          'Cake Service',
        ],
        'imageUrls': [],
        'contactEmail': 'events@tasteofelegance.com',
        'contactPhone': '555-234-5678',
        'packages': [
          {
            'id': '1',
            'name': 'Classic Package',
            'description': 'Elegant catering package for sophisticated events.',
            'price': 75.0, // per person
            'items': [
              '4 appetizer options',
              '3 main course options',
              '2 dessert options',
              'Non-alcoholic beverages',
              'Basic bar service',
            ],
          },
          {
            'id': '2',
            'name': 'Premium Package',
            'description':
                'Comprehensive catering package with premium options.',
            'price': 95.0, // per person
            'items': [
              '6 appetizer options',
              '4 main course options',
              '3 dessert options',
              'Non-alcoholic beverages',
              'Full bar service',
              'Coffee and tea station',
            ],
          },
          {
            'id': '3',
            'name': 'Luxury Package',
            'description': 'All-inclusive luxury catering experience.',
            'price': 125.0, // per person
            'items': [
              '8 appetizer options',
              '5 main course options',
              '4 dessert options',
              'Non-alcoholic beverages',
              'Premium bar service',
              'Coffee and tea station',
              'Late night snack',
              'Custom cake',
            ],
          },
        ],
        'menu': {
          'appetizers': [
            'Tuna Tartare',
            'Beef Carpaccio',
            'Goat Cheese Crostini',
            'Lobster Bisque Shooters',
            'Prosciutto-Wrapped Asparagus',
            'Mini Crab Cakes',
            'Truffle Arancini',
            'Oysters on the Half Shell',
          ],
          'mainCourses': [
            'Filet Mignon with Truffle Butter',
            'Herb-Crusted Rack of Lamb',
            'Pan-Seared Sea Bass',
            'Duck Breast with Cherry Sauce',
            'Lobster Tail with Drawn Butter',
            'Wild Mushroom Risotto',
          ],
          'desserts': [
            'Chocolate Soufflé',
            'Vanilla Bean Panna Cotta',
            'Lemon Tart',
            'Opera Cake',
            'Assorted French Macarons',
            'Crème Brûlée',
          ],
        },
      },
      {
        'id': '3',
        'name': 'Fresh & Flavorful Catering',
        'description':
            'Farm-to-table catering service using locally sourced ingredients.',
        'priceRange': '\$\$',
        'rating': 4.7,
        'features': [
          'Local Ingredients',
          'Seasonal Menus',
          'Eco-Friendly',
          'Dietary Accommodations',
        ],
        'imageUrls': [],
        'contactEmail': 'info@freshandflavorful.com',
        'contactPhone': '555-345-6789',
        'packages': [
          {
            'id': '1',
            'name': 'Seasonal Package',
            'description': 'Seasonal menu using locally sourced ingredients.',
            'price': 55.0, // per person
            'items': [
              '3 seasonal appetizer options',
              '2 seasonal main course options',
              '1 seasonal dessert option',
              'Infused water and lemonade',
            ],
          },
          {
            'id': '2',
            'name': 'Farm-to-Table Package',
            'description': 'Comprehensive farm-to-table dining experience.',
            'price': 75.0, // per person
            'items': [
              '5 seasonal appetizer options',
              '3 seasonal main course options',
              '2 seasonal dessert options',
              'Organic beverages',
              'Local wine and beer options',
            ],
          },
        ],
        'menu': {
          'appetizers': [
            'Seasonal Vegetable Crudité',
            'Local Cheese Board',
            'Heirloom Tomato Bruschetta',
            'Roasted Beet Salad',
            'Stuffed Squash Blossoms',
            'Deviled Farm Eggs',
          ],
          'mainCourses': [
            'Grass-Fed Beef Tenderloin',
            'Free-Range Chicken with Herbs',
            'Locally Caught Fish',
            'Seasonal Vegetable Risotto',
            'Heirloom Tomato Pasta',
          ],
          'desserts': [
            'Seasonal Fruit Crisp',
            'Local Honey Panna Cotta',
            'Organic Chocolate Cake',
            'Berry Shortcake',
          ],
        },
      },
    ];
  }

  /// Get all photography services
  static List<Map<String, dynamic>> getPhotographyServices() {
    return [
      {
        'id': '1',
        'name': 'Capture Moments Photography',
        'description':
            'Professional photography service specializing in weddings and events.',
        'priceRange': '\$\$\$',
        'rating': 4.9,
        'features': [
          'Wedding Photography',
          'Event Coverage',
          'Portrait Sessions',
          'Photo Booth',
        ],
        'imageUrls': [],
        'contactEmail': 'info@capturemoments.com',
        'contactPhone': '555-456-7890',
        'packages': [
          {
            'id': '1',
            'name': 'Basic Coverage',
            'description': '4 hours of photography coverage.',
            'price': 1200.0,
            'items': [
              '4 hours of coverage',
              '1 photographer',
              'Online gallery',
              '100 edited digital images',
            ],
          },
          {
            'id': '2',
            'name': 'Standard Coverage',
            'description': '8 hours of photography coverage.',
            'price': 2400.0,
            'items': [
              '8 hours of coverage',
              '1 photographer',
              'Online gallery',
              '300 edited digital images',
              'Engagement session',
            ],
          },
          {
            'id': '3',
            'name': 'Premium Coverage',
            'description':
                'Full day photography coverage with 2 photographers.',
            'price': 3600.0,
            'items': [
              'Full day coverage (up to 12 hours)',
              '2 photographers',
              'Online gallery',
              '500+ edited digital images',
              'Engagement session',
              'Photo album',
            ],
          },
        ],
      },
      {
        'id': '2',
        'name': 'Artistic Vision Photography',
        'description':
            'Creative photography service with a unique artistic style.',
        'priceRange': '\$\$\$\$',
        'rating': 4.8,
        'features': [
          'Fine Art Photography',
          'Editorial Style',
          'Destination Events',
          'Album Design',
        ],
        'imageUrls': [],
        'contactEmail': 'info@artisticvision.com',
        'contactPhone': '555-567-8901',
        'packages': [
          {
            'id': '1',
            'name': 'Signature Collection',
            'description': '6 hours of artistic photography coverage.',
            'price': 2800.0,
            'items': [
              '6 hours of coverage',
              '1 photographer',
              'Online gallery',
              '200 artistically edited images',
              'Engagement session',
            ],
          },
          {
            'id': '2',
            'name': 'Masterpiece Collection',
            'description': 'Full day artistic photography coverage.',
            'price': 4200.0,
            'items': [
              'Full day coverage (up to 10 hours)',
              '2 photographers',
              'Online gallery',
              '400 artistically edited images',
              'Engagement session',
              'Fine art album',
            ],
          },
          {
            'id': '3',
            'name': 'Destination Collection',
            'description':
                'Multi-day photography coverage for destination events.',
            'price': 6500.0,
            'items': [
              '2 days of coverage',
              '2 photographers',
              'Online gallery',
              '600+ artistically edited images',
              'Engagement session',
              'Fine art album',
              'Travel included',
            ],
          },
        ],
      },
      {
        'id': '3',
        'name': 'Timeless Photography',
        'description':
            'Classic photography service capturing timeless moments.',
        'priceRange': '\$\$',
        'rating': 4.7,
        'features': [
          'Wedding Photography',
          'Event Coverage',
          'Portrait Sessions',
          'Prints Available',
        ],
        'imageUrls': [],
        'contactEmail': 'info@timelessphotography.com',
        'contactPhone': '555-678-9012',
        'packages': [
          {
            'id': '1',
            'name': 'Essential Package',
            'description': '4 hours of photography coverage.',
            'price': 1000.0,
            'items': [
              '4 hours of coverage',
              '1 photographer',
              'Online gallery',
              '100 edited digital images',
            ],
          },
          {
            'id': '2',
            'name': 'Classic Package',
            'description': '8 hours of photography coverage.',
            'price': 1800.0,
            'items': [
              '8 hours of coverage',
              '1 photographer',
              'Online gallery',
              '250 edited digital images',
              'Engagement session',
            ],
          },
          {
            'id': '3',
            'name': 'Complete Package',
            'description': 'Full day photography coverage.',
            'price': 2500.0,
            'items': [
              'Full day coverage (up to 10 hours)',
              '1 photographer + assistant',
              'Online gallery',
              '400 edited digital images',
              'Engagement session',
              'Photo album',
            ],
          },
        ],
      },
    ];
  }

  /// Get service by ID and type
  static Map<String, dynamic>? getServiceById(String id, String type) {
    List<Map<String, dynamic>> services;

    if (type == 'catering') {
      services = getCateringServices();
    } else if (type == 'photography') {
      services = getPhotographyServices();
    } else {
      return null;
    }

    try {
      return services.firstWhere((service) => service['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Search services by name or description
  static List<Map<String, dynamic>> searchServices(String query, String type) {
    List<Map<String, dynamic>> services;

    if (type == 'catering') {
      services = getCateringServices();
    } else if (type == 'photography') {
      services = getPhotographyServices();
    } else {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();

    return services.where((service) {
      final name = service['name'].toString().toLowerCase();
      final description = service['description'].toString().toLowerCase();

      return name.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  /// Filter services by criteria
  static List<Map<String, dynamic>> filterServices({
    required String type,
    String? priceRange,
    double? minRating,
    List<String>? features,
  }) {
    List<Map<String, dynamic>> services;

    if (type == 'catering') {
      services = getCateringServices();
    } else if (type == 'photography') {
      services = getPhotographyServices();
    } else {
      return [];
    }

    if (priceRange != null) {
      services =
          services
              .where((service) => service['priceRange'] == priceRange)
              .toList();
    }

    if (minRating != null) {
      services =
          services.where((service) => service['rating'] >= minRating).toList();
    }

    if (features != null && features.isNotEmpty) {
      services =
          services.where((service) {
            final serviceFeatures = List<String>.from(service['features']);
            return features.every(
              (feature) => serviceFeatures.contains(feature),
            );
          }).toList();
    }

    return services;
  }
}
