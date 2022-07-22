
import 'package:biux/config/strings.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget{
  @override
 _NotificationScreenState createState()=> new _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppStrings.notifications),
      ),
    );
  }
}