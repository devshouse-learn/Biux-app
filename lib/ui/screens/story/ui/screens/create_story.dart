import 'dart:convert';
import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/shared_preferences/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:biux/data/models/story.dart';
import 'package:biux/data/repositories/stories/stories_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/models/user.dart';

class CreateStory extends StatefulWidget {
  @override
  _CreateStoryState createState() => new _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  @override
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _description;
  var response;
  var _image;
  late BiuxUser user;
  late bool refresh = false;

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      this.setState(
        () {
          _image = image;
        },
      );
    }
  }

  var _image2;
  getUserProfile() async {
    String? username = await LocalStorage().getUser();
    user = await UserRepository().getPerson(username!);
    if (user != null) {
      setState(
        () {
          user = user;
        },
      );
    } else {}
  }

  Future getImageFromGallery2() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      this.setState(
        () {
          _image2 = image;
        },
      );
    }
  }

  var _image3;

  Future getImageFromGallery3() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      this.setState(
        () {
          _image3 = image;
        },
      );
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: Text(AppStrings.createStory),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: ListView(
            children: <Widget>[
              Container(
                height: 20,
                width: 20,
              ),
              Container(
                height: 2,
              ),
              Container(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: descriptionController,
                    minLines: 10,
                    maxLines: 500,
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: AppStrings.descriptionStory,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            10.0,
                          ),
                        ),
                        borderSide: BorderSide(),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            10.0,
                          ),
                        ),
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 20,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100, //igualito
                    child: _image == null
                        ? RaisedButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(),
                            ),
                            onPressed: () {
                              getImageFromGallery();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.photo_camera,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            child: Image.file(
                              _image.path != null ? _image : _image,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          ),
                  ),
                  Container(
                    width: 10,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100, // parecido xd
                    child: _image2 == null
                        ? RaisedButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(),
                            ),
                            onPressed: () {
                              getImageFromGallery2();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.photo_camera,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            child: Image.file(
                              _image2.path != null ? _image2 : _image2,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          ),
                  ),
                  Container(
                    width: 10,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100, //parecido
                    child: _image3 == null
                        ? RaisedButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(),
                            ),
                            onPressed: () {
                              getImageFromGallery3();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.photo_camera,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            child: Image.file(
                              _image3.path != null ? _image3 : _image3,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          ),
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              ButtonTheme(
                minWidth: 10.0,
                height: 50.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _description = descriptionController.text;
                      createStory(
                        Story(
                          userId: user.id!,
                          description: _description,
                          //    imageUrl: _image.path,
                        ),
                      );
                      _showDialog();
                    }
                  },
                  child: Text(
                    AppStrings.postStory,
                    style: Styles.postStoryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppStrings.publishedStory),
          content: new Text(""),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    50.0,
                  ),
                ),
              ),
              child: new Text(AppStrings.ok),
              onPressed: () {
                Future.delayed(
                  Duration(seconds: 5),
                  () async {
                    refresh = true;
                    Navigator.pop(context, refresh);
                  },
                );
                // Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void createStory(Story story) async {
    try {
      var uriResponse = await http.post(
          Uri.parse(AppStrings.urlBiuxHistorias),
          body: jsonEncode(story.toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: AppStrings.applicationJsonText,
          });
      final dataI = json.decode(uriResponse.body);
      int id = dataI[AppStrings.idText];
      await StoriesRepository().uploadImageStory(
        id,
        _image,
      );
      if (uriResponse.statusCode == 200) {
        return;
      } else {
        return null;
      }
    } catch (e) {}
  }
}
