import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final taskVM = context.read<TaskViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Task Details', style: TextStyle(color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<TaskModel?>(
        future: taskVM.getTaskById(taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Task not found or was deleted.'));
          }

          final task = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description.isEmpty ? 'No notes added.' : task.description,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Due Date:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(DateFormat('dd MMMM yyyy').format(task.dueDate),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Course Bucket:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(task.courseBucket, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Priority:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(
                          task.priority.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(
                          task.isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}