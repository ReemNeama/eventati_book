import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/screens/planning/widgets/task_card.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// A widget that visualizes task dependencies as a graph
class DependencyGraph extends StatefulWidget {
  /// The list of tasks
  final List<Task> tasks;

  /// The list of task categories
  final List<TaskCategory> categories;

  /// The list of task dependencies
  final List<TaskDependency> dependencies;

  /// Callback when a task is selected
  final Function(Task task)? onTaskSelected;

  /// Creates a new dependency graph
  const DependencyGraph({
    super.key,
    required this.tasks,
    required this.categories,
    required this.dependencies,
    this.onTaskSelected,
  });

  @override
  State<DependencyGraph> createState() => _DependencyGraphState();
}

class _DependencyGraphState extends State<DependencyGraph> {
  /// The currently selected task
  Task? _selectedTask;

  /// The offset for panning the graph
  Offset _offset = Offset.zero;

  /// The scale factor for zooming the graph
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        // Store the current scale and offset when starting a new gesture
        _scale = _scale;
        _offset = _offset;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Update scale (zoom) with limits
          _scale = (_scale * details.scale).clamp(0.5, 2.0);

          // Update offset (pan)
          _offset += details.focalPointDelta;
        });
      },
      child: ClipRect(
        child: Stack(
          children: [
            // Background grid
            _buildGrid(),

            // Transformable content
            Transform.translate(
              offset: _offset,
              child: Transform.scale(
                scale: _scale,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    // Dependency lines
                    ..._buildDependencyLines(),

                    // Task nodes
                    ..._buildTaskNodes(),
                  ],
                ),
              ),
            ),

            // Controls overlay
            Positioned(
              right: AppConstants.mediumPadding,
              bottom: AppConstants.mediumPadding,
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the background grid
  Widget _buildGrid() {
    return CustomPaint(
      painter: GridPainter(
        gridSpacing: 50 * _scale,
        gridColor: Colors.grey.withOpacity(0.2),
      ),
      size: Size.infinite,
    );
  }

  /// Builds the dependency lines between tasks
  List<Widget> _buildDependencyLines() {
    final lines = <Widget>[];

    for (final dependency in widget.dependencies) {
      // Find the tasks
      final prerequisiteTask = widget.tasks.firstWhere(
        (task) => task.id == dependency.prerequisiteTaskId,
        orElse:
            () => Task(
              id: dependency.prerequisiteTaskId,
              title: 'Unknown Task',
              categoryId: '0',
              dueDate: DateTime.now(),
              status: TaskStatus.notStarted,
            ),
      );

      final dependentTask = widget.tasks.firstWhere(
        (task) => task.id == dependency.dependentTaskId,
        orElse:
            () => Task(
              id: dependency.dependentTaskId,
              title: 'Unknown Task',
              categoryId: '0',
              dueDate: DateTime.now(),
              status: TaskStatus.notStarted,
            ),
      );

      // Calculate positions
      final prerequisitePosition = _calculateTaskPosition(prerequisiteTask);
      final dependentPosition = _calculateTaskPosition(dependentTask);

      // Add the line
      lines.add(
        CustomPaint(
          painter: DependencyLinePainter(
            start: prerequisitePosition,
            end: dependentPosition,
            color:
                _selectedTask?.id == prerequisiteTask.id ||
                        _selectedTask?.id == dependentTask.id
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.5),
            strokeWidth:
                _selectedTask?.id == prerequisiteTask.id ||
                        _selectedTask?.id == dependentTask.id
                    ? 2.0
                    : 1.0,
          ),
          size: Size.infinite,
        ),
      );
    }

    return lines;
  }

  /// Builds the task nodes
  List<Widget> _buildTaskNodes() {
    final nodes = <Widget>[];

    for (final task in widget.tasks) {
      // Find the category
      final category = widget.categories.firstWhere(
        (cat) => cat.id == task.categoryId,
        orElse:
            () => TaskCategory(
              id: '0',
              name: 'Unknown',
              icon: Icons.help_outline,
              color: Colors.grey,
            ),
      );

      // Calculate position
      final position = _calculateTaskPosition(task);

      // Add the node
      nodes.add(
        Positioned(
          left: position.dx - 150, // Half the card width
          top: position.dy - 60, // Half the card height
          child: SizedBox(
            width: 300, // Card width
            child: TaskCard(
              task: task,
              category: category,
              isSelected: _selectedTask?.id == task.id,
              isPrerequisite: _isPrerequisite(task),
              isDependent: _isDependent(task),
              onTap: () {
                setState(() {
                  _selectedTask = _selectedTask?.id == task.id ? null : task;
                });
                if (widget.onTaskSelected != null) {
                  widget.onTaskSelected!(task);
                }
              },
            ),
          ),
        ),
      );
    }

    return nodes;
  }

  /// Builds the zoom and reset controls
  Widget _buildControls() {
    return Column(
      children: [
        // Zoom in button
        FloatingActionButton(
          heroTag: 'zoom_in',
          mini: true,
          onPressed: () {
            setState(() {
              _scale = (_scale + 0.1).clamp(0.5, 2.0);
            });
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: AppConstants.smallPadding),

        // Zoom out button
        FloatingActionButton(
          heroTag: 'zoom_out',
          mini: true,
          onPressed: () {
            setState(() {
              _scale = (_scale - 0.1).clamp(0.5, 2.0);
            });
          },
          child: const Icon(Icons.remove),
        ),
        const SizedBox(height: AppConstants.smallPadding),

        // Reset button
        FloatingActionButton(
          heroTag: 'reset',
          mini: true,
          onPressed: () {
            setState(() {
              _scale = 1.0;
              _offset = Offset.zero;
            });
          },
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  /// Calculates the position of a task in the graph
  Offset _calculateTaskPosition(Task task) {
    // This is a simple layout algorithm that positions tasks based on their due date
    // and category. A more sophisticated algorithm could be implemented for better
    // visualization.

    // Get the index of the task's category
    final categoryIndex = widget.categories.indexWhere(
      (cat) => cat.id == task.categoryId,
    );

    // Calculate x position based on category
    final x = 200.0 + (categoryIndex * 350.0);

    // Calculate y position based on due date
    final now = DateTime.now();
    final daysDifference = task.dueDate.difference(now).inDays;
    final y = 200.0 + (daysDifference * 2.0);

    return Offset(x, y);
  }

  /// Checks if a task is a prerequisite for the selected task
  bool _isPrerequisite(Task task) {
    if (_selectedTask == null) return false;

    return widget.dependencies.any(
      (d) =>
          d.prerequisiteTaskId == task.id &&
          d.dependentTaskId == _selectedTask!.id,
    );
  }

  /// Checks if a task is dependent on the selected task
  bool _isDependent(Task task) {
    if (_selectedTask == null) return false;

    return widget.dependencies.any(
      (d) =>
          d.dependentTaskId == task.id &&
          d.prerequisiteTaskId == _selectedTask!.id,
    );
  }
}

/// Custom painter for drawing the dependency lines
class DependencyLinePainter extends CustomPainter {
  /// The start position of the line
  final Offset start;

  /// The end position of the line
  final Offset end;

  /// The color of the line
  final Color color;

  /// The stroke width of the line
  final double strokeWidth;

  /// Creates a new dependency line painter
  DependencyLinePainter({
    required this.start,
    required this.end,
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    // Draw a curved line with an arrow
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Control points for the curve
    final controlPoint1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);

    // Draw arrow at the end
    _drawArrow(canvas, end, Offset(end.dx - 10, end.dy), paint);
  }

  /// Draws an arrow at the end of the line
  void _drawArrow(Canvas canvas, Offset tip, Offset tail, Paint paint) {
    // Calculate the angle of the line
    final angle = (tip - tail).direction;

    // Calculate the points for the arrow
    final arrowSize = 10.0;
    final arrowPoint1 = Offset(
      tip.dx - arrowSize * 1.5 * math.cos(angle - math.pi / 6),
      tip.dy - arrowSize * 1.5 * math.sin(angle - math.pi / 6),
    );
    final arrowPoint2 = Offset(
      tip.dx - arrowSize * 1.5 * math.cos(angle + math.pi / 6),
      tip.dy - arrowSize * 1.5 * math.sin(angle + math.pi / 6),
    );

    // Draw the arrow
    final arrowPath =
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
          ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
          ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant DependencyLinePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Custom painter for drawing the background grid
class GridPainter extends CustomPainter {
  /// The spacing between grid lines
  final double gridSpacing;

  /// The color of the grid lines
  final Color gridColor;

  /// Creates a new grid painter
  GridPainter({this.gridSpacing = 50.0, this.gridColor = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1.0;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.gridSpacing != gridSpacing ||
        oldDelegate.gridColor != gridColor;
  }
}
