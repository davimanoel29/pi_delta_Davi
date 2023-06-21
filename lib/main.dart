import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'product_page.dart';
import 'login.dart';
import 'cart.dart';
import 'information.dart';
import 'category.dart';
import 'auth.dart';

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
        primarySwatch: Colors.brown,
      ),
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Color _iconColor = Colors.white;
  List<Product> _products = [];
  List<Product> _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSidebarOpen = false;
  late AnimationController _animationController;
  late Animation<double> _sidebarAnimation;
  List<String> _categories = [];
  String _selectedCategory = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
    _fetchUserId();

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
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        _products = List<Product>.from(json
            .decode(response.body)
            .map((product) => Product.fromJson(product)));
      });
    } else {
      throw Exception('Falha ao carregar os produtos');
    }
  }

  Future<void> _fetchCategories() async {
    final response = await http
        .get(Uri.parse('https://fakestoreapi.com/products/categories'));
    if (response.statusCode == 200) {
      setState(() {
        _categories = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Falha ao carregar as categorias');
    }
  }

  Future<void> _fetchUserId() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/users'));
    if (response.statusCode == 200) {
      final users = json.decode(response.body);
      final user = users.firstWhere(
          (user) => user['username'] == widget.username,
          orElse: () => null);
      if (user != null) {
        setState(() {
          _userId = user['id'].toString();
        });
      }
    } else {
      throw Exception('Falha ao carregar o ID do usuário');
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
            tooltip: widget.username,
            onPressed: () {
              // Check if the userId is available
              if (_userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AuthPage(userId: _userId!)),
                );
              } else {
                throw Exception('Falha ao carregar o ID do usuário');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: _iconColor),
            tooltip: 'Carrinho',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CartPage(userId: _userId!)));
            },
          ),
          IconButton(
            icon: Icon(Icons.info, color: _iconColor),
            tooltip: 'Informações',
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
                    setState(() {
                      _searchResults = _products
                          .where((product) =>
                              product.title
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              product.description
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    });
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _searchController.text.isNotEmpty
                      ? _searchResults.length
                      : _products.length,
                  itemBuilder: (context, index) {
                    final product = _searchController.text.isNotEmpty
                        ? _searchResults[index]
                        : _products[index];
                    return InkWell(
                      onTap: () => _showProductPage(context, product),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8.0),
                                ),
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'R\$ ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
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
            ],
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              final slide = MediaQuery.of(context).size.width *
                  0.8 *
                  _sidebarAnimation.value;
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
                      padding:
                          EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
                              },
                              title: Text(
                                'Categorias',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: _selectedCategory == ''
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }
                          final category = _categories[index - 1];
                          return Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
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
                                    builder: (context) => CategoryPage(
                                      category: category,
                                      userId: _userId!,
                                    ),
                                  ),
                                );
                              },
                            ),
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
          builder: (context) =>
              ProductPage(productId: product.id, userId: _userId!)),
    );
  }
}
