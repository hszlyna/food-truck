import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AdminManagePackage extends StatefulWidget {
  @override
  _AdminManagePackageState createState() => _AdminManagePackageState();
}

class _AdminManagePackageState extends State<AdminManagePackage> {
  List<Map<String, dynamic>> _trucks = [];

  @override
  void initState() {
    super.initState();
    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    final list = await DatabaseHelper.instance.getFoodTrucks();
    setState(() {
      _trucks = list;
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Food Truck"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Food Truck Name"),
            ),
            TextField(
              controller: imageController,
              decoration: InputDecoration(
                labelText: "Image URL (optional)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Add"),
            onPressed: () async {
              await DatabaseHelper.instance.addFoodTruck(
                nameController.text,
                imageController.text,
              );
              Navigator.pop(context);
              _loadTrucks();
            },
          ),
        ],
      ),
    );
  }

  void _deleteTruck(int id) async {
    await DatabaseHelper.instance.deleteFoodTruck(id);
    _loadTrucks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Food Trucks"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _trucks.isEmpty
          ? Center(child: Text("No food trucks added yet."))
          : GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _trucks.length,
              itemBuilder: (context, index) {
                final truck = _trucks[index];

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black12,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: truck['image'] != null &&
                                      truck['image'].toString().isNotEmpty
                                  ? Image.network(
                                      truck['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              truck['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delete button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white, size: 18),
                          onPressed: () => _deleteTruck(truck['id']),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
