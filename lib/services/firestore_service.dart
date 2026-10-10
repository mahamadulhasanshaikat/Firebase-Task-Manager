import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _taskCollection {
    if (_uid == null) throw Exception("User is not authenticated");
    return _db.collection('users').doc(_uid).collection('tasks');
  }

  Stream<List<TaskModel>> getTasksStream() {
    return _taskCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList());
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    final doc = await _taskCollection.doc(taskId).get();
    if (doc.exists) {
      return TaskModel.fromDocument(doc);
    }
    return null;
  }

  Future<void> addTask(TaskModel task) async {
    await _taskCollection.add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _taskCollection.doc(taskId).update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }
}