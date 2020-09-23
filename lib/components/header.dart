import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String header;
  const Header({
    this.header,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: Text(
        header ?? 'График работы',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: Color(0xFF464850),
        ),
      ),
    );
  }
}
