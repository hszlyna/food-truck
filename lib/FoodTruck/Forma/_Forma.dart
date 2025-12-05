import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../db/database_helper.dart';
import '../../User/userProv.dart';

import 'UserInfo.dart';
import 'EventInfoReq.dart';
import '../FT_Conf/FTSelect.dart';
import 'BkChkOut.dart';
import 'RateIt.dart';
import 'FormaDat/_FormaPDat.dart';
import 'FormaDat/_FTPDat.dart';

class Forma extends StatefulWidget {
  const Forma({super.key});

  @override
  FormaState createState() => FormaState();
}

class FormaState extends State<Forma> {
  int cstep = 0;

  final GlobalKey<UserInfoState> UserInfoKey = GlobalKey<UserInfoState>();
  final GlobalKey<EventInfoReqState> EventInfoReqKey = GlobalKey<EventInfoReqState>();
  final GlobalKey<FTSelectState> FoodTruckSelectKey = GlobalKey<FTSelectState>();

  void prvstep() {
    if (cstep > 0) {
      setState(() => cstep -= 1);
    }
  }

  void nxtstep() {
    bool valid = false;

    if (cstep == 0) {
      valid = UserInfoKey.currentState?.valForm(context) ?? false;
    } else if (cstep == 1) {
      valid = EventInfoReqKey.currentState?.valForm(context) ?? false;
    } else if (cstep == 2) {
      valid = FoodTruckSelectKey.currentState?.fillBook() ?? false;
      if (!valid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Please add at least one Food Truck package first."),
          ),
        );
      }
    } else if (cstep == 3) {
      valid = true;
    } else {
      valid = false;
    }

    if (valid && cstep < 4) {
      setState(() => cstep += 1);
    }
  }

  Future<void> confirmCheckout() async {
    final formaProvider = Provider.of<FormaPDat>(context, listen: false);
    final ftpProvider = Provider.of<FTPDat>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Ensure userId is not null
    final userId = userProvider.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    // Prepare booking data
    final bookingData = {
      'userid': userId, // Use userId from provider
      'book_date': formaProvider.booking_date != null
          ? DateFormat('yyyy-MM-dd').format(formaProvider.booking_date!)
          : '',
      'booktime': formaProvider.booking_date != null
          ? DateFormat('HH:mm:ss').format(formaProvider.booking_date!)
          : '',
      'eventdate': formaProvider.event_date_range?.start.toIso8601String() ?? '',
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
          : 0,
      'price': ftpProvider.totProis, // Final price (including discounts if any)
    };

    try {
      // Insert booking into the database
      int result = await DatabaseHelper.instance.addBooking(bookingData);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking saved successfully!')),
        );

        // Navigate to the next step (Rating page)
        setState(() {
          cstep = 4; // Move to the Rating page
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save booking.')),
        );
      }
    } catch (e) {
      print('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  Widget gBckBtn() => ElevatedButton.icon(
    onPressed: prvstep,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white24,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    icon: Icon(Icons.arrow_back, color: Colors.white),
    label: Text(
      'Back',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );

  Widget gNxtBtn() => ElevatedButton.icon(
    onPressed: nxtstep,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    icon: Icon(Icons.arrow_forward, color: Colors.white),
    label: Text(
      cstep == 1
          ? 'Proceed Booking'
          : cstep == 2
          ? 'Continue Checkout'
          : 'Next',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );

  Widget gChckOutBtn() => Expanded(
    child: Padding(
      padding: EdgeInsets.only(left: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size.fromHeight(48),
        ),
        onPressed: confirmCheckout, // Save booking and move to Rating
        child: const Text(
          'Confirm Checkout',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            EasyStepper(
              activeStep: cstep,
              steps: const [
                EasyStep(title: 'User Info', icon: Icon(Icons.person_2)),
                EasyStep(title: 'Event & Requests', icon: Icon(Icons.event)),
                EasyStep(title: 'Food Truck', icon: Icon(Icons.dining)),
                EasyStep(title: 'Checkout', icon: Icon(Icons.payment)),
                EasyStep(title: 'Rating', icon: Icon(Icons.rate_review)),
              ],
              onStepReached: (idx) => setState(() => cstep = idx),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: IndexedStack(
                  index: cstep,
                  children: [
                    UserInfo(k: UserInfoKey),
                    EventInfoReq(k: EventInfoReqKey),
                    FTSelect(k: FoodTruckSelectKey),
                    BkChkOut(),
                    ReviewPage(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: cstep == 0
                    ? [
                  Container(),
                  gNxtBtn(),
                ]
                    : cstep == 3
                    ? [
                  gBckBtn(),
                  gChckOutBtn(),
                ]
                    : cstep == 4
                    ? [
                  // Empty for Rating page
                ]
                    : [
                  gBckBtn(),
                  gNxtBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
