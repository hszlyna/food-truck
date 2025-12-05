import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FoodTruck/Forma/FormaDat/_FTPDat.dart';
import 'FoodTruck/Forma/FormaDat/_FormaPDat.dart';
import 'User/userProv.dart';
import 'Home.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FormaPDat(),
        ),
        ChangeNotifierProvider(
          create: (_) => FTPDat(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: FDB(),
    ),
  );
}

class FDB extends StatelessWidget {
  const FDB({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
