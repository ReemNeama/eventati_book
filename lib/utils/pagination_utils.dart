import 'package:eventati_book/utils/core/constants.dart';
import 'package:eventati_book/utils/logger.dart';

/// Utility class for handling pagination
class PaginationUtils {
  /// Get the next page of items
  ///
  /// [currentPage] The current page number (0-based)
  /// [pageSize] The number of items per page
  /// [totalItems] The total number of items
  /// Returns the next page number, or null if there are no more pages
  static int? getNextPage(int currentPage, int pageSize, int totalItems) {
    final totalPages = (totalItems / pageSize).ceil();
    final nextPage = currentPage + 1;

    if (nextPage < totalPages) {
      return nextPage;
    }

    return null;
  }

  /// Check if there are more pages
  ///
  /// [currentPage] The current page number (0-based)
  /// [pageSize] The number of items per page
  /// [totalItems] The total number of items
  /// Returns true if there are more pages
  static bool hasMorePages(int currentPage, int pageSize, int totalItems) {
    return getNextPage(currentPage, pageSize, totalItems) != null;
  }

  /// Get the offset for a page
  ///
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns the offset
  static int getOffset(int page, int pageSize) {
    return page * pageSize;
  }

  /// Get the limit for a page
  ///
  /// [pageSize] The number of items per page
  /// Returns the limit
  static int getLimit(int pageSize) {
    return pageSize;
  }

  /// Create pagination parameters for a Supabase query
  ///
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns a map with 'start' and 'limit' keys
  static Map<String, dynamic> createSupabasePaginationParams(
    int page,
    int pageSize,
  ) {
    return {'start': getOffset(page, pageSize), 'limit': getLimit(pageSize)};
  }

  /// Create pagination parameters for a REST API query
  ///
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns a map with 'page' and 'pageSize' keys
  static Map<String, dynamic> createRestPaginationParams(
    int page,
    int pageSize,
  ) {
    return {'page': page, 'pageSize': pageSize};
  }

  /// Parse pagination metadata from a Supabase response
  ///
  /// [response] The Supabase response
  /// [currentPage] The current page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns a map with pagination metadata
  static Map<String, dynamic> parseSupabasePaginationMetadata(
    Map<String, dynamic> response,
    int currentPage,
    int pageSize,
  ) {
    try {
      final count = response['count'] as int? ?? 0;

      return {
        'currentPage': currentPage,
        'pageSize': pageSize,
        'totalItems': count,
        'totalPages': (count / pageSize).ceil(),
        'hasMorePages': hasMorePages(currentPage, pageSize, count),
      };
    } catch (e) {
      Logger.e('Error parsing pagination metadata: $e', tag: 'PaginationUtils');

      return {
        'currentPage': currentPage,
        'pageSize': pageSize,
        'totalItems': 0,
        'totalPages': 0,
        'hasMorePages': false,
      };
    }
  }

  /// Get default pagination parameters
  ///
  /// Returns a map with default pagination parameters
  static Map<String, dynamic> getDefaultPaginationParams() {
    return {'page': 0, 'pageSize': AppConstants.defaultPageSize};
  }
}
