import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class MenuEvents extends StatefulWidget {
  @override
  _MenuEventsState createState() => _MenuEventsState();
}

String gifE = Images.kGifEvents;

class _MenuEventsState extends State<MenuEvents> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      child: Text(
        AppStrings.eventsText,
        style: Styles.eventsText,
      ),
    );
  }
}
