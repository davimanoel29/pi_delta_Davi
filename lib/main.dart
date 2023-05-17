import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'product_page.dart';
import 'login.dart';
import 'cart.dart';
import 'information.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PI DELTA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color _iconColor = Colors.white;
  List<Product> _products = [];
  TextEditingController _searchController = TextEditingController();

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        _products = List<Product>.from(json.decode(response.body).map((product) => Product.fromJson(product)));
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home',
        textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFA52502), 
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: _iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: _iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info, color: _iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InformationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {}); // Atualizar a exibição da lista com base no valor digitado
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar produtos',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Center(
            child: Text(
              'Produtos',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                // Verificar se o título ou a descrição do produto contêm o valor de pesquisa
                if (_searchController.text.isNotEmpty &&
                    !product.title.toLowerCase().contains(_searchController.text.toLowerCase()) &&
                    !product.description.toLowerCase().contains(_searchController.text.toLowerCase())) {
                  return SizedBox.shrink(); // Oculta o item da lista se não corresponder à pesquisa
                }
                return GestureDetector(
                  onTap: () => _showProductPage(context, product),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            product.title,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            product.description,
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'R\$ ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProductPage(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductPage(product)),
    );
  }
}
