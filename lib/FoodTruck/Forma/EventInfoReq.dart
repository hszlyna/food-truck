import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'FormaDat/_FormaPDat.dart';

class EventInfoReq extends StatefulWidget {
  const EventInfoReq({Key? k}) : super(key: k);

  @override
  EventInfoReqState createState() => EventInfoReqState();
}

class EventInfoReqState extends State<EventInfoReq> {
  final _fKey = GlobalKey<FormBuilderState>();
  final List<DropdownMenuItem<String>> _ddItm = [
    DropdownMenuItem(value: 'Buffet', child: Text('Buffet')),
    DropdownMenuItem(value: 'Food Stalls', child: Text('Food Stalls')),
    DropdownMenuItem(value: 'Takeaway', child: Text('Takeaway')),
  ];

  bool valForm(BuildContext context) {
    if (_fKey.currentState?.saveAndValidate() ?? false) {
      final dat = _fKey.currentState?.value;

      //These two are being used to convert from DateTime to TimeOfDay
      TimeOfDay? startToim = dat?['event_start_time'] != null ? TimeOfDay.fromDateTime(dat?['event_start_time'],) : null;
      TimeOfDay? endToim = dat?['event_end_time'] != null ? TimeOfDay.fromDateTime(dat?['event_end_time'],) : null;

      //These are useful to "feed" the Provider for later use..
      Provider.of<FormaPDat>(context, listen: false).updtEventInfoReq(
        booking_date: dat?['booking_date'],
        event_date_range: dat?['event_date_range'],
        event_start_time: startToim,
        event_end_time: endToim,
        add_req: dat?['add_req'],
        food_sell_types: dat?['food_sell_types'],
      );
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Event Information'),
    ),
    body: FormBuilder(
    key: _fKey,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Booking Date Picker
            FormBuilderDateTimePicker(
              name: 'booking_date',
              decoration: InputDecoration(
                labelText: 'Booking Date',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.blueGrey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.red)),
              ),
              firstDate: DateTime.now(),
              format: DateFormat('dd/MM/yyyy hh:mm aaa'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 16),

            // Event Date Range Picker
            FormBuilderDateRangePicker(
              name: 'event_date_range',
              decoration: InputDecoration(
                labelText: 'Event Start & End Date',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.blueGrey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.red)),
              ),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              format: DateFormat('dd/MM/yyyy'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 16),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'event_start_time',
                      inputType: InputType.time,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.blueGrey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.blue)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.red)),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: FormBuilderDateTimePicker(
                    name: 'event_end_time',
                    inputType: InputType.time,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.blueGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.blue)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.red)),
                    ),
                    validator: FormBuilderValidators.required(),
                    ),
                  ),
                ],
              ),
            ),
            // Checkbox for Food Truck Decoration
            FormBuilderCheckbox(
              name: 'add_req',
              title: Text('Food Truck Decoration', style: TextStyle(fontSize: 18),),
            ),
            SizedBox(height: 16),

            // Dropdown for Food Selling Types
            FormBuilderDropdown(
              name: 'food_sell_types',
              items: _ddItm,
              decoration: InputDecoration(
                labelText: 'Select an Option',
                prefixIcon: Icon(Icons.fastfood),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.blueGrey)),
                focusedBorder : OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),borderSide: BorderSide(color: Colors.red)),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    )

    ),
  );
}
