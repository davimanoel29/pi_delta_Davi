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
    final response = await http.get(Uri.parse('http://localhost:3000/cart?userId=${widget.userId}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _cartItems = data;
      });
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> _finishPurchase() async {
    if (_cartItems.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Não é possível finalizar a compra. O carrinho está vazio.'),
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

    List<Map<String, dynamic>> saleProducts = [];
    for (var item in _cartItems) {
      saleProducts.add({
        'idproduct': item['idProduct'],
        'title': item['title'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    Map<String, dynamic> purchaseData = {
      'userId': int.parse(widget.userId),
      'date': DateTime.now().toIso8601String(),
      'total': _calculateTotalPrice(),
      'saleproducts': saleProducts,
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/sale'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(purchaseData),
    );

    if (response.statusCode == 201) {
      for (var item in _cartItems) {
        final deleteResponse = await http.delete(Uri.parse('http://localhost:3000/cart/${item['id']}/?userId=${item['userId']}'));
        if (deleteResponse.statusCode != 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erro'),
                content: Text('Ocorreu um erro ao remover um produto do carrinho. Por favor, tente novamente.'),
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

      setState(() {
        _cartItems.clear();
      });

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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Ocorreu um erro ao finalizar a compra. Por favor, tente novamente.'),
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
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                    onPressed: () => _decreaseQuantity(cartItem),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => _increaseQuantity(cartItem),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: () => _removeCartItem(cartItem),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1C8394),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 8.0),
                                    Text('Remover'),
                                  ],
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
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: R\$ $total',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
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

  void _removeCartItem(Map<String, dynamic> cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remover Item'),
          content: Text('Tem certeza de que deseja remover este item do carrinho?'),
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
                final response = await http.delete(Uri.parse('http://localhost:3000/cart/${cartItem['id']}/?userId=${cartItem['userId']}'));
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
                        content: Text('Ocorreu um erro ao remover o item do carrinho. Por favor, tente novamente.'),
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


