/// Data file containing catering service information
class CateringData {
  /// Get all catering services data
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
            'description': 'Premium catering package with extensive options.',
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
            'description':
                'All-inclusive catering package with top-tier service.',
            'price': 125.0, // per person
            'items': [
              '8 appetizer options',
              '5 main course options',
              '4 dessert options',
              'Non-alcoholic beverages',
              'Premium bar service',
              'Coffee and tea station',
              'Late night snack',
              'Champagne toast',
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
        'name': 'Fresh & Flavorful',
        'description':
            'Farm-to-table catering service using locally sourced ingredients.',
        'priceRange': '\$\$',
        'rating': 4.7,
        'features': [
          'Locally Sourced',
          'Seasonal Menus',
          'Organic Options',
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
}
