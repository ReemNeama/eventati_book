import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/models/planning_models/task_dependency.dart';
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
  final List<dynamic> dependencies;

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

            // Legend overlay
            Positioned(
              left: AppConstants.mediumPadding,
              bottom: AppConstants.mediumPadding,
              child: _buildLegend(),
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
        gridColor: Color.fromRGBO(
          AppColors.disabled.r.toInt(),
          AppColors.disabled.g.toInt(),
          AppColors.disabled.b.toInt(),
          0.20,
        ), // 0.2 * 255 = 51
      ),
      size: Size.infinite,
    );
  }

  /// Builds the dependency lines between tasks
  List<Widget> _buildDependencyLines() {
    final lines = <Widget>[];

    for (final dependency in widget.dependencies) {
      // Get the task IDs
      final prerequisiteTaskId = dependency.prerequisiteTaskId;
      final dependentTaskId = dependency.dependentTaskId;

      // Find the tasks
      final prerequisiteTask = widget.tasks.firstWhere(
        (task) => task.id == prerequisiteTaskId,
        orElse:
            () => Task(
              id: prerequisiteTaskId,
              title: 'Unknown Task',
              categoryId: '0',
              dueDate: DateTime.now(),
              status: TaskStatus.notStarted,
            ),
      );

      final dependentTask = widget.tasks.firstWhere(
        (task) => task.id == dependentTaskId,
        orElse:
            () => Task(
              id: dependentTaskId,
              title: 'Unknown Task',
              categoryId: '0',
              dueDate: DateTime.now(),
              status: TaskStatus.notStarted,
            ),
      );

      // Calculate positions
      final prerequisitePosition = _calculateTaskPosition(prerequisiteTask);
      final dependentPosition = _calculateTaskPosition(dependentTask);

      // Extract dependency type and offset days if available
      DependencyType? dependencyType;
      int offsetDays = 0;

      if (dependency is TaskDependency) {
        dependencyType = dependency.type;
        offsetDays = dependency.offsetDays;
      }

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
                    : Color.fromRGBO(
                      AppColors.disabled.r.toInt(),
                      AppColors.disabled.g.toInt(),
                      AppColors.disabled.b.toInt(),
                      0.50,
                    ), // 0.5 * 255 = 128
            strokeWidth:
                _selectedTask?.id == prerequisiteTask.id ||
                        _selectedTask?.id == dependentTask.id
                    ? 2.0
                    : 1.0,
            dependencyType: dependencyType,
            offsetDays: offsetDays,
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
              description: '',
              icon: 'help_outline',
              color: '#9E9E9E',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
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
              prerequisiteCount: _getPrerequisiteCount(task),
              dependentCount: _getDependentCount(task),
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

  /// Builds a legend explaining the different dependency types
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          Colors.white.r.toInt(),
          Colors.white.g.toInt(),
          Colors.white.b.toInt(),
          0.90,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.black.r.toInt(),
              Colors.black.g.toInt(),
              Colors.black.b.toInt(),
              0.16,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dependency Types:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Finish-to-Start',
            DependencyType.finishToStart,
            'Task B starts after Task A finishes',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            'Start-to-Start',
            DependencyType.startToStart,
            'Task B starts after Task A starts',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            'Finish-to-Finish',
            DependencyType.finishToFinish,
            'Task B finishes after Task A finishes',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            'Start-to-Finish',
            DependencyType.startToFinish,
            'Task B finishes after Task A starts',
          ),
        ],
      ),
    );
  }

  /// Builds a single legend item
  Widget _buildLegendItem(
    String label,
    DependencyType type,
    String description,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: CustomPaint(
            painter: _LegendLinePainter(type),
            size: const Size(30, 2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 9, color: AppColors.disabled),
            ),
          ],
        ),
      ],
    );
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

  /// Gets the count of tasks that depend on this task
  int _getDependentCount(Task task) {
    return widget.dependencies
        .where((d) => d.prerequisiteTaskId == task.id)
        .length;
  }

  /// Gets the count of tasks that this task depends on
  int _getPrerequisiteCount(Task task) {
    return widget.dependencies
        .where((d) => d.dependentTaskId == task.id)
        .length;
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

  /// The type of dependency
  final DependencyType? dependencyType;

  /// The offset days for the dependency
  final int offsetDays;

  /// Creates a new dependency line painter
  DependencyLinePainter({
    required this.start,
    required this.end,
    this.color = AppColors.disabled,
    this.strokeWidth = 1.0,
    this.dependencyType,
    this.offsetDays = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    // Set dash pattern based on dependency type
    if (dependencyType != null) {
      switch (dependencyType!) {
        case DependencyType.finishToStart:
          // Solid line (default)
          break;
        case DependencyType.startToStart:
          // Dashed line
          paint.strokeCap = StrokeCap.round;
          paint.strokeJoin = StrokeJoin.round;
          paint.strokeWidth = strokeWidth * 1.2;
          paint.shader = _getDashedLineShader();
          break;
        case DependencyType.finishToFinish:
          // Dotted line
          paint.strokeCap = StrokeCap.round;
          paint.strokeJoin = StrokeJoin.round;
          paint.strokeWidth = strokeWidth * 1.5;
          paint.shader = _getDottedLineShader();
          break;
        case DependencyType.startToFinish:
          // Dash-dot line
          paint.strokeCap = StrokeCap.round;
          paint.strokeJoin = StrokeJoin.round;
          paint.strokeWidth = strokeWidth * 1.2;
          paint.shader = _getDashDotLineShader();
          break;
      }
    }

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

    // Draw offset days label if needed
    if (offsetDays > 0) {
      _drawOffsetDaysLabel(canvas, path);
    }
  }

  /// Creates a shader for dashed lines
  Shader _getDashedLineShader() {
    return LinearGradient(
      colors: [color, Colors.transparent],
      stops: const [0.7, 0.3],
      tileMode: TileMode.repeated,
    ).createShader(Rect.fromPoints(start, Offset(start.dx + 15, start.dy)));
  }

  /// Creates a shader for dotted lines
  Shader _getDottedLineShader() {
    return LinearGradient(
      colors: [color, Colors.transparent],
      stops: const [0.5, 0.5],
      tileMode: TileMode.repeated,
    ).createShader(Rect.fromPoints(start, Offset(start.dx + 8, start.dy)));
  }

  /// Creates a shader for dash-dot lines
  Shader _getDashDotLineShader() {
    return LinearGradient(
      colors: [color, Colors.transparent, color, Colors.transparent],
      stops: const [0.5, 0.2, 0.1, 0.2],
      tileMode: TileMode.repeated,
    ).createShader(Rect.fromPoints(start, Offset(start.dx + 20, start.dy)));
  }

  /// Draws a label showing the offset days
  void _drawOffsetDaysLabel(Canvas canvas, Path path) {
    // Find a point in the middle of the path
    final pathMetrics = path.computeMetrics().first;
    final midPoint =
        pathMetrics.getTangentForOffset(pathMetrics.length / 2)?.position;

    if (midPoint != null) {
      final textSpan = TextSpan(
        text: '+$offsetDays days',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Color.fromRGBO(
            Colors.white.r.toInt(),
            Colors.white.g.toInt(),
            Colors.white.b.toInt(),
            0.78,
          ),
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          midPoint.dx - textPainter.width / 2,
          midPoint.dy - textPainter.height - 5,
        ),
      );
    }
  }

  /// Draws an arrow at the end of the line
  void _drawArrow(Canvas canvas, Offset tip, Offset tail, Paint paint) {
    // Calculate the angle of the line
    final angle = (tip - tail).direction;

    // Calculate the points for the arrow
    const arrowSize = 10.0;
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
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dependencyType != dependencyType ||
        oldDelegate.offsetDays != offsetDays;
  }
}

/// Custom painter for drawing a legend line
class _LegendLinePainter extends CustomPainter {
  /// The type of dependency to draw
  final DependencyType type;

  /// Creates a new legend line painter
  _LegendLinePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.disabled
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    // Set dash pattern based on dependency type
    switch (type) {
      case DependencyType.finishToStart:
        // Solid line (default)
        break;
      case DependencyType.startToStart:
        // Dashed line
        paint.strokeCap = StrokeCap.round;
        paint.strokeJoin = StrokeJoin.round;
        paint.strokeWidth = 2.5;
        paint.shader = const LinearGradient(
          colors: [AppColors.disabled, Colors.transparent],
          stops: [0.7, 0.3],
          tileMode: TileMode.repeated,
        ).createShader(const Rect.fromLTWH(0, 0, 10, 2));
        break;
      case DependencyType.finishToFinish:
        // Dotted line
        paint.strokeCap = StrokeCap.round;
        paint.strokeJoin = StrokeJoin.round;
        paint.strokeWidth = 3.0;
        paint.shader = const LinearGradient(
          colors: [AppColors.disabled, Colors.transparent],
          stops: [0.5, 0.5],
          tileMode: TileMode.repeated,
        ).createShader(const Rect.fromLTWH(0, 0, 6, 2));
        break;
      case DependencyType.startToFinish:
        // Dash-dot line
        paint.strokeCap = StrokeCap.round;
        paint.strokeJoin = StrokeJoin.round;
        paint.strokeWidth = 2.5;
        paint.shader = const LinearGradient(
          colors: [
            AppColors.disabled,
            Colors.transparent,
            AppColors.disabled,
            Colors.transparent,
          ],
          stops: [0.5, 0.2, 0.1, 0.2],
          tileMode: TileMode.repeated,
        ).createShader(const Rect.fromLTWH(0, 0, 15, 2));
        break;
    }

    // Draw the line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw arrow at the end
    final arrowPaint =
        Paint()
          ..color = AppColors.disabled
          ..style = PaintingStyle.fill;

    final arrowPath =
        Path()
          ..moveTo(size.width, size.height / 2)
          ..lineTo(size.width - 5, size.height / 2 - 3)
          ..lineTo(size.width - 5, size.height / 2 + 3)
          ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _LegendLinePainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

/// Custom painter for drawing the background grid
class GridPainter extends CustomPainter {
  /// The spacing between grid lines
  final double gridSpacing;

  /// The color of the grid lines
  final Color gridColor;

  /// Creates a new grid painter
  GridPainter({this.gridSpacing = 50.0, this.gridColor = AppColors.disabled});

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
