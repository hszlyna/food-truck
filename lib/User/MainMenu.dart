import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'userProv.dart';
import 'UserProfile.dart';
import 'ViewBookings.dart';
import '../FoodTruck/Forma/_Forma.dart'; // Import the Forma class
import 'login.dart';

class MainMenuPage extends StatelessWidget {
  void _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel logout
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm logout
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      // Clear userId from the Provider
      Provider.of<UserProvider>(context, listen: false).clearUserId();

      // Navigate to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    // Show the logout confirmation dialog
    bool? confirmExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Stay on the page
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Allow exit
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmExit == true) {
      // Perform logout if the user confirms
      _logout(context);
    }

    // Return false to prevent the default back navigation
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    return WillPopScope(
      onWillPop: () => _onWillPop(context), // Handle back button press
      child: Scaffold(
        appBar: AppBar(title: Text('Main Menu')),
        body: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(16.0),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            // Card for "Start Booking"
            Card(
              color: Colors.blue[100], // Set a background color
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Forma()), // Navigate to _Forma
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, size: 40, color: Colors.blue), // Icon
                      SizedBox(height: 10),
                      Text('Start Booking', style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ),

            // Card for "User Profile"
            Card(
              color: Colors.green[100],
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(userId: userId!),
                    ),
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle, size: 40, color: Colors.green), // Icon
                      SizedBox(height: 10),
                      Text('User Profile', style: TextStyle(fontSize: 16, color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ),

            // Card for "View Bookings"
            Card(
              color: Colors.orange[100],
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewBookingsPage(userId: userId!),
                    ),
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark, size: 40, color: Colors.orange), // Icon
                      SizedBox(height: 10),
                      Text('View Bookings', style: TextStyle(fontSize: 16, color: Colors.orange)),
                    ],
                  ),
                ),
              ),
            ),

            // Card for "Logout"
            Card(
              color: Colors.red[100],
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () => _logout(context),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 40, color: Colors.red), // Icon
                      SizedBox(height: 10),
                      Text('Logout', style: TextStyle(fontSize: 16, color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
