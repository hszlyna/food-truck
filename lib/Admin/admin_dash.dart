import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../db/database_helper.dart';
import 'EditUser.dart';
import 'admin_login.dart';

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadBookings();
  }

  // Fetch all registered users
  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.getUsers();
    setState(() {
      _users = users;
    });
  }

  // Fetch all bookings
  Future<void> _loadBookings() async {
    final bookings = await DatabaseHelper.instance.getAllBookings();
    setState(() {
      _bookings = bookings;
    });
  }

  // Delete a user
  Future<void> _deleteUser(int userId) async {
    bool confirm = await _showDeleteConfirmationDialog('user');
    if (confirm) {
      await DatabaseHelper.instance.adminDeleteUser(userId);
      _loadUsers(); // Refresh the users list
    }
  }

  // Delete a booking
  Future<void> _deleteBooking(int bookingId) async {
    bool confirm = await _showDeleteConfirmationDialog('booking');
    if (confirm) {
      await DatabaseHelper.instance.deleteBooking(bookingId);
      _loadBookings(); // Refresh the bookings list
    }
  }

  // Show a confirmation dialog for deletion
  Future<bool> _showDeleteConfirmationDialog(String itemType) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemType'),
        content: Text('Are you sure you want to delete this $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ??
        false;
  }

  // Logout and navigate back to the admin login page
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginPage()),
          (route) => false,
    );
  }

  void _showEditBookingDialog(BuildContext context, Map<String, dynamic> booking) {
    final _fbKey = GlobalKey<FormBuilderState>();

    // Initialize controllers
    final _foodTruckTypeController = TextEditingController(text: booking['foodtrucktype']);
    final _eventTimeController = TextEditingController(text: booking['eventtime']);
    final _priceController = TextEditingController(text: booking['price'].toString());

    // Initial values for date pickers
    DateTime? _bookingDate = DateTime.tryParse(booking['book_date']);
    DateTimeRange? _eventDateRange = DateTimeRange(
      start: DateTime.parse(booking['eventdate']),
      end: DateTime.parse(booking['eventdate']).add(Duration(days: booking['numberofdays'] - 1)),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Booking'),
          content: SingleChildScrollView(
            child: FormBuilder(
              key: _fbKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Booking Date and Time Picker (Custom Picker with FormBuilder)
                  FormBuilderDateTimePicker(
                    name: 'booking_date',
                    initialValue: _bookingDate,
                    decoration: InputDecoration(
                      labelText: 'Booking Date & Time',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    inputType: InputType.both, // For both date and time
                    format: DateFormat('yyyy-MM-dd HH:mm:ss'),
                    onChanged: (val) {
                      _bookingDate = val;
                    },
                    validator: FormBuilderValidators.required(errorText: 'Please select a booking date and time'),
                  ),
                  SizedBox(height: 16),

                  // Event Date Range Picker (Custom Picker with FormBuilder)
                  FormBuilderTextField(
                    name: 'event_date_range',
                    controller: TextEditingController(
                      text: _eventDateRange != null
                          ? '${DateFormat('yyyy-MM-dd').format(_eventDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_eventDateRange!.end)}'
                          : '',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Event Date Range',
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        initialDateRange: _eventDateRange,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (dateRange != null) {
                        _eventDateRange = dateRange;
                        _fbKey.currentState!.fields['event_date_range']!.didChange(
                            '${DateFormat('yyyy-MM-dd').format(dateRange.start)} - ${DateFormat('yyyy-MM-dd').format(dateRange.end)}');
                      }
                    },
                    validator: FormBuilderValidators.required(errorText: 'Please select an event date range'),
                  ),
                  SizedBox(height: 16),

                  // Event Time (with validation for the time format)
                  FormBuilderTextField(
                    name: 'event_time',
                    controller: _eventTimeController,
                    decoration: InputDecoration(
                      labelText: 'Event Time (HH:mm - HH:mm)',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                          (value) {
                        final regex = RegExp(r'^\d{2}:\d{2} - \d{2}:\d{2}$');
                        if (value == null || !regex.hasMatch(value)) {
                          return 'Please enter a valid time range (e.g., 10:00 - 14:00)';
                        }
                        return null;
                      },
                    ]),
                  ),
                  SizedBox(height: 16),

                  // Food Truck Type
                  FormBuilderTextField(
                    name: 'food_truck_type',
                    controller: _foodTruckTypeController,
                    decoration: InputDecoration(labelText: 'Food Truck Type'),
                    validator: FormBuilderValidators.required(errorText: 'Please enter the food truck type'),
                  ),
                  SizedBox(height: 16),

                  // Price
                  FormBuilderTextField(
                    name: 'price',
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Please enter the price'),
                      FormBuilderValidators.numeric(errorText: 'Please enter a valid number')
                    ]),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () async {
                if (_fbKey.currentState!.validate()) {
                  // Prepare updated booking data
                  final updatedBooking = {
                    'book_date': _bookingDate != null ? DateFormat('yyyy-MM-dd').format(_bookingDate!) : '',
                    'booktime': _bookingDate != null ? DateFormat('HH:mm:ss').format(_bookingDate!) : '',
                    'eventdate': _eventDateRange?.start.toIso8601String(),
                    'eventtime': _eventTimeController.text.trim(),
                    'foodtrucktype': _foodTruckTypeController.text.trim(),
                    'numberofdays': _eventDateRange != null
                        ? _eventDateRange!.end.difference(_eventDateRange!.start).inDays + 1
                        : 0,
                    'price': double.parse(_priceController.text.trim()),
                  };

                  try {
                    // Update booking in the database
                    await DatabaseHelper.instance.updateBooking(
                      booking['bookid'],
                      updatedBooking,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking updated successfully!')),
                    );

                    // Refresh bookings and close the dialog
                    _loadBookings();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update booking: $e')),
                    );
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Users and Bookings
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Users'),
              Tab(icon: Icon(Icons.event), text: 'Bookings'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Registered Users
            _buildUsersTab(),

            // Tab 2: Bookings
            _buildBookingsTab(),
          ],
        ),
      ),
    );
  }

  // Build the Users Tab
  Widget _buildUsersTab() {
    return _users.isEmpty
        ? Center(child: Text('No registered users found.'))
        : ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Name: ${user['name']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UserID: ${user['userid']}'),
                Text('Email: ${user['email']}'),
                Text('Phone: ${user['phone']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(
                          user: user, // Pass user data to edit
                          onUpdate: _loadUsers, // Callback to refresh users list
                        ),
                      ),
                    );
                  },
                  tooltip: 'Edit User',
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteUser(user['userid']),
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build the Bookings Tab
  Widget _buildBookingsTab() {
    return _bookings.isEmpty
        ? Center(child: Text('No bookings found.'))
        : ListView.builder(
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Booking ID: ${booking['bookid']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UserID: ${booking['userid']}'),
                Text('Food Truck: ${booking['foodtrucktype']}'),
                Text('Booking Date: ${booking['book_date']}'),
                Text('Booking Time: ${booking['booktime']}'),
                Text('Event Date/Time: ${booking['eventdate']} ${booking['eventtime']}'),
                Text('Price: RM${NumberFormat('###0.00').format(booking['price'])}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditBookingDialog(context, booking);
                  },
                  tooltip: 'Edit Booking',
                ),

                // Delete button
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteBooking(booking['bookid']),
                  tooltip: 'Delete Booking',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
