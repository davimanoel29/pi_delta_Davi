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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 16.0),
              Center(
                child: Image.network(
                  _product?.image ?? '',
                  height: 300.0,
                  width: 300.0,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _product?.title ?? '',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      _product?.category ?? '',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'R\$ ${_product?.price.toStringAsFixed(2) ?? ''}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      _product?.description ?? '',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        addToCart(_product!, 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA52502),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      child: Text(
                        'Adicionar ao Carrinho',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
    // Primeiro, faça uma solicitação para obter os itens do carrinho do usuário
    final cartResponse = await http.get(
      Uri.parse('http://localhost:3000/cart?userId=${widget.userId}'),
    );

    if (cartResponse.statusCode == 200) {
      final cartItems = jsonDecode(cartResponse.body) as List<dynamic>;

      // Verifique se o produto já está no carrinho
      bool isProductInCart =
          cartItems.any((item) => item['idProduct'] == product.id);

      if (isProductInCart) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto já está no carrinho')),
        );
        return; // Retorna imediatamente se o produto já estiver no carrinho
      }
    }

    // Se o produto não estiver no carrinho, faça a solicitação para adicioná-lo
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
