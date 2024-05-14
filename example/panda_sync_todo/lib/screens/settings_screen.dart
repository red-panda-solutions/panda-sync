import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_screen.dart';
import 'stacked_icons.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

showAlertDialog(BuildContext context) async {

  // set up the buttons
  // ignore: deprecated_member_use
  Widget cancelButton = ElevatedButton(
    child: const Text("Cancel"),
    onPressed:  () {Navigator.pop(context);},
  );
  // ignore: deprecated_member_use
  Widget continueButton = ElevatedButton(
    child: const Text("OK"),
    onPressed:  () {
      Fluttertoast.showToast(msg: "All data cleared");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => HomeScreen()));
      },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: const Text("Would you like to clear all data? It cannot be undone."),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => HomeScreen()))),
        title: const Row(children: [
          Text(
            'Settings',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ]),
        // actions: [
        //   IconButton(
        //       icon: Icon(
        //         Icons.info_outline,
        //         color: Colors.black,
        //       ),
        //       onPressed: () {}),
        // ],
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 60.0, 25.0, 25.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const StakedIcons(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Task Manager",
                      style: TextStyle(fontSize: 20.0, color: Colors.grey),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, left: 25.0, right: 20.0, bottom: 60.0),
                child: Container(
                    alignment: Alignment.center,
                    child: const Text("Version: 3.0.0",
                        style: TextStyle(fontSize: 12.0, color: Colors.grey))),
              ),
              const SizedBox(
                width: 1080,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, left: 40.0, right: 20.0, bottom: 30.0),
                        child: GestureDetector(
                          onTap: () {
                            showAlertDialog(context);
                          },
                          child: Container(
                              alignment: Alignment.center,
                              height: 40.0,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(9.0)),
                              child: const Text("CLEAR ALL DATA",
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white))),
                        ),
                      ),
                    ),
                  ]),
              const SizedBox(
                width: 1080,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 20.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 60.0,
                  child: InkWell(
                    child: Text(
                      "Terms and Condition",
                      style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.brown,
                          backgroundColor: Colors.transparent),
                    ),
                    onTap: () => {}// launch('https://bornomala-tech.web.app/policies'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 20.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 60.0,
                  child: InkWell(
                    child: const Text(
                      "Privacy Policy",
                      style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.brown,
                          backgroundColor: Colors.transparent),
                    ),
                    onTap: () => {}
                        //launch('https://bornomala-tech.web.app/policies'),
                  ),
                ),
              ),
              const SizedBox(
                width: 1080,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              ),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child:  Text("Bornomala Technologies ",
                          style: TextStyle(
                              fontSize: 15.0, color: Colors.black54)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
