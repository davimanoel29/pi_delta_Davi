import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  String? _nome, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Usuário'),
                onSaved: (value) => _nome = value,
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
                    backgroundColor: Colors.blue,
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
    );
  }

  void _submit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      final url = Uri.parse('https://fakestoreapi.com/auth/login');
      final response = await http.post(
        url,
        body: json.encode({'Nome do Usuário': _nome, 'password': _password}),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      // TODO: verificar se o login foi bem sucedido e navegar para a próxima tela
    }
  }
}
