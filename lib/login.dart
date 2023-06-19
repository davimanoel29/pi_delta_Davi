import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PI DELTA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA52502),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submit,
                      child: Text('Entrar'),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    height: 44.0,
                    child: TextButton(
                      onPressed: _navigateToSignUp,
                      child: Text('Criar cadastro'),
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

      try {
        final responseData = json.decode(response.body);
        // Verificar se o login foi bem sucedido
        if (response.statusCode == 200) {
          final token = responseData['token'];
          // Verificar se o token foi retornado
          if (token != null && token.isNotEmpty) {
            // Navegar para a próxima tela
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(username: _username!),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Erro de autenticação"),
                content: Text("Usuário e/ou senha inválidos."),
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
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Erro"),
            content: Text("Usuário e/ou senha inválidos."),
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

  void _navigateToSignUp() {
    // Navegar para a tela de cadastro
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() async {
    final name = {'firstname': _nameController.text};
    final userData = {
      'email': _emailController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'name': name
    };

    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://fakestoreapi.com/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Cadastro realizado"),
            content: Text("O cadastro foi criado com sucesso."),
            actions: [
              TextButton(
                onPressed: () {
                  // Fechar o diálogo
                  Navigator.pop(context);
                  // Retornar para a página de login
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Erro"),
            content: Text("Ocorreu um erro ao criar o cadastro."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
        backgroundColor: Color(0xFFA52502),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Preencha os campos abaixo para criar um novo cadastro',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nome Completo'),
                  controller: _nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite seu nome completo';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nome de Usuário'),
                  controller: _usernameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite um nome de usuário';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite um endereço de e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, digite um e-mail válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite uma senha';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Container(
                  height: 44.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA52502),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _createAccount,
                    child: Text('Criar cadastro'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
