import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:flutter_cur_prj_day3_4_5_6/api/api_client.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiClient apiClient = ApiClient();
  
  int _currentIndex = 0;
  

  List<String> categories = ["All Products"]; 
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchCategories(); 
  }

  
  void fetchCategories() async {
    try {
      var res = await apiClient.getData('/products/categories');
      if (res.statusCode == 200) {
        List<String> fetchedCategories = [];
        for (var item in res.data) {
          if (item is String) {
            fetchedCategories.add(item);
          } else if (item is Map) {
            fetchedCategories.add(item['slug'] ?? item['name'] ?? '');
          }
        }
        setState(() {
          categories.addAll(fetchedCategories);
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return isLoadingCategories
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          )
        : DefaultTabController(
            length: categories.length, 
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Products"),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                
                bottom: _currentIndex == 0
                    ? TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: categories.map((cat) => Tab(text: cat.toUpperCase())).toList(),
                      )
                    : null,
              ),
              drawer: _buildDrawer(), 
              body: _currentIndex == 0
                  ? TabBarView(
                      children: categories.map((cat) => ProductListTab(category: cat)).toList(),
                    )
                  : _currentIndex == 1
                      ? const Center(child: Text("Search Content Area", style: TextStyle(fontSize: 24)))
                      : const Center(child: Text("Profile Content Area", style: TextStyle(fontSize: 24))),
              
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                selectedItemColor: Colors.deepOrange,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
                ],
              ),
            ),
          );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepOrange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.deepOrange),
                ),
                SizedBox(height: 16),
                Text(
                  "Welcome User!",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductListTab extends StatefulWidget {
  final String category;
  const ProductListTab({super.key, required this.category});

  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  ApiClient apiClient = ApiClient();
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
       String endpoint = widget.category == "All Products"
          ? '/products'
          : '/products/category/${widget.category}';

      var res = await apiClient.getData(endpoint);
      if (res.statusCode == 200) {
        setState(() {
          products = res.data['products'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching products for ${widget.category}: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
    }

    if (products.isEmpty) {
      return const Center(child: Text("No products found."));
    }
  
    
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, 
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product['thumbnail'], 
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "\$${product['price']}",
                      style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
