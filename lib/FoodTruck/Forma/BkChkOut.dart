// ignore_for_file: file_names

import 'package:fdb/FoodTruck/Forma/FormaDat/_FTPDat.dart';
import 'package:fdb/User/userProv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FormaDat/_FormaPDat.dart';
import '../../db/database_helper.dart';

class BkChkOut extends StatefulWidget {
  const BkChkOut({super.key});

  @override
  BkChkOutState createState() => BkChkOutState();
}

class BkChkOutState extends State<BkChkOut> {
  final TextEditingController dscountCtrl = TextEditingController();
  double finProis = 0.0;

  // ====================================================================
  //                        DISCOUNT CODE MATCHING
  // ====================================================================

  double dscountProis(double SelPaxProis, String? dscountKod) {
    if (dscountKod == null || dscountKod.isEmpty) {
      return SelPaxProis;
    } else if (dscountKod == "FT10") {
      return (SelPaxProis * 0.9);
    } else if (dscountKod == "NEWME25") {
      return (SelPaxProis * 0.75);
    } else if (dscountKod == "RAHMAHB40") {
      return (SelPaxProis * 0.6);
    } else {
      return SelPaxProis;
    }
  }

  // ====================================================================
  //DISCOUNT CODE VALIDATION
  // ====================================================================

  void appDscount(double SelPaxProis) {
    String dscountKod = dscountCtrl.text.trim();
    double calcProis = dscountProis(SelPaxProis, dscountKod);

    if (calcProis == SelPaxProis) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Discount Code'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      setState(() {
        finProis = calcProis;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great Discount, Happy Booking!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }
  // ====================================================================
  // ====================================================================

  // ====================================================================
  // SAVE BOOKING TO DATABASE
  // ====================================================================

  Future<void> saveBooking() async {
    final formaProvider = Provider.of<FormaPDat>(context, listen: false);
    final ftpProvider = Provider.of<FTPDat>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Prepare data to save
    final bookingData = {
      'userid': userProvider.userId, // Get userId from provider
      'book_date': formaProvider.booking_date != null
          ? DateFormat('yyyy-MM-dd').format(formaProvider.booking_date!)
          : '',
      'booktime': formaProvider.booking_date != null
          ? DateFormat('HH:mm:ss').format(formaProvider.booking_date!)
          : '',
      'eventdate': formaProvider.event_date_range?.start.toIso8601String() ??
          '', // Start of the date range
      'eventtime': formaProvider.event_start_time != null &&
              formaProvider.event_end_time != null
          ? '${formaProvider.event_start_time!.format(context)} - ${formaProvider.event_end_time!.format(context)}'
          : '',
      'foodtrucktype': formaProvider.food_sell_types ?? 'Not Provided',
      'numberofdays': formaProvider.event_date_range != null
          ? formaProvider.event_date_range!.end
                  .difference(formaProvider.event_date_range!.start)
                  .inDays +
              1
          : 0, // Calculate number of days
      'price': finProis > 0 ? finProis : ftpProvider.totProis, // Final price
    };

    try {
      // Insert booking into the database
      int result = await DatabaseHelper.instance.addBooking(bookingData);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking saved successfully!')),
        );
        Navigator.pop(context); // Navigate back after saving
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save booking.')),
        );
      }
    } catch (e) {
      print('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ====================================================================
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    final ftP = Provider.of<FTPDat>(context);
    double chkProis = ftP.totProis;
    double discountReduction = chkProis - (finProis > 0 ? finProis : chkProis);

    //Get data from Event Info page via Provider
    DateTime? bookDate = Provider.of<FormaPDat>(context).booking_date;
    String forBookDate = DateFormat('dd/MM/yyyy HH:mm').format(bookDate!);

    DateTime? startDateRange =
        Provider.of<FormaPDat>(context).event_date_range?.start;
    String forStartDate = DateFormat('dd/MM/yyyy').format(startDateRange!);

    DateTime? endDateRange =
        Provider.of<FormaPDat>(context).event_date_range?.start;
    String forEndDate = DateFormat('dd/MM/yyyy').format(endDateRange!);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Booking Information')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Details:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text(
                          'Name: ${Provider.of<FormaPDat>(context).full_name ?? 'Not Provided'}'),
                      Text(
                          'Address: ${Provider.of<FormaPDat>(context).address ?? 'Not Provided'}'),
                      Text(
                          'Phone: ${Provider.of<FormaPDat>(context).phone_no ?? 'Not Provided'}'),
                      Text(
                          'Email: ${Provider.of<FormaPDat>(context).email ?? 'Not Provided'}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Event Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Event Info:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Booking Date: $forBookDate'),
                      Text(
                          'Event Start-End Date: ${forStartDate.toString()} - ${forEndDate.toString()}'),
                      Text(
                          'Event Start-End Time: ${Provider.of<FormaPDat>(context).event_start_time?.format(context) ?? 'Not Provided'} - ${Provider.of<FormaPDat>(context).event_end_time?.format(context) ?? 'Not Provided'}'),
                      Text(
                          'Food Truck Decoration: ${Provider.of<FormaPDat>(context).add_req == true ? "Yes" : (Provider.of<FormaPDat>(context).add_req == false ? "No" : "Not Provided")}'),
                      Text(
                          'Food Selling Type: ${Provider.of<FormaPDat>(context).food_sell_types ?? 'Not Provided'}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Pricing Section
              Text(
                'Pricing Details:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Original Total Price:',
                            style: TextStyle(fontSize: 16)),
                        Text(
                          'RM${chkProis.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: finProis > 0 ? Colors.grey : Colors.black,
                            decoration: finProis > 0
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Discount Reduction (if any)
                    if (discountReduction > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount Reduction:',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.red)),
                          Text(
                            '- RM${discountReduction.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    SizedBox(height: 8),
                    // Final Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Final Price:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        Text(
                          'RM${(finProis > 0 ? finProis : chkProis).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Discount Section
              Text(
                'Apply Discount:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dscountCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Discount Code',
                        hintText: 'Enter Discount Code',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => appDscount(chkProis),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Selected Packages List
              Text(
                'Selected Packages:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ftP.selPax.length,
                itemBuilder: (context, index) {
                  final pck = ftP.selPax[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('${pck['ft']} (${pck['pax']})',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text('RM${pck['prois'].toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
