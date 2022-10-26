import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class ZoomPage extends StatefulWidget {
  final String urlImage;
  final name;
  ZoomPage(this.urlImage, this.name);
  _ZoomPageState createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  int x = 2;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileCoverGroup,
      body: Center(
        child: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            _previousScale = _scale;
            setState(() {});
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            _scale = _previousScale * details.scale;
            setState(() {});
          },
          onScaleEnd: (ScaleEndDetails details) {
            _previousScale = 1.0;
            setState(() {});
          },
          child: RotatedBox(
            quarterTurns: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.diagonal3(
                  Vector3(
                    _scale,
                    _scale,
                    _scale,
                  ),
                ),
                child: Hero(
                  tag: AppStrings.coverImage,
                  child: PhotoView(
                    imageProvider: NetworkImage(
                      widget.urlImage.isNotEmpty
                          ? widget.urlImage
                          : AppStrings.urlBiuxApp,
                    ),
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 10,
                    backgroundDecoration: BoxDecoration(
                      color: AppColors.profileCoverGroup,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
