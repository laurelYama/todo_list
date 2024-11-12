import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://todolist-api-production-1e59.up.railway.app";

  // Méthode pour s'inscrire
  Future<http.Response> signUp(String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/users/signup"); // Vérifiez l'URL d'inscription
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );
    return response;
  }

  // Méthode pour se connecter
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login"); // Vérifiez l'URL de connexion
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    return response;
  }

  // Méthode pour récupérer la liste des tâches de l'utilisateur
  Future<http.Response> getTasks(String token) async {
    final url = Uri.parse("$baseUrl/tasks");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return response;
  }

  // Méthode pour créer une nouvelle tâche
  Future<http.Response> createTask(String title, String description, String token) async {
    final url = Uri.parse("$baseUrl/tasks");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": title,
        "description": description,
      }),
    );
    return response;
  }

  // Méthode pour supprimer une tâche
  Future<http.Response> deleteTask(String taskId, String token) async {
    final url = Uri.parse("$baseUrl/tasks/$taskId");
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return response;
  }
}
