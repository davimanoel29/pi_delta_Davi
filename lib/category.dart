import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_page.dart'; 

class CategoryPage extends StatefulWidget {
  final String category;
  final String userId;

  CategoryPage({required this.category, required this.userId});

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
    final response = await http.get(Uri.parse(
        'https://fakestoreapi.com/products/category/${widget.category}'));

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
        builder: (context) =>
            ProductPage(productId: int.parse(productId), userId: widget.userId),
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return GestureDetector(
            onTap: () {
              _navigateToProductPage(product['id'].toString());
            },
            child: Card(
              elevation: 2,
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['title'],
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'R\$${product['price']}',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
