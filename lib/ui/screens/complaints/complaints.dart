import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';
import 'package:biux/ui/widgets/dropdowm_widget.dart';

class Complaints extends StatefulWidget {
  @override
  _ComplaintsState createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  late String _myActivity;
  late String _myActivity2;
  late String _myActivity3;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.complaintsText),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              AppStrings.IndicatePerson,
              style: Styles.indicatePerson,
            ),
            height: 22,
          ),
          Container(
            height: 10,
          ),
          Container(
            //  height: 52,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1.0,
                  style: BorderStyle.solid,
                  color: AppColors.gray,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
            ),

            child: DropDownFormField(
              titleText: AppStrings.memberList,
              hintText: AppStrings.selectPerson,
              value: _myActivity,
              onSaved: (value) {
                setState(
                  () {
                    _myActivity = value;
                  },
                );
              },
              onChanged: (value) {
                setState(
                  () {
                    _myActivity = value;
                  },
                );
              },
              filled: false,
              dataSource: [
                {
                  AppStrings.displayText: AppStrings.complaintsDisplay1,
                  AppStrings.valueText: AppStrings.complaintsvalue1,
                  AppStrings.iconText: Icons.account_circle,
                },
                {
                  AppStrings.displayText: AppStrings.complaintsDisplay2,
                  AppStrings.valueText: AppStrings.complaintsvalue2,
                  AppStrings.iconText: Icons.account_circle
                },
                {
                  AppStrings.displayText: AppStrings.complaintsDisplay3,
                  AppStrings.valueText: AppStrings.complaintsvalue3,
                  AppStrings.iconText: Icons.account_circle
                },
                {
                  AppStrings.displayText: AppStrings.complaintsDisplay4,
                  AppStrings.valueText: AppStrings.complaintsvalue4,
                  AppStrings.iconText: Icons.account_circle
                },
                {
                  AppStrings.displayText: AppStrings.complaintsDisplay5,
                  AppStrings.valueText: AppStrings.complaintsvalue5,
                  AppStrings.iconText: Icons.account_circle
                },
              ],
              textField: AppStrings.displayText,
              valueField: AppStrings.valueText,
              iconField: AppStrings.iconText,
            ),
          ),
          Container(
            height: 20,
          ),
          Container(
            child: Text(
              AppStrings.affairText,
              style: Styles.indicatePerson,
            ),
            height: 22,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 270,
                height: 120,
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.transparent),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    hintText: AppStrings.affairText,
                    hintStyle: Styles.hintStyle,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.emptyField : null,
                ),
              ),
            ],
          ),
          Container(
            height: 20,
          ),
          Align(
            child: ButtonTheme(
              minWidth: 125.0,
              height: 50.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  side: BorderSide(width: 3, color: AppColors.lightNavyBlue),
                ),
                onPressed: () {},
                child: Text(
                  AppStrings.sendText,
                  style: Styles.sendText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
