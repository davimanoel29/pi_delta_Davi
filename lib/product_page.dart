import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:convert';

enum ProductPageState {
  loading,
  success,
  error,
}

class ProductPage extends StatefulWidget {
  final int productId;
  final String userId;

  ProductPage({required this.productId, required this.userId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product? _product;
  ProductPageState _pageState = ProductPageState.loading;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    try {
      final response = await http.get(
          Uri.parse('https://fakestoreapi.com/products/${widget.productId}'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          setState(() {
            _product = Product.fromJson(jsonResponse);
            _pageState = ProductPageState.success;
          });
        } else {
          setState(() {
            _pageState = ProductPageState.error;
          });
        }
      } else {
        setState(() {
          _pageState = ProductPageState.error;
        });
      }
    } catch (error) {
      setState(() {
        _pageState = ProductPageState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.title ?? 'Loading...'),
        backgroundColor: Color(0xFFA52502),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_pageState) {
      case ProductPageState.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case ProductPageState.success:
        return Padding(
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
                'R\$ ${_product?.price.toStringAsFixed(2) ?? ''}',
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
        );
      case ProductPageState.error:
        return Center(
          child: Text('Erro ao carregar o produto'),
        );
      default:
        return Container();
    }
  }

  void addToCart(Product product, int quantity) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          "userId": widget.userId,
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
