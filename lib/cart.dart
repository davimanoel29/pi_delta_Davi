import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  final String userId;

  CartPage({required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _cartItems = [];

  Future<void> _fetchCartItems() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/cart?userId=${widget.userId}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (var item in data) {
          final existingItem = _cartItems.firstWhere(
            (cartItem) => cartItem['idProduct'] == item['idProduct'],
            orElse: () => null,
          );
          if (existingItem != null) {
            existingItem['quantity']++;
          } else {
            _cartItems.add(item);
          }
        }
      });
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> _finishPurchase() async {
    if (_cartItems.isEmpty) {
      // Display an error dialog if the cart is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text(
                'Não é possível finalizar a compra. O carrinho está vazio.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Criar uma lista de produtos no formato esperado
    List<Map<String, dynamic>> saleProducts = [];
    for (var item in _cartItems) {
      saleProducts.add({
        'idproduct': item['idProduct'],
        'title': item['title'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    // Create the purchase data object
    Map<String, dynamic> purchaseData = {
      'userId': int.parse(widget.userId),
      'date': DateTime.now().toIso8601String(),
      'total': _calculateTotalPrice(),
      'saleproducts': saleProducts,
    };

    // Send the POST request to finalize the purchase
    final response = await http.post(
      Uri.parse('http://localhost:3000/sale'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(purchaseData),
    );

    if (response.statusCode == 201) {
      // Purchase successful, now delete each product from the cart
      for (var item in _cartItems) {
        final deleteResponse = await http.delete(Uri.parse(
            'http://localhost:3000/cart/${item['id']}/?userId=${item['userId']}'));
        if (deleteResponse.statusCode != 200) {
          // Display an error dialog if deleting a product fails
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erro'),
                content: Text(
                    'Ocorreu um erro ao remover um produto do carrinho. Por favor, tente novamente.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
      }

      // Clear the cart after successful purchase and deletion
      setState(() {
        _cartItems.clear();
      });

      // Display a success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Compra Finalizada'),
            content: Text('Sua compra foi finalizada com sucesso!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Display an error dialog if the purchase fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text(
                'Ocorreu um erro ao finalizar a compra. Por favor, tente novamente.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  double _calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var item in _cartItems) {
      totalPrice += item['price'] * item['quantity'];
    }
    return totalPrice;
  }

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    double total = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Carrinho'),
        backgroundColor: Color(0xFFA52502),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Itens do Carrinho',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = _cartItems[index];
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (cartItem['image'] != null)
                          Image.network(
                            cartItem['image'],
                            height: 100,
                            width: 100,
                          ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                cartItem['title'],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Preço: R\$${cartItem['price']}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Text(
                                    'Quantidade: ${cartItem['quantity']}',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  SizedBox(width: 8.0),
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () =>
                                        _decreaseQuantity(cartItem),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        _increaseQuantity(cartItem),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: () => _removeCartItem(cartItem),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(int.parse('0xFF1C8394')),
                                ),
                                child: Text('Remover'),
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
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Total: R\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _finishPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA52502),
                  ),
                  child: Text('Finalizar Compra'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _decreaseQuantity(Map<String, dynamic> cartItem) {
    if (cartItem['quantity'] > 1) {
      setState(() {
        cartItem['quantity']--;
      });
    }
  }

  void _increaseQuantity(Map<String, dynamic> cartItem) {
    setState(() {
      cartItem['quantity']++;
    });
  }

  void _removeCartItem(dynamic cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remover Produto'),
          content: Text('Deseja remover este produto do carrinho?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remover'),
              onPressed: () async {
                final url = Uri.parse(
                    'http://localhost:3000/cart/${cartItem['id']}/?idProduct=${cartItem['idProduct']}');
                final response = await http.delete(url);
                if (response.statusCode == 200) {
                  setState(() {
                    _cartItems.remove(cartItem);
                  });
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Erro'),
                        content: Text(
                            'Ocorreu um erro ao remover o produto do carrinho. Por favor, tente novamente.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
