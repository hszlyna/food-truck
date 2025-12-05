import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class EditBookingPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onUpdate;

  EditBookingPage({required this.booking, required this.onUpdate});

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<DropdownMenuItem<String>> _ddItm = [
    DropdownMenuItem(value: 'Buffet', child: Text('Buffet')),
    DropdownMenuItem(value: 'Food Stalls', child: Text('Food Stalls')),
    DropdownMenuItem(value: 'Takeaway', child: Text('Takeaway')),
  ];

  Future<void> _updateBooking() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      // Split the event_time into start and end times
      final eventTimeParts = values['event_time']?.split(' - ') ?? [];
      if (eventTimeParts.length != 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid time format. Please use HH:mm - HH:mm.',
              style: TextStyle(color: Colors.white), // White text
            ),
            backgroundColor: Colors.red, // Red background for error
          ),
        );
        return;
      }

      final updatedBooking = {
        'book_date': DateFormat('yyyy-MM-dd').format(values['booking_date']),
        'booktime': DateFormat('HH:mm:ss').format(values['booking_date']),
        'eventdate': values['event_date_range']?.start.toIso8601String(),
        'eventtime': values['event_time'], // Use combined time
        'foodtrucktype': values['food_sell_types'],
        'numberofdays': widget.booking['numberofdays'], // Keep unchanged
      };

      await DatabaseHelper.instance.updateBooking(
        widget.booking['bookid'],
        updatedBooking,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking updated successfully!',
            style: TextStyle(color: Colors.white), // White text
          ),
          backgroundColor: Colors.green, // Green background for success
        ),
      );

      widget.onUpdate(); // Refresh the booking list
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Booking')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            initialValue: {
              'booking_date': DateTime.parse(widget.booking['book_date']),
              'event_date_range': DateTimeRange(
                start: DateTime.parse(widget.booking['eventdate']),
                end: DateTime.parse(widget.booking['eventdate'])
                    .add(Duration(days: widget.booking['numberofdays'])),
              ),
              'event_time': widget.booking['eventtime'], // Use combined time
              'food_sell_types': widget.booking['foodtrucktype'],
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'booking_date',
                  decoration: InputDecoration(
                    labelText: 'Booking Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  firstDate: DateTime.now(),
                  format: DateFormat('dd/MM/yyyy hh:mm aaa'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                SizedBox(height: 16),

                FormBuilderDateRangePicker(
                  name: 'event_date_range',
                  decoration: InputDecoration(
                    labelText: 'Event Start & End Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  format: DateFormat('dd/MM/yyyy'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'event_time',
                  decoration: InputDecoration(
                    labelText: 'Event Time (HH:mm - HH:mm)',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  initialValue: widget.booking['eventtime'],
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

                FormBuilderDropdown(
                  name: 'food_sell_types',
                  items: _ddItm,
                  decoration: InputDecoration(
                    labelText: 'Select an Option',
                    prefixIcon: Icon(Icons.fastfood),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _updateBooking,
                  child: Text('Update Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
