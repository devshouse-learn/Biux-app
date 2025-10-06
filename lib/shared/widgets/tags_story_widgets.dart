import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/styles.dart';
import 'package:flutter/material.dart';

class TagsStoryWidget extends StatelessWidget {
  final String labelText;
  final void Function() onPressed;
  const TagsStoryWidget({
    Key? key,
    required this.labelText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 3,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.primary30,
            borderRadius: BorderRadius.all(
              Radius.circular(
                10,
              ),
            ),
          ),
          child: Text(
            labelText,
            style: Styles.containerTextName,
          ),
        ),
        GestureDetector(
          onTap: onPressed,
          child: ClipOval(
            child: ColoredBox(
              color: ColorTokens.error50,
              child: Icon(
                Icons.close,
                color: ColorTokens.neutral100,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


