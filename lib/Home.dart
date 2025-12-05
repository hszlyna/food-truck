import 'package:flutter/material.dart';
import 'User/login.dart'; // User login page
import 'Admin/admin_login.dart'; // Admin login page

class Home extends StatelessWidget {
  // Food Truck Package Data
  final List<Map<String, dynamic>> foodTrucks = [
    {
      'name': 'Da Grill Mastas',
      'packages': {
        'Grill Master\'s Feast': [
          {'title': 'Juicy Grilled Ribeye Steak', 'desc': 'Delicious burger', 'price': 25.00},
          {'title': 'Grilled Chicken Skewers', 'desc': 'Crispy fries', 'price': 12.00},
          {'title': 'Baked Potato with Cheese and Beef', 'desc': 'Hearty side dish', 'price': 5.00},
          {'title': 'Seasonal Vegetables', 'desc': 'Fresh and healthy', 'price': 3.00},
        ],
        'Classic Grill Night': [
          {'title': 'Grilled Lamb Chops', 'desc': 'Juicy lamb chops', 'price': 20.00},
          {'title': 'Grilled Corn on the Cob', 'desc': 'Sweet and savory', 'price': 3.00},
          {'title': 'Garlic Bread', 'desc': 'Buttery and garlicky', 'price': 2.00},
          {'title': 'Caesar Salad', 'desc': 'Classic salad', 'price': 5.00},
        ],
      },
    },
    {
      'name': 'Spice Caravan',
      'packages': {
        'Indian Spice Sensation': [
          {'title': 'Butter Chicken with Naan', 'desc': 'Creamy and flavorful', 'price': 15.00},
          {'title': 'Vegetable Samosas', 'desc': 'Crispy and savory', 'price': 5.00},
          {'title': 'Chana Masala with Rice', 'desc': 'Hearty and spicy', 'price': 10.00},
          {'title': 'Mango Lassi', 'desc': 'Refreshing drink', 'price': 4.00},
        ],
        'Spicy Thai Delight': [
          {'title': 'Pad Thai with Shrimp', 'desc': 'Classic Thai dish', 'price': 12.00},
          {'title': 'Tom Yum Soup', 'desc': 'Fresh and tangy', 'price': 8.00},
          {'title': 'Spring Rolls', 'desc': 'Crispy and flavorful', 'price': 4.00},
          {'title': 'Thai Iced Tea', 'desc': 'Sweet and refreshing', 'price': 3.00},
        ],
      },
    },
    {
      'name': 'Sweet Treat Wheels',
      'packages': {
        'Dessert Lover\'s Dream': [
          {'title': 'Chocolate Lava Cake', 'desc': 'Indulgent dessert', 'price': 8.00},
          {'title': 'Vanilla Bean Ice Cream', 'desc': 'Classic ice cream', 'price': 4.00},
          {'title': 'Caramel Apple Tart', 'desc': 'Sweet and tart', 'price': 6.00},
          {'title': 'Hot Chocolate', 'desc': 'Warm and comforting', 'price': 5.00},
        ],
        'Mini Dessert Sampler': [
          {'title': 'Assorted Mini Cupcakes', 'desc': 'Colorful and tasty', 'price': 8.00},
          {'title': 'Mini Cheesecake', 'desc': 'Creamy and delicious', 'price': 6.00},
          {'title': 'Macarons', 'desc': 'French delicacy', 'price': 10.00},
          {'title': 'Fruit Tarts', 'desc': 'Fresh and fruity', 'price': 7.00},
        ],
      },
    },
    {
      'name': 'The Wok Working',
      'packages': {
        'Asian Fusion Feast': [
          {'title': 'Stir-Fried Noodles with Chicken and Vegetables', 'desc': 'Flavorful and healthy', 'price': 12.00},
          {'title': 'Crispy Spring Rolls', 'desc': 'Crispy and savory', 'price': 4.00},
          {'title': 'Edamame', 'desc': 'Healthy snack', 'price': 3.00},
          {'title': 'Miso Soup', 'desc': 'Warm and comforting', 'price': 2.00},
        ],
        'Spicy Noodle Sensation': [
          {'title': 'Pad Thai with Tofu', 'desc': 'Vegetarian delight', 'price': 10.00},
          {'title': 'Spicy Ramen', 'desc': 'Flavorful and spicy', 'price': 8.00},
          {'title': 'Gyoza', 'desc': 'Dumplings', 'price': 6.00},
          {'title': 'Green Tea', 'desc': 'Refreshing drink', 'price': 2.00},
        ],
      },
    },

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🚚 FDB'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple[100], // Light purple AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Section
            Text(
              'Welcome to the Food Truck Booking App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Login Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminLoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Purple button background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12), // Vertical padding
                    ),
                    child: Text(
                      'Admin Login',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent, // Purple button background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12), // Vertical padding
                    ),
                    child: Text(
                      'User Login',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Image.network(
              'https://t4.ftcdn.net/jpg/03/90/68/13/360_F_390681352_BsFsBsRqL4HzilaQDe7cxeq1pl7lreSs.jpg',
              height: 200, width: double.infinity, fit: BoxFit.cover,
            ),
            SizedBox(height: 20),

            // Food Truck Packages List
            Expanded(
              child: ListView.builder(
                itemCount: foodTrucks.length,
                itemBuilder: (context, index) {
                  final foodTruck = foodTrucks[index];
                  return _buildFoodTruckCard(foodTruck);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a Food Truck Card
  Widget _buildFoodTruckCard(Map<String, dynamic> foodTruck) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(foodTruck['name'], style: TextStyle(fontWeight: FontWeight.bold)),
        children: foodTruck['packages'].entries.map<Widget>((entry) {
          final packageName = entry.key;
          final menuItems = entry.value as List<Map<String, dynamic>>;
          return _buildPackageTile(packageName, menuItems);
        }).toList(),
      ),
    );
  }

  // Build a Package Tile
  Widget _buildPackageTile(String packageName, List<Map<String, dynamic>> menuItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            packageName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...menuItems.map((item) => _buildMenuItem(item)).toList(),
        ],
      ),
    );
  }

  // Build a Menu Item
  Widget _buildMenuItem(Map<String, dynamic> menuItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '🔥 ${menuItem['title']} - ${menuItem['desc']}',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
