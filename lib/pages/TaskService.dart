import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  int id;
  String name;
  bool isComplete;

  Task({required this.id, required this.name, this.isComplete = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      isComplete: json['isComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isComplete': isComplete,
    };
  }
}

class TaskService {
  static const String baseUrl = 'https://todolist-api-production-1e59.up.railway.app';
  static const String tasksKey = 'tasks';

  // Récupérer la liste des tâches depuis l'API
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<Task> tasks = jsonResponse.map((task) => Task.fromJson(task)).toList();
        
        // Sauvegarder les tâches localement
        await saveTasksToLocal(tasks);
        
        return tasks;
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print("Erreur de chargement de l'API, récupération des tâches locales.");
      return await loadTasksFromLocal();
    }
  }

  // Sauvegarder les tâches dans SharedPreferences
  Future<void> saveTasksToLocal(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskList = tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList(tasksKey, taskList);
  }

  // Charger les tâches depuis SharedPreferences
  Future<List<Task>> loadTasksFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList(tasksKey);
    
    if (taskList != null) {
      return taskList.map((task) => Task.fromJson(json.decode(task))).toList();
    } else {
      return [];
    }
  }

  // Ajouter une tâche
  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      Task createdTask = Task.fromJson(json.decode(response.body));
      
      // Charger les tâches, ajouter la nouvelle tâche, et sauvegarder
      List<Task> tasks = await loadTasksFromLocal();
      tasks.add(createdTask);
      await saveTasksToLocal(tasks);
      
      return createdTask;
    } else {
      throw Exception('Failed to create task');
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      List<Task> tasks = await loadTasksFromLocal();
      int index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        await saveTasksToLocal(tasks);
      }
    } else {
      throw Exception('Failed to update task');
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));

    if (response.statusCode == 200) {
      List<Task> tasks = await loadTasksFromLocal();
      tasks.removeWhere((task) => task.id == id);
      await saveTasksToLocal(tasks);
    } else {
      throw Exception('Failed to delete task');
    }
  }
}
