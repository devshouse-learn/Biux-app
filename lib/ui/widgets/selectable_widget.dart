import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:flutter/material.dart';

class SelectableWidget extends StatefulWidget {
  final String text;
  SelectableWidget(this.text);

  @override
  _StateSelectableWidget createState() => _StateSelectableWidget();
}

class _StateSelectableWidget extends State<SelectableWidget> {
  final Color color1 = AppColors.white;
  final Color color2 = AppColors.greyishNavyBlue2;
  final Color textColor1 = AppColors.lightNavyBlue;
  final Color textColor2 = AppColors.white;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: 75,
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(
            color: !isSelected ? textColor1 : textColor1,
          ),
          borderRadius: BorderRadius.circular(20.0),
          color: !isSelected ? color2 : color1,
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: Styles.selectableWidget.copyWith(
            color: !isSelected ? textColor2 : textColor1,
          ),
        ),
      ),
      onTap: () {
        setState(
          () {
            isSelected = !isSelected;
          },
        );
      },
    );
  }
}
