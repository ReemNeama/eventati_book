import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/core_providers/accessibility_provider.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';

/// An accessible text field that combines semantic labels and keyboard navigation
///
/// This text field ensures:
/// 1. It has a semantic label for screen readers
/// 2. It has a focus node for keyboard navigation
/// 3. It has a visual focus indicator
/// 4. It provides haptic feedback when focused (if enabled)
class AccessibleTextField extends StatefulWidget {
  /// The controller for the text field
  final TextEditingController controller;

  /// The decoration for the text field
  final InputDecoration? decoration;

  /// The semantic label for the text field
  final String semanticLabel;

  /// The semantic hint for the text field (additional description)
  final String? semanticHint;

  /// The focus node for the text field
  final FocusNode? focusNode;

  /// Whether to add haptic feedback when the text field is focused
  final bool addHapticFeedback;

  /// The keyboard type for the text field
  final TextInputType keyboardType;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// The text input action
  final TextInputAction? textInputAction;

  /// The callback to call when the text field is submitted
  final ValueChanged<String>? onSubmitted;

  /// The callback to call when the text field is changed
  final ValueChanged<String>? onChanged;

  /// The validator for the text field
  final FormFieldValidator<String>? validator;

  /// Whether the text field is enabled
  final bool enabled;

  /// The maximum number of lines for the text field
  final int? maxLines;

  /// The minimum number of lines for the text field
  final int? minLines;

  /// The maximum length of the text field
  final int? maxLength;

  /// The input formatters for the text field
  final List<TextInputFormatter>? inputFormatters;

  /// Constructor
  const AccessibleTextField({
    super.key,
    required this.controller,
    required this.semanticLabel,
    this.decoration,
    this.semanticHint,
    this.focusNode,
    this.addHapticFeedback = true,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      final accessibilityProvider = Provider.of<AccessibilityProvider>(
        context,
        listen: false,
      );

      if (widget.addHapticFeedback &&
          accessibilityProvider.enableHapticFeedback) {
        AccessibilityUtils.selectionChangeHapticFeedback();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a default decoration if none is provided
    final InputDecoration effectiveDecoration =
        widget.decoration ??
        InputDecoration(
          labelText: widget.semanticLabel,
          hintText: widget.semanticHint,
        );

    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      textField: true,
      focusable: true,
      focused: _isFocused,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: effectiveDecoration,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        validator: widget.validator,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
      ),
    );
  }
}
