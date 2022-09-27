import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/repositories/stories/stories_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share/share.dart';

import '../../../../../data/models/story.dart';

class ButtonStory extends StatefulWidget {
  // Historia _historia;
  final Story story;

  ButtonStory({required this.story});

  @override
  _ButtonStoryState createState() => _ButtonStoryState();
}

@override
class _ButtonStoryState extends State<ButtonStory> {
  var storiesFilter = [];
  var story;
  var firstHalf;
  var secondHalf;
  bool flag = false;
  var response;

  var map = Map();
  List ouput = [];
  @override
  @override
  void initState() {
    setState(
      () {
        if (widget.story.description.length > 20) {
          firstHalf = widget.story.description.substring(0, 50);
          secondHalf = widget.story.description.substring(
            50,
            widget.story.description.length,
          );
        } else {
          firstHalf = widget.story.description;
          secondHalf = "";
        }
      },
    );
  }

  Widget build(BuildContext context) {
    Widget imageCarousel = Stack(

      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
            ),
          ),
          child: Stack(

            children: [
              Column(
                children: [
                  Container(
                    height: 40,
                    padding: EdgeInsets.only(
                      left: 60,
                    ),
                    color: AppColors.strongCyan,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            AppStrings.storyItems(names: 'aqui va el nombre de usuario'),
                            style: Styles.advertisingTitle,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.share),
                          color: AppColors.white,
                          onPressed: () async {
                            final RenderObject? box =
                                context.findRenderObject();
                            if (Platform.isAndroid) {
                              // var response = await get(
                              //     Uri.parse(widget.historiaItem.fileUrl1));
                              // final documentDirectory =
                              //     (await getExternalStorageDirectory()).path;
                              // File imgFile =
                              //      File('$documentDirectory/flutter.png');

                              // imgFile.writeAsBytesSync(response.bodyBytes);
                              var response2 = await get(
                                Uri.parse(widget.story.fileUrl2),
                              );

                              final documentDirectory2 =
                                  (await getExternalStorageDirectory())!.path;
                              File imgFile2 =
                                  File(AppStrings.file(png: documentDirectory2));
                              imgFile2.writeAsBytesSync(response2.bodyBytes);
                              // var response3 = await get(
                              //     Uri.parse(widget.historiaItem.fileUrl3));
                              // final documentDirectory3 =
                              //     (await getExternalStorageDirectory()).path;
                              // File imgFile3 =
                              //      File('$documentDirectory3/flutter.png');
                              // imgFile3.writeAsBytesSync(response3.bodyBytes);
                              await Share.shareFiles(
                                [
                                  File(AppStrings.file(png: documentDirectory2)).path,
                                ],
                                text: AppStrings.shareStory(name: 'aqui va el nombre de usuario', descripcion: widget.story.description)
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: ImageSlideshow(
                      width: double.infinity,
                      height: 240,
                      initialPage: 0,
                      // autoPlayInterval: 2,
                      indicatorColor: AppColors.strongCyan,
                      indicatorBackgroundColor: AppColors.gray,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.story.fileUrl1),
                              fit: BoxFit.fitHeight,
                            ),
                            // border:
                            //     Border.all(color: Theme.of(context).accentColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.story.fileUrl2),
                              fit: BoxFit.fitHeight,
                            ),
                            // border:
                            //     Border.all(color: Theme.of(context).accentColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.story.fileUrl3),
                              fit: BoxFit.fitHeight,
                            ),
                            // border:
                            //     Border.all(color: Theme.of(context).accentColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      response = await StoriesRepository().reactionStory(
                        widget.story.user.id,
                        widget.story.id,
                      );
                      // .whenComplete(
                      //     () => {setState(() {})});
                    },
                  ),
                  Container(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReadMoreText(
                      "aqui va el nombre de usuario :   ${widget.story.description}",
                      trimLines: 2,
                      colorClickableText: AppColors.gray,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: AppStrings.seeMore,
                      trimExpandedText: AppStrings.seeLess,
                      style: Styles.accentTextThemeBlack,
                      moreStyle: Styles.advertisingTitleBlack,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height / 200,
                    // width: MediaQuery.of(context).size.width * 0.0002,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    return Column(
      children: <Widget>[
        Stack(

          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 2.0,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: imageCarousel,
                ),
                Container(
                  width: 10,
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: -20,
              right: 0,
              top: -16,
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  child: Material(
                    elevation: 20,
                    borderRadius: BorderRadius.circular(55.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60.0),
                        boxShadow: [
                          BoxShadow(color: AppColors.white, spreadRadius: 2)
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.strongCyan,
                        ),
                        height: 75,
                        width: 75,
                        child: InkWell(
                          child: Container(
                            alignment: (Alignment(-0.2, 2.2)),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  widget.story.fileUrl1,
                                ),
                              ),
                              borderRadius: BorderRadius.all(
                                const Radius.circular(80.0),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(
                              () {},
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 240,
              right: 0,
              top: 255,
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(55.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.strongCyan,
                      ),
                      height: 55,
                      width: 205,
                      child: InkWell(
                        child: Container(
                          width: 205,
                          alignment: (Alignment(-0.2, 2.2)),
                          decoration: BoxDecoration(
                            color: AppColors.strongCyan,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40.0),
                              topLeft: Radius.circular(40.0),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Text(
                                      "0 ",
                                      style: Styles.advertisingTitle,
                                    ),
                                  ),
                                  Icon(
                                    Icons.pedal_bike,
                                    size: 25.0,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                              Container(
                                child: Text(
                                  AppStrings.likeText,
                                  style: Styles.advertisingTitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(
                            () {},
                          );
                        },
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pullRefresh() async {
    this.setState(() => {});
  }
}
