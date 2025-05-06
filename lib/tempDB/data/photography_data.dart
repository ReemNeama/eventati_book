/// Data file containing photography service information
class PhotographyData {
  /// Get all photography services data
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
}
