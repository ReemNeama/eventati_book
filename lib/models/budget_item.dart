import 'package:flutter/material.dart';

class BudgetCategory {
  final String id;
  final String name;
  final IconData icon;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
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

  BudgetItem({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.estimatedCost,
    this.actualCost,
    this.isPaid = false,
    this.paymentDate,
    this.notes,
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
    );
  }
}
