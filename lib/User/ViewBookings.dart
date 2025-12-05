import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import 'EditBooking.dart';

class ViewBookingsPage extends StatefulWidget {
  final int userId;

  ViewBookingsPage({required this.userId});

  @override
  _ViewBookingsPageState createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> {
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await DatabaseHelper.instance.getBookings(widget.userId);
    setState(() {
      _bookings = bookings;
    });
  }

  Future<void> _deleteBooking(int bookId) async {
    bool confirm = await _showDeleteConfirmationDialog();
    if (confirm) {
      await DatabaseHelper.instance.deleteBooking(bookId);
      _loadBookings(); // Refresh the list
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Booking'),
            content: Text('Request to delete booking?'),
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

  void _editBooking(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookingPage(
          booking: booking,
          onUpdate: _loadBookings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Bookings')),
      body: _bookings.isEmpty
          ? Center(child: Text('No bookings found'))
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
                        Text('Food Truck Type: ${booking['foodtrucktype']}'),
                        Text('Booking Date: ${booking['book_date']}'),
                        Text('Booking Time: ${booking['booktime']}'),
                        Text('Event Date: ${booking['eventdate']}'),
                        Text('Event Time: ${booking['eventtime']}'),
                        Text('Number of Days: ${booking['numberofdays']}'),
                        Text(
                            'Price: RM${NumberFormat('###0.00').format(booking['price'])}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteBooking(booking['bookid']),
                    ),
                    onTap: () => _editBooking(booking),
                  ),
                );
              },
            ),
    );
  }
}
