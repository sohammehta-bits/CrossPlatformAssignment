import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'kvizXVWQ5PCvxa76RE2p34SAyU0ibqBoPL3JEPv5', // Replace with your Back4App App ID
    'https://parseapi.back4app.com', // Back4App's Parse endpoint
    clientKey: 'qcqSAvmourWHZexqnx99dnTzk8unSPOGFG4Vyrgh', // Replace with your Back4App Client Key
    autoSendSessionId: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
