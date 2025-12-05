import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'db/database_helper.dart';

class BookingPage extends StatefulWidget {
  final int userId;

  BookingPage({required this.userId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Variable to hold the calculated number of days
  int? numberOfDays;

  // Function to calculate the number of days based on the date range
  void _calculateNumberOfDays(DateTimeRange? dateRange) {
    if (dateRange != null) {
      setState(() {
        numberOfDays = dateRange.end.difference(dateRange.start).inDays + 1;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      // Get Start and End Event Times
      String startEventTimeStr = DateFormat('HH:mm').format(values['start_event_time']);
      String endEventTimeStr = DateFormat('HH:mm').format(values['end_event_time']);

      // Combine Start and End Times into a single string
      String eventTimeStr = '$startEventTimeStr - $endEventTimeStr';

      // Add the logged-in user's ID to the booking data
      final booking = {
        'userid': widget.userId,
        'book_date': DateFormat('yyyy-MM-dd').format(values['booking_date_time']),
        'booktime': DateFormat('HH:mm:ss').format(values['booking_date_time']),
        'eventdate': values['eventdate']?.start.toIso8601String() ?? '', // Start of the date range
        'eventtime': eventTimeStr,  // Combined start and end time
        'foodtrucktype': values['foodtrucktype'],
        'numberofdays': numberOfDays,
        'price': values['price'],
      };

      try {
        // Insert booking into the database
        int result = await DatabaseHelper.instance.addBooking(booking);

        // Show success or failure message
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit booking.')),
          );
        }

        // Navigate back after submission
        Navigator.pop(context);
      } catch (e) {
        print('Error inserting booking: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      print('Form is not valid.');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book a Food Truck')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              // Combined Booking Date and Time Picker
              FormBuilderDateTimePicker(
                name: 'booking_date_time',
                decoration: InputDecoration(
                  labelText: 'Booking Date & Time',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blueGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                firstDate: DateTime.now(),
                format: DateFormat('dd/MM/yyyy hh:mm aaa'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),

              // Event Date (Date Range Picker)
              FormBuilderDateRangePicker(
                name: 'eventdate',
                decoration: InputDecoration(labelText: 'Event Date'),
                validator: FormBuilderValidators.required(),
                onChanged: _calculateNumberOfDays,
                firstDate: DateTime.now(), // Set first date to today
                lastDate: DateTime(2026, 12, 31), // Set last date to the end of 2026
              ),

              // Event Time
              FormBuilderDateTimePicker(
                name: 'start_event_time',
                decoration: InputDecoration(
                  labelText: 'Start Event Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                inputType: InputType.time,
                validator: FormBuilderValidators.required(),
                format: DateFormat('HH:mm'),
              ),

              FormBuilderDateTimePicker(
                name: 'end_event_time',
                decoration: InputDecoration(
                  labelText: 'End Event Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                inputType: InputType.time,
                validator: FormBuilderValidators.required(),
                format: DateFormat('HH:mm'),
              ),

              // Food Truck Type
              FormBuilderTextField(
                name: 'foodtrucktype',
                decoration: InputDecoration(labelText: 'Food Truck Type'),
                validator: FormBuilderValidators.required(),
              ),

              // Price
              FormBuilderTextField(
                name: 'price',
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.min(0),
                ]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
