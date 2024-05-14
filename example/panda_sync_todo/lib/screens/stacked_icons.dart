import 'package:flutter/material.dart';

class StakedIcons extends StatelessWidget {
  const StakedIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: 60.0,
          width: 60.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0), color: Colors.white),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF18D191),
            size: 50.0,
          ),
        ),
      ],
    );
  }
}
