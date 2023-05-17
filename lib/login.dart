import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.brown
        ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _username, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFFA52502),        
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'images/logo.jpg',
                      width: 300,
                      height: 300,
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome do Usuário'),
                    onSaved: (value) => _username = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    onSaved: (value) => _password = value,
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: 44.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFFA52502),
                        primary: Colors.white,
                      ),
                      onPressed: _submit,
                      child: Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      final url = Uri.parse('https://fakestoreapi.com/auth/login');
      final response = await http.post(
        url,
        body: {
          "username": _username,
          "password": _password,
        },
      );
      final responseData = json.decode(response.body);
      print(responseData);
      // Verificar se o login foi bem sucedido
      if (response.statusCode == 200) {
        final token = responseData['token'];
        // Verificar se o token foi retornado
        if (token != null && token.isNotEmpty) {
          // Navegar para a próxima tela
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Erro de autenticação"),
              content: Text("Usuário ou senha inválidos."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      } 
    }
  }
}