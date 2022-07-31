import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/models/sites.dart';
import 'package:biux/data/models/group.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class ZoomPage extends StatefulWidget {
  final Group _group;
  ZoomPage(this._group);
  _ZoomPageState createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {
  late Road _road;
  bool imageProfileCover = true;
  double _scale = 1.0;
  double _previousScale = 1.0;
  int x = 2;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.strongCyan,
        title: Text(AppStrings.coverGroup2),
      ),
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
                      imageProfileCover
                          ? widget._group.profileCover
                          : AppStrings.urlBiuxApp,
                    ),
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 10,
                    backgroundDecoration: BoxDecoration(
                      color: AppColors.white,
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

class ZoomPage2 extends StatefulWidget {
  @override
  final Group _group;
  ZoomPage2(this._group);
  _ZoomPageState2 createState() => _ZoomPageState2();
}

class _ZoomPageState2 extends State<ZoomPage2> {
  late Road _road;
  bool imagelogo = true;
  double _scale = 1.0;
  double _previousScale = 1.0;
  int x = 2;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.groupLogo),
        backgroundColor: AppColors.strongCyan,
      ),
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
                  tag: AppStrings.logoImage,
                  child: PhotoView(
                    imageProvider: NetworkImage(
                      imagelogo
                          ? widget._group.logo
                          : AppStrings.urlBiuxApp,
                    ),
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 10,
                    backgroundDecoration: BoxDecoration(
                      color: AppColors.white,
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

class ZoomPage3 extends StatefulWidget {
  final Sites _sites;
  ZoomPage3(this._sites);
  _ZoomPageState3 createState() => _ZoomPageState3();
}

class _ZoomPageState3 extends State<ZoomPage3> {
  bool imageProfileCover = false;
  double _scale = 1.0;
  double _previousScale = 1.0;
  int x = 2;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.frontPage),
      ),
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
                      widget._sites.profileCover == null
                          ? AppStrings.urlBiuxApp
                          : widget._sites.profileCover,
                    ),
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 10,
                    backgroundDecoration: BoxDecoration(
                      color: AppColors.greyishNavyBlue2,
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
