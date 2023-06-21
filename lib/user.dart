import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class UserPage extends StatefulWidget {
  final String userId;

  UserPage({required this.userId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
    final response = await http.get(Uri.parse('http://localhost:3000/sale?userId=${widget.userId}'));
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

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Widget _buildProductInfo(ProductInfo productInfo) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produto: ${productInfo.title}'),
          Text('Quantidade: ${productInfo.quantity}'),
          Text('Preço: R\$${productInfo.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Card _buildCard(Sale sale) {
    return Card(
      child: ExpansionTile(
        title: Text('Ordem de Compra ID: ${sale.id}'),
        children: [
          ListTile(
            title: Text('Total da Compra: R\$${sale.total.toStringAsFixed(2)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text('Data da Compra: ${sale.date.toString().split(' ')[0]}'),
                SizedBox(height: 8),
                Text('Produtos:'),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var productInfo in sale.products)
                      _buildProductInfo(productInfo),
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
                return _buildCard(_sales[index]);
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
    final productsData = json['saleproducts'] as List<dynamic>;
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
  final int idproduct;
  final String title;
  final int quantity;
  final double price;

  ProductInfo({
    required this.idproduct,
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      idproduct: json['idproduct'],
      title: json['title'],
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
