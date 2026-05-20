import 'package:biux/core/design_system/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      width: width,
      color: ColorTokens.neutral0.withValues(alpha: 0.7),
      child: Stack(
        children: [
          Center(
            child: Container(height: height, width: width),
          ),
          Center(
            child: SizedBox(
              height: 90.0,
              width: 90.0,
              child: LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: const [ColorTokens.neutral100],
                strokeWidth: 20,
                backgroundColor: ColorTokens.transparent,
                pathBackgroundColor: ColorTokens.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
