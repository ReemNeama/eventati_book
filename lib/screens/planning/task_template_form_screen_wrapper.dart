import 'package:flutter/material.dart';
import 'package:eventati_book/models/planning_models/task_template.dart';
import 'package:eventati_book/screens/planning/task_template_form_screen.dart';

/// Wrapper for the task template form screen
/// This is used to navigate to the form screen from the template screen
class TaskTemplateFormScreenWrapper extends StatelessWidget {
  /// The template to edit, or null for a new template
  final TaskTemplate? template;

  /// Constructor
  const TaskTemplateFormScreenWrapper({super.key, this.template});

  @override
  Widget build(BuildContext context) {
    return TaskTemplateFormScreen(template: template);
  }
}
