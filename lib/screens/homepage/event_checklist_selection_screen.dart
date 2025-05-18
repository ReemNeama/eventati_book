import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';

class EventChecklistSelectionScreen extends StatefulWidget {
  const EventChecklistSelectionScreen({super.key});

  @override
  State<EventChecklistSelectionScreen> createState() =>
      _EventChecklistSelectionScreenState();
}

class _EventChecklistSelectionScreenState
    extends State<EventChecklistSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text('Eventati Book', style: TextStyles.title),
        centerTitle: true,
      ),
      body: const Column(),
    );
  }
}
