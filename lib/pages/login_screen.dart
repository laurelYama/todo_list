import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/pages/signup_screen.dart';
import 'package:todo_list/pages/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final String apiUrl =
      "https://todolist-api-production-1e59.up.railway.app/auth/connexion";

  Future<void> _login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (!validateInputs(email, password)) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      setState(() {
        isLoading = false;
      });

      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? accessToken = responseData['accessToken'] as String?;

        if (accessToken != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', accessToken);
          print(
              "Token d'accès stocké: $accessToken"); // Vérification du stockage

          await prefs.setString('user_id', responseData['user']['id']);
          await prefs.setString('user_name', responseData['user']['nom']);
          await prefs.setString('user_email', responseData['user']['email']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );

          _clearInputFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Le token d\'authentification est manquant.')),
          );
        }
      } else {
        handleError(response);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : ${e.toString()}')),
      );
    }
  }

  void _clearInputFields() {
    emailController.clear();
    passwordController.clear();
  }

  bool validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tous les champs sont obligatoires.')),
      );
      return false;
    }
    return true;
  }

  void handleError(http.Response response) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final errorMessage = responseData['message'] ??
          'Échec de la connexion. Veuillez vérifier vos informations.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage.toString())));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur inconnue est survenue.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Todolist',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: 'Mot de passe', border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Connexion'),
                  ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
              child: Text("Vous n'avez pas de compte ? Créer un",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
