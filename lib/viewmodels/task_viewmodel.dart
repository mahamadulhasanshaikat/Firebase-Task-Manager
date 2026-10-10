import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _allTasks = [];
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Pending', 'Completed'
  bool _isLoading = false;
  StreamSubscription? _taskSubscription;

  List<TaskModel> get allTasks => _allTasks;
  int get totalCount => _allTasks.length;
  int get pendingCount => _allTasks.where((t) => !t.isCompleted).length;
  int get completedCount => _allTasks.where((t) => t.isCompleted).length;

  List<TaskModel> get filteredTasks {
    return _allTasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'Pending') {
        return matchesSearch && !task.isCompleted;
      } else if (_selectedFilter == 'Completed') {
        return matchesSearch && task.isCompleted;
      }
      return matchesSearch;
    }).toList();
  }

  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;

  void initTaskStream() {
    _isLoading = true;
    notifyListeners();
    _taskSubscription?.cancel();
    _taskSubscription = _firestoreService.getTasksStream().listen((list) {
      _allTasks = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String courseBucket,
  }) async {
    final task = TaskModel(
      id: '',
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
      courseBucket: courseBucket,
    );
    await _firestoreService.addTask(task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestoreService.updateTask(task);
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _firestoreService.toggleTaskStatus(taskId, isCompleted);
  }

  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    return await _firestoreService.getTaskById(taskId);
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}