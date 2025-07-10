import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  final String _baseUrl = 'https://your-project-id.firebaseio.com';

  Future<List<TaskModel>> fetchTasks(String userId) async {
    final url = Uri.parse('$_baseUrl/tasks/$userId.json');
    final response = await http.get(url);

    if (response.body == 'null') return [];

    final data = json.decode(response.body) as Map<String, dynamic>;
    return data.entries
        .map((entry) => TaskModel.fromJson(entry.key, Map<String, dynamic>.from(entry.value)))
        .toList();
  }

  Future<void> addTask(TaskModel task) async {
    final url = Uri.parse('$_baseUrl/tasks/${task.userId}.json');
    await http.post(url, body: json.encode(task.toJson()));
  }

  Future<void> updateTask(TaskModel task) async {
    final url = Uri.parse('$_baseUrl/tasks/${task.userId}/${task.id}.json');
    await http.put(url, body: json.encode(task.toJson()));
  }

  Future<void> deleteTask(String userId, String id) async {
    final url = Uri.parse('$_baseUrl/tasks/$userId/$id.json');
    await http.delete(url);
  }
}
