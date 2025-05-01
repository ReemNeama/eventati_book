import 'package:flutter/material.dart';

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
        title: const Text(
          "Eventati Book",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(),
    );
  }
}
