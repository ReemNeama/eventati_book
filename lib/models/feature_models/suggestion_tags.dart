import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Tags for categorizing and filtering suggestions
class SuggestionTags {
  /// Venue-related tags
  static const List<String> venueTags = [
    'small_venue', // Venues suitable for small events (< 50 guests)
    'medium_venue', // Venues suitable for medium events (50-150 guests)
    'large_venue', // Venues suitable for large events (> 150 guests)
    'indoor', // Indoor venues
    'outdoor', // Outdoor venues
    'hotel', // Hotel venues
    'banquet_hall', // Banquet hall venues
    'garden', // Garden venues
    'beach', // Beach venues
    'historic', // Historic venues
    'modern', // Modern venues
    'rustic', // Rustic venues
    'urban', // Urban venues
    'rural', // Rural venues
    'accessible', // Accessible venues
    'parking', // Venues with parking
    'accommodation', // Venues with accommodation
  ];

  /// Catering-related tags
  static const List<String> cateringTags = [
    'buffet', // Buffet-style catering
    'plated', // Plated meal catering
    'family_style', // Family-style catering
    'cocktail', // Cocktail-style catering
    'food_station', // Food station catering
    'vegetarian', // Vegetarian options
    'vegan', // Vegan options
    'gluten_free', // Gluten-free options
    'kosher', // Kosher options
    'halal', // Halal options
    'international', // International cuisine
    'local', // Local cuisine
    'dessert', // Dessert options
    'cake', // Wedding cake
    'bar_service', // Bar service
    'coffee', // Coffee service
  ];

  /// Photography-related tags
  static const List<String> photographyTags = [
    'traditional', // Traditional photography
    'photojournalistic', // Photojournalistic photography
    'contemporary', // Contemporary photography
    'artistic', // Artistic photography
    'candid', // Candid photography
    'portrait', // Portrait photography
    'drone', // Drone photography
    'videography', // Videography
    'photo_booth', // Photo booth
    'album', // Photo album
    'digital', // Digital photos
    'prints', // Printed photos
    'engagement', // Engagement photos
    'second_shooter', // Second shooter
  ];

  /// Entertainment-related tags
  static const List<String> entertainmentTags = [
    'dj', // DJ
    'band', // Live band
    'solo_musician', // Solo musician
    'ceremony_music', // Ceremony music
    'reception_music', // Reception music
    'dance_floor', // Dance floor
    'lighting', // Lighting
    'photo_booth', // Photo booth
    'games', // Games
    'mc', // Master of ceremonies
    'fireworks', // Fireworks
    'performers', // Performers
  ];

  /// Decoration-related tags
  static const List<String> decorationTags = [
    'flowers', // Flowers
    'centerpieces', // Centerpieces
    'lighting', // Lighting
    'draping', // Draping
    'linens', // Linens
    'chairs', // Chairs
    'tables', // Tables
    'signage', // Signage
    'backdrop', // Backdrop
    'arch', // Arch
    'candles', // Candles
    'lanterns', // Lanterns
  ];

  /// Style-related tags
  static const List<String> styleTags = [
    'formal', // Formal style
    'casual', // Casual style
    'rustic', // Rustic style
    'elegant', // Elegant style
    'modern', // Modern style
    'traditional', // Traditional style
    'bohemian', // Bohemian style
    'vintage', // Vintage style
    'minimalist', // Minimalist style
    'glamorous', // Glamorous style
    'romantic', // Romantic style
    'whimsical', // Whimsical style
    'industrial', // Industrial style
    'beach', // Beach style
    'garden', // Garden style
  ];

  /// Get all tags
  static List<String> get allTags {
    return [
      ...venueTags,
      ...cateringTags,
      ...photographyTags,
      ...entertainmentTags,
      ...decorationTags,
      ...styleTags,
    ];
  }

  /// Get a color for a tag
  static Color getColorForTag(String tag) {
    if (venueTags.contains(tag)) {
      return AppColors.primary;
    } else if (cateringTags.contains(tag)) {
      return AppColors.warning;
    } else if (photographyTags.contains(tag)) {
      return AppColors.primary;
    } else if (entertainmentTags.contains(tag)) {
      return AppColors.success;
    } else if (decorationTags.contains(tag)) {
      return AppColors.primary;
    } else if (styleTags.contains(tag)) {
      return AppColors.info;
    } else {
      return AppColors.disabled;
    }
  }

  /// Get an icon for a tag
  static IconData getIconForTag(String tag) {
    if (venueTags.contains(tag)) {
      return Icons.location_on;
    } else if (cateringTags.contains(tag)) {
      return Icons.restaurant;
    } else if (photographyTags.contains(tag)) {
      return Icons.camera_alt;
    } else if (entertainmentTags.contains(tag)) {
      return Icons.music_note;
    } else if (decorationTags.contains(tag)) {
      return Icons.celebration;
    } else if (styleTags.contains(tag)) {
      return Icons.style;
    } else {
      return Icons.label;
    }
  }
}
