import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  // ignore: must_call_super
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 1),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => HomeScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                        radius: 40.0,
                        child: Icon(
                          Icons.check_rounded,
                          color: Color(0xFF18D191),
                          size: 60.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Text(
                        "Task Manager",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      //CircularProgressIndicator(backgroundColor: Colors.grey),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text(
                        "Bornomala Technologies",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17.0,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 60.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
