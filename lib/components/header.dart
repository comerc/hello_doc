import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String header;
  final String text;
  const Header({
    this.header,
    this.text,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
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
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              text ??
                  'Укажите время, когда вы доступны для звонков и сможете быстро отвечать пациентам',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF464850)),
            ),
          )
        ],
      ),
    );
  }
}
