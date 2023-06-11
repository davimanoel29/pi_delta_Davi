import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:convert';

class ProductPage extends StatefulWidget {
  final int productId;
  

  ProductPage({required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product? _product;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/${widget.productId}'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _product = Product.fromJson(jsonResponse);
        });
      } else {
        throw Exception('Failed to parse product data');
      }
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

return Scaffold(
  appBar: AppBar(
    title: Text(_product?.title ?? 'Loading...'),
    backgroundColor: Color(0xFFA52502),
  ),
  body: _product != null ? Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _product?.title ?? '',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          _product?.description ?? '',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: Image.network(
            _product?.image ?? '',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          'R\$ ${_product?.price?.toStringAsFixed(2) ?? ''}',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            addToCart(_product!, 1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFA52502),
          ),
          child: Text('Adicionar ao carrinho'),
        ),
      ],
    ),
  ) : Center(
    child: CircularProgressIndicator(),
  ),
);
}

  void addToCart(Product product, int quantity) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          "userId": 1,
          "date": DateTime.now().toIso8601String(),
          "idProduct": product.id,
          "title": product.title,
          "price": product.price,
          "description": product.description,
          "category": product.category,
          "image": product.image,
          "quantity": 1
        },
      ),
    );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto adicionado ao carrinho')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao adicionar produto ao carrinho')),
    );
  }
}
}