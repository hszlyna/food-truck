import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class EditBookingPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onUpdate;

  const EditBookingPage({
    required this.booking,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<DropdownMenuItem<String>> _dropdownItems = [
    DropdownMenuItem(value: 'Buffet', child: Text('Buffet')),
    DropdownMenuItem(value: 'Food Stalls', child: Text('Food Stalls')),
    DropdownMenuItem(value: 'Takeaway', child: Text('Takeaway')),
  ];

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Dummy cart data
  List<Map<String, dynamic>> cart = [
    {
      'foodTruck': 'Da Grill Mastas',
      'package': "Grill Master's Feast",
      'price': 45.00,
      'quantity': 1,
    },
    {
      'foodTruck': 'Spice Caravan',
      'package': "Indian Spice Sensation",
      'price': 34.00,
      'quantity': 2,
    },
  ];

  double get _totalPrice {
    double total = 0;
    for (var item in cart) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _initEventTime(); // Initialize start/end time
  }

  void _initEventTime() {
    final eventTimeStr = widget.booking['eventtime']; // e.g., "13:00 - 18:00"
    if (eventTimeStr != null && eventTimeStr.contains(" - ")) {
      try {
        final parts = eventTimeStr.split(" - ");
        final start = DateFormat.Hm().parse(parts[0].trim());
        final end = DateFormat.Hm().parse(parts[1].trim());
        _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
        _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
      } catch (_) {
        _startTime = TimeOfDay(hour: 13, minute: 0);
        _endTime = TimeOfDay(hour: 18, minute: 0);
      }
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? TimeOfDay(hour: 13, minute: 0))
        : (_endTime ?? TimeOfDay(hour: 18, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  String get _formattedEventTime {
    final startStr = _startTime?.format(context) ?? "13:00";
    final endStr = _endTime?.format(context) ?? "18:00";
    return "$startStr - $endStr";
  }

  Future<void> _updateBooking() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      final updatedBooking = {
        'book_date': DateFormat('yyyy-MM-dd').format(values['booking_date']),
        'booktime': DateFormat('HH:mm:ss').format(values['booking_date']),
        'eventdate': values['event_date_range']?.start.toIso8601String(),
        'eventtime': _formattedEventTime,
        'foodtrucktype': values['food_sell_types'],
        'numberofdays': widget.booking['numberofdays'],
      };

      await DatabaseHelper.instance.updateBooking(
        widget.booking['bookid'],
        updatedBooking,
      );

      _showSnackBar(message: 'Booking updated successfully!', isError: false);

      widget.onUpdate();
      Navigator.pop(context);
    }
  }

  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addDummyPackage() {
    setState(() {
      cart.add({
        'foodTruck': 'Sweet Treat Wheels',
        'package': "Dessert Lover's Dream",
        'price': 25.00,
        'quantity': 1,
      });
    });
  }

  void _updateQuantity(int index, bool increase) {
    setState(() {
      if (increase) {
        cart[index]['quantity']++;
      } else {
        if (cart[index]['quantity'] > 1) {
          cart[index]['quantity']--;
        } else {
          cart.removeAt(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Booking',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(),
            SizedBox(height: 24),
            _buildCartSection(),
            SizedBox(height: 32),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'booking_date': DateTime.parse(widget.booking['book_date']),
            'event_date_range': DateTimeRange(
              start: DateTime.parse(widget.booking['eventdate']),
              end: DateTime.parse(widget.booking['eventdate'])
                  .add(Duration(days: widget.booking['numberofdays'])),
            ),
            'food_sell_types': widget.booking['foodtrucktype'],
          },
          child: Column(
            children: [
              _buildDateTimePicker(),
              SizedBox(height: 16),
              _buildDateRangePicker(),
              SizedBox(height: 16),
              _buildTimeInput(),
              SizedBox(height: 16),
              _buildDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return FormBuilderDateTimePicker(
      name: 'booking_date',
      decoration: InputDecoration(
        labelText: 'Booking Date',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      firstDate: DateTime.now(),
      format: DateFormat('dd/MM/yyyy hh:mm aaa'),
      validator: FormBuilderValidators.required(
        errorText: 'Please select a booking date',
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return FormBuilderDateRangePicker(
      name: 'event_date_range',
      decoration: InputDecoration(
        labelText: 'Event Start & End Date',
        prefixIcon: Icon(Icons.date_range, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      format: DateFormat('dd/MM/yyyy'),
      validator: FormBuilderValidators.required(
        errorText: 'Please select event dates',
      ),
    );
  }

  Widget _buildTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Time',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(isStart: true),
                child: Text(
                  _startTime != null
                      ? _startTime!.format(context)
                      : "Start Time",
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(isStart: false),
                child: Text(
                  _endTime != null ? _endTime!.format(context) : "End Time",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return FormBuilderDropdown(
      name: 'food_sell_types',
      items: _dropdownItems,
      decoration: InputDecoration(
        labelText: 'Select an Option',
        prefixIcon: Icon(Icons.fastfood, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please select a food type',
      ),
    );
  }

  Widget _buildCartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Packages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addDummyPackage,
              icon: Icon(Icons.add, size: 20),
              label: Text('Add Package'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (cart.isEmpty)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Text(
                'No packages selected',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          Column(
            children: [
              ...cart.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildCartItem(item, index);
              }),
              SizedBox(height: 16),
              _buildTotalPrice(),
            ],
          ),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item['foodTruck'],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['package'],
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'RM${item['price'].toStringAsFixed(2)} each',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 18),
                color: Colors.red[600],
                onPressed: () => _updateQuantity(index, false),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item['quantity'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 18),
                color: Colors.green[600],
                onPressed: () => _updateQuantity(index, true),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'RM${_totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Update Booking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
