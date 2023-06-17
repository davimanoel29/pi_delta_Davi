import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _cartItems = [];

Future<void> _fetchCartItems() async {
  final response = await http.get(Uri.parse('http://localhost:3000/cart'));
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
  final response = await http.post(
    Uri.parse('http://localhost:3000/sale'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(_cartItems),
  );

  if (response.statusCode == 201) {
    // Finalizar a compra com sucesso, agora vamos limpar o carrinho
    final deleteResponse = await http.delete(Uri.parse('http://localhost:3000/cart'));
    if (deleteResponse.statusCode == 200) {
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

      setState(() {
        _cartItems.clear();
      });
    } else {
      // Falha ao limpar o carrinho
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
  } else {
    // Falha ao finalizar a compra
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text('Ocorreu um erro ao finalizar a compra.'),
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

    setState(() {
      _cartItems.clear();
    });
  }
}


  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    double total = 0.0;
    for (var item in _cartItems) {
      total += item['price'] * item['quantity'];
    }

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
                        if (cartItem['image'] !=
                            null) 
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
                                  backgroundColor: Color(int.parse('0xFF1C8394')),
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
            child: Text(
              'Total: R\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _finishPurchase,
                style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA52502),
              ),
              child: Text('Finalizar Compra'),
            ),
          ),
        ],
      ),
    );
  }

  void _decreaseQuantity(dynamic cartItem) {
    setState(() {
      if (cartItem['quantity'] > 1) {
        cartItem['quantity']--;
      }
    });
  }

  void _increaseQuantity(dynamic cartItem) {
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
              final url = Uri.parse('http://localhost:3000/cart/${cartItem['id']}/?idProduct=${cartItem['idProduct']}');
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
                      content: Text('Ocorreu um erro ao remover o produto do carrinho. Por favor, tente novamente.'),
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
