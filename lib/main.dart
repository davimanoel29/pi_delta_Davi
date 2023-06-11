import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'product_page.dart';
import 'login.dart';
import 'cart.dart';
import 'information.dart';
import 'category.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final Color _iconColor = Colors.white;
  List<Product> _products = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSidebarOpen = false;
  late AnimationController _animationController;
  late Animation<double> _sidebarAnimation;
  List<String> _categories = [];
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _sidebarAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/categories'));
    if (response.statusCode == 200) {
      setState(() {
        _categories = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFA52502),
        leading: IconButton(
          icon: Icon(Icons.menu, color: _iconColor),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
              if (_isSidebarOpen) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
        ),
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
      body: Stack(
        children: [
          Column(
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
                                                                  Image.network(
                                      product.image, // URL da imagem
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.contain, // Define o modo de exibição da imagem
                                    ),
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
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
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              final slide = MediaQuery.of(context).size.width * 0.8 * _sidebarAnimation.value;
              return Stack(
                children: [
                  if (_isSidebarOpen)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSidebarOpen = false;
                          _animationController.reverse();
                        });
                      },
                      child: Container(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  Transform(
                    transform: Matrix4.translationValues(slide, 0, 0),
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: ListView.builder(
                        itemCount: _categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = '';
                                  _isSidebarOpen = false;
                                  _animationController.reverse();
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryPage(category: _selectedCategory),
                                  ),
                                );
                              },
                            );
                          }
                          final category = _categories[index - 1];
                          return ListTile(
                            title: Text(category),
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _isSidebarOpen = false;
                                _animationController.reverse();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryPage(category: category),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProductPage(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(productId: product.id),
      ),
    );
  }
}
