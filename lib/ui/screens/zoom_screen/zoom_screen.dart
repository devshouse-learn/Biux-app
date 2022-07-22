import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/road.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

// ignore: must_be_immutable
class ZoomScreen extends StatefulWidget {
  String _image;
  ZoomScreen(this._image);
  _ZoomScreenState createState() => _ZoomScreenState();
}

class _ZoomScreenState extends State<ZoomScreen> {
  bool imageProfileCover = true;
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
                      imageProfileCover
                          ? widget._image
                          : AppStrings.urlBiuxApp,
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

class ZoomPage2 extends StatefulWidget {
  final String? image;
  ZoomPage2(this.image);
  _ZoomPageState2 createState() => _ZoomPageState2();
}

class _ZoomPageState2 extends State<ZoomPage2> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  int x = 2;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    Container loadingPlaceHolder = Container(
      height: 600.0,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.strongCyan,
        title: Text(AppStrings.historyImage),
      ),
      body: Center(
        child: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            _previousScale = _scale;
            setState(() {});
          },
          onTap: () {
            Navigator.pop(context);
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
                      imageProvider: NetworkImage(widget.image!),
                      minScale: PhotoViewComputedScale.contained * 1.0,
                      maxScale: PhotoViewComputedScale.covered * 10,
                      backgroundDecoration: BoxDecoration(
                        color: AppColors.white,
                      ),
                    )
                    // child: CachedNetworkImage(
                    //   height: 600,
                    //   // width: double.infinity,
                    //   imageUrl: widget.image!,
                    //   fit: BoxFit.contain,
                    //   placeholder: (context, url) => loadingPlaceHolder,
                    //   errorWidget: (context, url, error) => Icon(Icons.error),
                    // )

                    // PhotoView(
                    //   imageProvider: NetworkImage(
                    //      widget.image!),
                    //   minScale: PhotoViewComputedScale.contained * 1.0,
                    //   maxScale: PhotoViewComputedScale.covered * 10,
                    //   backgroundDecoration: BoxDecoration(
                    //     color: AppColors.greyishNavyBlue2,
                    //   ),
                    // )),
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
  final String? image;
  ZoomPage3(this.image);
  _ZoomPageState3 createState() => _ZoomPageState3();
}

class _ZoomPageState3 extends State<ZoomPage3> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  int x = 2;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    Container loadingPlaceHolder = Container(
      height: 600.0,
      child: Center(child: CircularProgressIndicator()),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.strongCyan,
        title: Text(AppStrings.profilePicture),
      ),
      body: Center(
        child: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            _previousScale = _scale;
            setState(() {});
          },
          onTap: () {
            Navigator.pop(context);
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
                    imageProvider: NetworkImage(widget.image!),
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
