import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_page.dart'; // Import the existing product_page.dart file

class CategoryPage extends StatefulWidget {
  final String category;

  CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  Future<void> _fetchCategoryProducts() async {
    final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products/category/${widget.category}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _products = List<dynamic>.from(data);
      });
    } else {
      throw Exception('Failed to load category products');
    }
  }

  void _navigateToProductPage(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(productId: int.parse(productId)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categoria: ${widget.category}'),
        backgroundColor: Color(0xFFA52502),
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: Image.network(
              product['image'],
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            title: Text(product['title']),
            trailing: Text('R\$${product['price']}'),
            onTap: () {
              _navigateToProductPage(product['id'].toString());
            },
          );
        },
      ),
    );
  }
}
