import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'product.dart';

class AuthPage extends StatefulWidget {
  final String userId;

  AuthPage({required this.userId});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  List<Sale> _sales = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchSales();
    await _fetchUser();
  }

  Future<void> _fetchSales() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/sale?userId=${widget.userId}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final sales = List<Sale>.from(jsonData.map((sale) => Sale.fromJson(sale)));
      setState(() {
        _sales = sales;
      });
    } else {
      throw Exception('Failed to load sales');
    }
  }

  Future<void> _fetchUser() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/users/${widget.userId}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final user = User.fromJson(jsonData);
      setState(() {
        _user = user;
      });
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<Product> _fetchProduct(int productId) async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/$productId'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final product = Product.fromJson(jsonData);
      return product;
    } else {
      throw Exception('Failed to load product');
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Widget _buildProductInfo(Product product, ProductInfo productInfo) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produto: ${product.title}'),
          Text('Quantidade: ${productInfo.quantity}'),
          Text('Preço: R\$${productInfo.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Future<Card> _buildCard(Sale sale) async {
    final products = await Future.wait(sale.products.map(
      (productInfo) => _fetchProduct(productInfo.id),
    ));

    return Card(
      child: ExpansionTile(
        title: Text('Ordem de Compra ID: ${sale.id}'),
        children: [
          ListTile(
            title: Text('Total da Compra: R\$${sale.total.toStringAsFixed(2)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8), // Adiciona um espaço entre "Data da Compra" e "Products"
                Text('Data da Compra: ${sale.date.toString().split(' ')[0]}'),
                SizedBox(height: 8), // Adiciona um espaço entre "Data da Compra" e a lista de produtos
                Text('Produtos:'),
                SizedBox(height: 8), // Adiciona um espaço entre "Data da Compra" e a lista de produtos
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < products.length; i++)
                      _buildProductInfo(products[i], sale.products[i]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuário'),
        backgroundColor: Color(0xFFA52502),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_user != null) ...[
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome'),
                  Text(_user!.name),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('E-mail'),
                  Text(_user!.email),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome de usuário'),
                  Text(_user!.username),
                ],
              ),
            ),
            Divider(),
          ],
          ListTile(
            title: Text(
              'Histórico de Compras',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Card>(
                  future: _buildCard(_sales[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data!;
                    } else {
                      return Container(); // ou um widget de carregamento
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Sale {
  final int id;
  final int userId;
  final DateTime date;
  final double total;
  final List<ProductInfo> products;

  Sale({
    required this.id,
    required this.userId,
    required this.date,
    required this.total,
    required this.products,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    final productsData = json['idproducts'] as List<dynamic>;
    final products = productsData.map((data) => ProductInfo.fromJson(data)).toList();

    return Sale(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      products: products,
    );
  }
}

class ProductInfo {
  final int id;
  final int quantity;
  final double price;

  ProductInfo({
    required this.id,
    required this.quantity,
    required this.price,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'],
      quantity: json['quantity'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String username;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final firstName = name['firstname'];
    final lastName = name['lastname'];
    final fullName = '$firstName $lastName';

    return User(
      id: json['id'],
      name: fullName,
      email: json['email'],
      username: json['username'],
    );
  }
}
