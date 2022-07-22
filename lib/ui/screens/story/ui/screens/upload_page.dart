import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/analitics.dart';
import 'package:biux/data/models/location.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:io';

// ignore: must_be_immutable
class Uploader extends StatefulWidget {
  BiuxUser? user;
  Uploader(this.user);
  _Uploader createState() => _Uploader();
}

class _Uploader extends State<Uploader> {
  var file;
  var address;
  Map<String, double> currentLocation = Map();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  ImagePicker imagePicker = ImagePicker();
  late String data;
  bool uploading = false;
  int selected = 1;
  Member? member;
  var selectID;
  bool loading = false;
  @override
  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();
  initState() {
    super.initState();
    //variables with location assigned as 0.0
    currentLocation[AppStrings.latitude] = 0.0;
    currentLocation[AppStrings.longitude] = 0.0;
    //method to call location
    member = Member(
      id: 0,
      user: BiuxUser(
        surnames: "",
        gender: "",
        names: "",
        id: '0',
      ),
      group: Group(
        id: '0',
        admin: BiuxUser(
          surnames: "",
          gender: "",
          names: "",
          id: '0',
        ),
      ),
    );
    Future.delayed(
      Duration.zero,
      () async {
        initPlatformState();
        member = await MembersRepository().getMyGroupsUser(
          widget.user!.id!,
        );
        this.setState(() => {});
      },
    );
  }

  //method to get Location and save into variables
  initPlatformState() async {
    Address? first = await getUserLocation();
    setState(() {});
    setState(
      () {
        address = first!;
      },
    );
  }

  Widget build(BuildContext context) {
    ImagePicker imagePicker = ImagePicker();
    _selectImage(BuildContext parentContext) async {
      return showDialog<Null>(
        context: parentContext,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.all(
                Radius.circular(40),
              ),
              side: BorderSide(
                width: 3,
                color: AppColors.greyishNavyBlue,
              ),
            ),
            title: const Text(
              AppStrings.choose,
              style: Styles.accentTextThemeBlack,
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    PickedFile? imageFile = await imagePicker.getImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1200,
                      imageQuality: 80,
                    );
                    setState(
                      () {
                        file = File(imageFile!.path);
                      },
                    );
                  },
                  child: Text(
                    AppStrings.takePhoto,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
              ),
              SimpleDialogOption(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    PickedFile? imageFile = await imagePicker.getImage(
                        source: ImageSource.gallery,
                        maxWidth: 1920,
                        maxHeight: 1200,
                        imageQuality: 80);
                    setState(
                      () {
                        file = File(imageFile!.path);
                      },
                    );
                  },
                  child: Text(
                    AppStrings.chooseGallery,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
              ),
              SimpleDialogOption(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppStrings.cancelText,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // file == null
    //     ? MaterialApp(
    //         home: Scaffold(
    //           body: Center(
    //             child: IconButton(
    //                 icon: Icon(Icons.file_upload),
    //                 onPressed: () => {_selectImage(context)}),
    //           ),
    //         ),
    //       )
    //     :
    return MaterialApp(
      home: Scaffold(
        key: _scaffolState,
        backgroundColor: AppColors.darkBlue,
        body: Form(
          child: ListView(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 20,
                        ),
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 10),
                        child: Text(
                          AppStrings.createStory,
                          textAlign: TextAlign.center,
                          style: Styles.wrapDrawerWhite,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Stack(

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Stack(

                            children: [
                              Center(
                                child: Container(
                                  height: 550,
                                  width: 370,
                                  child: Card(
                                    color: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            member!.group!.admin!.id! ==
                                                    widget.user!.id!
                                                ? Row(
                                                    children: [
                                                      GestureDetector(
                                                        child: Container(
                                                          width: 80,
                                                          height: 90,
                                                          child: CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                              widget
                                                                  .user!.photo!,
                                                            ),
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: selected ==
                                                                      1
                                                                  ? AppColors
                                                                      .strongCyan
                                                                  : AppColors
                                                                      .transparent,
                                                              width: 4.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(
                                                            () {
                                                              selected = 1;
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      GestureDetector(
                                                        child: Container(
                                                          width: 80,
                                                          height: 90,
                                                          decoration:
                                                              new BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border:
                                                                new Border.all(
                                                              color: selected ==
                                                                      2
                                                                  ? AppColors
                                                                      .strongCyan
                                                                  : AppColors
                                                                      .transparent,
                                                              width: 4.0,
                                                            ),
                                                          ),
                                                          child: CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                              member!
                                                                  .group!.logo!,
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(
                                                            () {
                                                              selected = 2;
                                                            },
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  )
                                                : GestureDetector(
                                                    child: Container(
                                                      width: 80,
                                                      height: 90,
                                                      decoration:
                                                          new BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: new Border.all(
                                                          color: selected == 1
                                                              ? AppColors
                                                                  .strongCyan
                                                              : AppColors
                                                                  .transparent,
                                                          width: 4.0,
                                                        ),
                                                      ),
                                                      child: CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(
                                                          widget.user!.photo!,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(
                                                        () {
                                                          selected = 1;
                                                        },
                                                      );
                                                    },
                                                  ),
                                          ],
                                        ),
                                        Divider(),
                                        file == null
                                            ? Container(
                                                height: 150,
                                                width: 170,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                  color:
                                                      AppColors.greyishNavyBlue,
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.camera_alt,
                                                    color: AppColors.white,
                                                  ),
                                                  onPressed: () =>
                                                      {_selectImage(context)},
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () =>
                                                    {_selectImage(context)},
                                                child: Container(
                                                  height: 160,
                                                  width: 160,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(
                                                          10.0,
                                                        ),
                                                      ),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: FileImage(
                                                          file,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 330,
                                              child: TextFormField(
                                                maxLines: 3,
                                                maxLength: 200,
                                                controller:
                                                    descriptionController,
                                                style: Styles.indicatePerson,
                                                textInputAction:
                                                    TextInputAction.next,
                                                decoration: InputDecoration(
                                                  fillColor: AppColors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  filled: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                    10.0,
                                                    15.0,
                                                    20.0,
                                                    15.0,
                                                  ),
                                                  hintText:
                                                      AppStrings.tellYourStory,
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors.gray,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(
                                                        15,
                                                      ),
                                                    ),
                                                  ),
                                                  hintStyle:
                                                      Styles.textFormFieldGray,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        ListTile(
                                          leading: Icon(Icons.pin_drop),
                                          title: Container(
                                            width: 250.0,
                                            child: TextField(
                                              controller: locationController,
                                              decoration: InputDecoration(
                                                fillColor: AppColors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                filled: true,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                  10.0,
                                                  15.0,
                                                  20.0,
                                                  15.0,
                                                ),
                                                hintText:
                                                    AppStrings.whereDidThisStoryTakePlace,
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.gray,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                ),
                                                hintStyle:
                                                    Styles.textFormFieldGray,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(), //scroll view where we will show location to users
                                        (address == null)
                                            ? Container()
                                            : SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: EdgeInsets.only(
                                                  right: 5.0,
                                                  left: 5.0,
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    //     buildLocationButton(address.featureName),
                                                    buildLocationButton(
                                                      address.subAdminArea,
                                                    ),
                                                    buildLocationButton(
                                                      address.adminArea,
                                                    ),
                                                    buildLocationButton(
                                                      address.countryName,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          height: 30,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            margin: EdgeInsets.only(top: 570),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Material(
                                elevation: 20,
                                borderRadius: BorderRadius.circular(55.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.white,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.strongCyan,
                                    ),
                                    height: 70,
                                    width: 70,
                                    child: Stack(
                                      children: <Widget>[
                                        new Center(
                                          child: new Icon(
                                            Icons.arrow_forward,
                                            color: AppColors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            setState(() {
                              loading = true;
                            });
                            if (file != null &&
                                descriptionController.text.isNotEmpty &&
                                descriptionController.text.length >= 20 &&
                                locationController.text.isNotEmpty &&
                                selected != 0) {
                              uploadImage(file).then((data) {
                                postToFireStore(
                                  member: member,
                                  user: widget.user,
                                  selected: selected,
                                  photo: data,
                                  description: descriptionController.text,
                                  location: locationController.text,
                                  nameVal: widget.user!.userName,
                                );
                              }).then(
                                (_) {
                                  setState(
                                    () {
                                      file = File("");
                                      uploading = false;
                                    },
                                  );
                                },
                              );
                              setState(
                                () {
                                  Navigator.pop(context);
                                  // .then((value) => setState(() => {}));
                                  uploading = true;
                                },
                              );
                              setState(
                                () {},
                              );
                            } else {
                              Future.delayed(
                                Duration(seconds: 1),
                                () {
                                  setState(() {
                                    loading = false;
                                  });
                                  _scaffolState.currentState!.showSnackBar(
                                    SnackBar(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(40),
                                        ),
                                      ),
                                      backgroundColor: AppColors.red,
                                      content: Text(
                                        file == null
                                            ? AppStrings.imageNotSelected
                                            : descriptionController.text.isEmpty
                                                ? AppStrings.enterDescription
                                                : descriptionController
                                                            .text.length <
                                                        20
                                                    ? AppStrings.descriptionShort
                                                    : locationController
                                                            .text.isEmpty
                                                        ? AppStrings.storyLocation
                                                        : AppStrings.checkData,
                                        style: Styles.advertisingTitle,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  loading == true ? Loading() : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //method to build buttons with location.
  buildLocationButton(String locationName) {
    if (locationName != null) {
      return InkWell(
        onTap: () {
          locationController.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            margin: EdgeInsets.only(
              right: 3.0,
              left: 3.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(
                5.0,
              ),
            ),
            child: Center(
              child: Text(
                locationName,
                style: Styles.centerLocationName,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void clearImage() {
    setState(
      () {
        Navigator.of(context)
            .pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => MyHome(),
                ),
                (Route<dynamic> route) => false)
            .then(
              (value) => setState(() => {}),
            );
        file = File("");
      },
    );
  }

  void postImage() {
    if (file != null &&
        descriptionController.text.isNotEmpty &&
        locationController.text.isNotEmpty) {
      uploadImage(file).then(
        (data) {
          postToFireStore(
            member: member,
            user: widget.user,
            selected: selected,
            photo: data,
            description: descriptionController.text,
            location: locationController.text,
            nameVal: widget.user!.userName,
          );
        },
      ).then(
        (_) {
          setState(
            () {
              file = File("");
              uploading = false;
            },
          );
        },
      );
      setState(
        () {
          Navigator.pop(context);
          // .then((value) => setState(() => {}));
          uploading = true;
        },
      );
      setState(
        () {},
      );
    } else {
      final snackBar = SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        backgroundColor: AppColors.red,
        content: Text(
          file == null
              ? AppStrings.imageNotSelected
              : selected == 0
                  ? AppStrings.selectImageProfile
                  : descriptionController.text.isEmpty
                      ? AppStrings.enterDescription
                      : locationController.text.isEmpty
                          ? AppStrings.storyLocation
                          : AppStrings.checkData,
          style: Styles.advertisingTitle,
        ),
      );
      _scaffolState.currentState!.showSnackBar(snackBar);
    }
  }
}

Future<String> uploadImage(var imageFile) async {
  var uuid = Uuid().v1();
  Reference ref = FirebaseStorage.instance.ref().child(AppStrings.postIdFirebase(uuid: uuid));
  UploadTask uploadTask = ref.putFile(imageFile);
  String downloadUrl = await (await uploadTask).ref.getDownloadURL();
  return downloadUrl;
}

void postToFireStore({
  String? photo,
  String? location,
  String? description,
  BiuxUser? user,
  Member? member,
  int? selected,
  String? nameVal,
}) async {
  var reference = FirebaseFirestore.instance.collection(AppStrings.instaPosts);
  if (member != null && selected == 2) {
    Analitycs.postStory(
      member.group!.name!,
      member.group!.id!.toString(),
      AppStrings.group,
    );
    reference.add({
      AppStrings.user: user!.userName!,
      AppStrings.locationText: location,
      AppStrings.likes: {},
      AppStrings.photoText: photo,
      AppStrings.typeText: AppStrings.group,
      AppStrings.idGroup: member.group!.id!.toString(),
      AppStrings.description2: description,
      AppStrings.ownerIdText: '${member.group!.id!.toString()}G',
      AppStrings.timestamp: DateTime.now(),
      AppStrings.nameVal: nameVal,
      AppStrings.name: member.group!.name,
    }).then(
      (DocumentReference doc) {
        String docId = doc.id;
        reference.doc(docId).update(
          {
            AppStrings.postId: docId,
          },
        );
      },
    );
  } else {
    Analitycs.postStory(
      user!.userName!,
      user.id!,
      AppStrings.user,
    );
    reference.add({
      AppStrings.user: user.userName,
      AppStrings.locationText: location,
      AppStrings.likes: {},
      AppStrings.photoText: photo,
      AppStrings.description2: description,
      AppStrings.ownerIdText: '${user.id.toString()}U',
      AppStrings.timestamp: DateTime.now(),
      AppStrings.nameVal: nameVal,
      AppStrings.name: user.userName!,
    }).then(
      (DocumentReference doc) {
        String docId = doc.id;
        reference.doc(docId).update(
          {
            AppStrings.postId: docId,
          },
        );
      },
    );
  }
}
