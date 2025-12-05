import 'package:flutter/material.dart';

class FormaPDat with ChangeNotifier{
  //User Info Page
  String? full_name, address, phone_no, email;

  void updtUserInfo({String? full_name, address, phone_no, email}) {
    this.full_name = full_name;
    this.address = address;
    this.phone_no = phone_no;
    this.email = email;
    notifyListeners();
  }

  //Event Info Page
  DateTime? booking_date;
  DateTimeRange? event_date_range;
  TimeOfDay? event_start_time;
  TimeOfDay? event_end_time;
  bool? add_req;
  String? food_sell_types;

  void updtEventInfoReq({DateTime? booking_date, DateTimeRange? event_date_range, TimeOfDay? event_start_time, TimeOfDay? event_end_time, bool? add_req, String? food_sell_types}){
    this.booking_date = booking_date;
    this.event_date_range = event_date_range;
    this.event_start_time = event_start_time;
    this.event_end_time = event_end_time;
    this.add_req = add_req;
    this.food_sell_types = food_sell_types;
    notifyListeners();
  }
}