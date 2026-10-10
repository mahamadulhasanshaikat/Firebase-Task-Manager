import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../auth/login_page.dart';
import 'add_task_page.dart';
import 'edit_task_page.dart';
import 'widgets/delete_confirmation_dialog.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskViewModel>(context, listen: false).initTaskStream());
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();
    final authVM = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Task',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tasks',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${taskVM.totalCount} total',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Today • ${DateFormat('EEEE, MMM d').format(DateTime.now())}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearchVisible ? Icons.close : Icons.search,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () => setState(
                            () => _isSearchVisible = !_isSearchVisible),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
                        onPressed: () async {
                          await authVM.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isSearchVisible)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (val) => taskVM.setSearchQuery(val),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildFilterTab('All', taskVM.totalCount, taskVM),
                  const SizedBox(width: 8),
                  _buildFilterTab('Pending', taskVM.pendingCount, taskVM),
                  const SizedBox(width: 8),
                  _buildFilterTab('Completed', taskVM.completedCount, taskVM),
                ],
              ),
            ),
            Expanded(
              child: taskVM.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskVM.filteredTasks.isEmpty
                      ? const Center(
                          child: Text(
                            'No tasks found.',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                          itemCount: taskVM.filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = taskVM.filteredTasks[index];
                            return _buildTaskCard(task, taskVM);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, int count, TaskViewModel vm) {
    final isSelected = vm.selectedFilter == label;
    return GestureDetector(
      onTap: () => vm.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, TaskViewModel vm) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = const Color(0xFFEF4444);
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFF59E0B);
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF10B981);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => vm.toggleTaskStatus(task.id, !task.isCompleted),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? const Color(0xFF4F46E5)
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: priorityColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.priority.name.capitalize(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.isCompleted) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditTaskPage(task: task)),
                  );
                },
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteConfirmationDialog(task: task),
                  );
                },
                child: const Icon(Icons.delete_outline,
                    size: 18, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF64748B), height: 1.3),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                'Due ${DateFormat('MMM d').format(task.dueDate)}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time,
                  size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d').format(task.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}