import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:convert';

class ProductPage extends StatefulWidget {
  final Product product;

  ProductPage(this.product);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.product.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.product.description,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Image.network(
                widget.product.image,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'R\$ ${widget.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                addToCart(widget.product, 1);
              },
              child: Text('Adicionar ao carrinho'),
            ),
          ],
        ),
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
                    //"rate": product.rate,
                    //"count": product.count, 
                    "quantity": 1
      }
      ),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar produto ao carrinho')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto adicionado ao carrinho')),        
      );
    }
  }
}