import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  User? _user;
  final List<TaskModel> _tasks = [];
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref('tasks');

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  Future<void> setUser(User? user) async {
    _user = user;
    if (_user != null) {
      await fetchTasks();
      _listenToTasks();
    } else {
      _tasks.clear();
      notifyListeners();
    }
  }

  Future<void> fetchTasks() async {
    if (_user == null) return;
    try {
      final snapshot = await _tasksRef.child(_user!.uid).get();
      _tasks.clear();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          _tasks.add(TaskModel.fromJson(key, Map<String, dynamic>.from(value)));
        });
      }
      notifyListeners();
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  void _listenToTasks() {
    if (_user == null) return;
    _tasksRef.child(_user!.uid).onValue.listen((event) {
      final snapshot = event.snapshot;
      _tasks.clear();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          _tasks.add(TaskModel.fromJson(key, Map<String, dynamic>.from(value)));
        });
      }
      notifyListeners();
    }, onError: (e) {
      print("Realtime error: $e");
    });
  }

  Future<void> addTask(String title) async {
    if (_user == null) return;
    try {
      final newTaskRef = _tasksRef.child(_user!.uid).push();
      final taskId = newTaskRef.key;
      if (taskId == null) throw Exception("No task ID generated.");

      final taskData = TaskModel(
        id: taskId,
        userId: _user!.uid,
        title: title,
        isCompleted: false,
      ).toJson();

      await newTaskRef.set(taskData);
    } catch (e) {
      print("Add task error: $e");
    }
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    if (_user == null) return;
    try {
      final taskRef = _tasksRef.child(_user!.uid).child(updatedTask.id);
      await taskRef.update(updatedTask.toJson());

      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      print("Update task error: $e");
    }
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final updatedTask = TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      isCompleted: !task.isCompleted,
    );
    await updateTask(updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    if (_user == null) return;
    try {
      await _tasksRef.child(_user!.uid).child(taskId).remove();
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      print("Delete error: $e");
    }
  }
}
