import 'package:flutter/material.dart';
import 'package:panda_sync/panda_sync.dart';
import 'package:panda_sync_todo/screens/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineFirstLocalStorageInit.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
    );
  }
}
