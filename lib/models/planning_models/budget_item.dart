import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BudgetCategory {
  final String id;
  final String name;
  final IconData icon;

  BudgetCategory({required this.id, required this.name, required this.icon});

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore document
  factory BudgetCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }

    return BudgetCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: IconData(
        data['iconCodePoint'] ?? Icons.attach_money.codePoint,
        fontFamily: data['iconFontFamily'],
        fontPackage: data['iconFontPackage'],
      ),
    );
  }
}

class BudgetItem {
  final String id;
  final String categoryId;
  final String description;
  final double estimatedCost;
  final double? actualCost;
  final bool isPaid;
  final DateTime? paymentDate;
  final String? notes;
  final String? vendorName;
  final String? vendorContact;
  final DateTime? dueDate;
  final bool isBooked;
  final String? bookingId;

  BudgetItem({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.estimatedCost,
    this.actualCost,
    this.isPaid = false,
    this.paymentDate,
    this.notes,
    this.vendorName,
    this.vendorContact,
    this.dueDate,
    this.isBooked = false,
    this.bookingId,
  });

  BudgetItem copyWith({
    String? id,
    String? categoryId,
    String? description,
    double? estimatedCost,
    double? actualCost,
    bool? isPaid,
    DateTime? paymentDate,
    String? notes,
    String? vendorName,
    String? vendorContact,
    DateTime? dueDate,
    bool? isBooked,
    String? bookingId,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      isPaid: isPaid ?? this.isPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      vendorName: vendorName ?? this.vendorName,
      vendorContact: vendorContact ?? this.vendorContact,
      dueDate: dueDate ?? this.dueDate,
      isBooked: isBooked ?? this.isBooked,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'description': description,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'isPaid': isPaid,
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
      'vendorName': vendorName,
      'vendorContact': vendorContact,
      'dueDate': dueDate?.toIso8601String(),
      'isBooked': isBooked,
      'bookingId': bookingId,
    };
  }

  /// Create from JSON
  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'],
      categoryId: json['categoryId'] ?? '',
      description: json['description'] ?? '',
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      actualCost:
          json['actualCost'] != null ? (json['actualCost']).toDouble() : null,
      isPaid: json['isPaid'] ?? false,
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate'])
              : null,
      notes: json['notes'],
      vendorName: json['vendorName'],
      vendorContact: json['vendorContact'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isBooked: json['isBooked'] ?? false,
      bookingId: json['bookingId'],
    );
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'description': description,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'isPaid': isPaid,
      'paymentDate':
          paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'notes': notes,
      'vendorName': vendorName,
      'vendorContact': vendorContact,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isBooked': isBooked,
      'bookingId': bookingId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore document
  factory BudgetItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }

    return BudgetItem(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      description: data['description'] ?? '',
      estimatedCost: (data['estimatedCost'] ?? 0).toDouble(),
      actualCost:
          data['actualCost'] != null ? (data['actualCost']).toDouble() : null,
      isPaid: data['isPaid'] ?? false,
      paymentDate:
          data['paymentDate'] != null
              ? (data['paymentDate'] as Timestamp).toDate()
              : null,
      notes: data['notes'],
      vendorName: data['vendorName'],
      vendorContact: data['vendorContact'],
      dueDate:
          data['dueDate'] != null
              ? (data['dueDate'] as Timestamp).toDate()
              : null,
      isBooked: data['isBooked'] ?? false,
      bookingId: data['bookingId'],
    );
  }

  /// Calculate remaining amount
  double get remaining => estimatedCost - (actualCost ?? 0);

  /// Get payment status
  String get status {
    if (isPaid) return 'Paid';
    if (actualCost != null && actualCost! > 0) return 'Partially Paid';
    return 'Not Paid';
  }
}
