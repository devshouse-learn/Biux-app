import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';
import 'package:biux/ui/screens/home.dart';
import 'package:biux/ui/widgets/loading_widget.dart';
import 'package:biux/ui/widgets/textField_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditGroups extends StatefulWidget {
  final Group _groups;
  final BiuxUser admin;

  EditGroups(this._groups, this.admin);
  _EditGroupsState createState() => _EditGroupsState();
}

class _EditGroupsState extends State<EditGroups> {
  final formKey = GlobalKey<FormState>();
  late BiuxUser _user;
  late String _name;
  late String _description;
  late String _whatsapp;
  late String _facebook;
  late String _instagram;
  late String _city;
  int size = 30;
  var response;
  bool isLoggedIn = false;
  List<bool> isSelected = [false, true, false, true];
  late String _myActivity;
  late String _myActivity2;
  late String _myActivity3;
  late Group _grupo;
  String instagram = Images.kInstagramLogo;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final whatsappController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  bool loanding = false;
  var _image2;
  var _image;

  final GlobalKey<ScaffoldState> _scaffolState = GlobalKey<ScaffoldState>();

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  void initState() {
    super.initState();
    nameController.text = widget._groups.name;
    whatsappController.text = widget._groups.whatsapp;
    facebookController.text = widget._groups.facebook;
    instagramController.text = widget._groups.instagram;
    descriptionController.text = widget._groups.description;
  }

  final _formKey = GlobalKey<FormState>();
  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(
        () {
          _image = image;
        },
      );
    }
  }

  Future getImageProfileCover() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = (await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30))!;
    File image = File(pickedFile.path);
    if (image != null) {
      setState(
        () {
          _image2 = image;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffolState,
      backgroundColor: AppColors.darkBlue,
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.kBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 0, left: 0),
                    height: 150,
                    width: 400,
                    child: Stack(
                      children: <Widget>[
                        _image2 != null
                            ? Container(
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image: FileImage(
                                      _image2.path != null ? _image2 : _image2,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 150,
                                width: 400,
                              )
                            : Container(
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image: NetworkImage(
                                      widget._groups.profileCover == null
                                          ? AppStrings.urlBiuxApp
                                          : widget._groups.profileCover,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 150,
                                width: 400,
                              ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 18.0,
                            right: 20,
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 40,
                              width: 120,
                              child: RaisedButton(
                                color: AppColors.strongCyan,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(
                                    width: 3,
                                    color: AppColors.strongCyan,
                                  ),
                                ),
                                child: Text(
                                  "Subir Portada",
                                  style: Styles.uploadProfileCoverText,
                                ),
                                onPressed: getImageProfileCover,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 20),
                              child: GestureDetector(
                                  child: Icon(
                                    Icons.arrow_back_outlined,
                                    size: 30,
                                    color: AppColors.white,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  }),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20, left: 10),
                              child: Text(
                                AppStrings.uploadCover,
                                textAlign: TextAlign.center,
                                style: Styles.createGroupText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Stack(
                            //   alignment: Alignment.center,
                            children: [
                              Center(
                                child: Container(
                                  height: 520,
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
                                        Padding(
                                          padding: EdgeInsets.only(top: 20),
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[0],
                                          nameController: nameController,
                                          text: AppStrings.nameText,
                                          icon: Icon(
                                            Icons.person_outline,
                                            color: AppColors.gray,
                                          ),
                                          validator: (value) {},
                                        ),
                                        SizedBox(
                                          height: 88,
                                          child: TexFieldWidget(
                                            obscureText: false,
                                            keyboardType: TextInputType.number,
                                            maxLength: 10,
                                            focusNode: _focusNodes[2],
                                            nameController: whatsappController,
                                            text: AppStrings.WhatsappText,
                                            icon: Icon(
                                              Icons.phone_outlined,
                                              color: AppColors.gray,
                                            ),
                                            validator: (value) {},
                                          ),
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          color: AppColors.black,
                                          focusNode: _focusNodes[3],
                                          nameController: facebookController,
                                          text: AppStrings.facebookText,
                                          icon: Icon(
                                            Icons.facebook,
                                            color: AppColors.gray,
                                          ),
                                          validator: (value) {
                                            if (facebookController.text == '') {
                                              _facebook =
                                                  AppStrings.notRegistered;
                                            } else if (facebookController.text
                                                .contains(
                                                    AppStrings.urlFacebook)) {
                                              _facebook =
                                                  facebookController.text;
                                            } else {
                                              _facebook =
                                                  AppStrings.notRegistered;
                                            }
                                          },
                                        ),
                                        TexFieldWidget(
                                          obscureText: false,
                                          focusNode: _focusNodes[4],
                                          nameController: instagramController,
                                          text: AppStrings.instagramText,
                                          icon: Image.asset(
                                            instagram,
                                            scale: 30,
                                          ),
                                          validator: (value) {
                                            if (instagramController.text ==
                                                '') {
                                              _instagram =
                                                  AppStrings.notRegistered;
                                            } else {
                                              _instagram =
                                                  instagramController.text;
                                            }
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 320,
                                                height: 120,
                                                child: TextFormField(
                                                  maxLines: 5,
                                                  controller:
                                                      descriptionController,
                                                  focusNode: _focusNodes[1],
                                                  style: Styles.sizedBox,
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
                                                        20,
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
                                                    hintText: AppStrings
                                                        .descriptionText,
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
                                                        Radius.circular(15),
                                                      ),
                                                    ),
                                                    hintStyle: Styles
                                                        .sizedBoxHintStyle,
                                                  ),
                                                  maxLength: 600,
                                                  validator: (value) {},
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                            margin: EdgeInsets.only(top: 525),
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
                                      )
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.strongCyan,
                                    ),
                                    height: 70,
                                    width: 70,
                                    child: new Stack(
                                      children: <Widget>[
                                        Center(
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
                            if (widget._groups.logo != null || _image != null) {
                              if (widget._groups.profileCover != null ||
                                  _image2 != null) {
                                if (_formKey.currentState!.validate() &&
                                        facebookController.text
                                            .contains(AppStrings.urlFacebook) ||
                                    _facebook.contains(
                                            AppStrings.notRegistered) &&
                                        whatsappController.text.length == 10) {
                                  setState(() {
                                    loanding = true;
                                  });
                                  var group = Group(
                                    id: widget._groups.id,
                                    cityAdmin: widget.admin.cityId!
                                        .toString(),
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    whatsapp: whatsappController.text,
                                    type: true,
                                    cityId: widget.admin.cityId!,
                                    adminId: widget.admin.id!,
                                    facebook: _facebook,
                                    instagram: _instagram,
                                    modality: modalityToList(isSelected),
                                  );
                                  response =
                                      await GroupsRepository().updateGroup(
                                    group,
                                  );
                                  if (_image != null) {
                                    await GroupsRepository().uploadLogoGroup(
                                      widget._groups.id,
                                      _image,
                                    );
                                    uploadImage(_image).then(
                                      (data) {
                                        postToFireStore(
                                          photo: data,
                                          userId: AppStrings.idGFirebase(
                                              id: widget._groups.id
                                                  .toString()),
                                        );
                                      },
                                    );
                                  }
                                  Future.delayed(Duration(seconds: 1), () {
                                    if (_image2 != null) {
                                      GroupsRepository()
                                          .uploadGroupProfileCover(
                                        widget._groups.id,
                                        _image2,
                                      );
                                    }
                                  });
                                  _showDialog();
                                  Future.delayed(
                                    Duration(seconds: 2),
                                    () {
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) => MyHome(),
                                              ),
                                              (Route<dynamic> route) => false)
                                          .then((value) => setState(() => {}));
                                    },
                                  );
                                } else {
                                  setState(() {
                                    loanding = false;
                                  });
                                  Future.delayed(Duration(milliseconds: 5), () {
                                    _showDialog2(
                                      nameController.text.isEmpty
                                          ? AppStrings.textErrorName
                                          : whatsappController.text.isEmpty
                                              ? AppStrings.textErrorWhatsapp
                                              : whatsappController.text.length <
                                                      10
                                                  ? AppStrings
                                                      .textErrorWhatsapp2
                                                  : facebookController.text !=
                                                          AppStrings.urlFacebook
                                                      ? AppStrings
                                                          .textErrorFacebook
                                                      : descriptionController
                                                                  .text ==
                                                              ""
                                                          ? AppStrings
                                                              .textErrorDescription
                                                          : descriptionController
                                                                      .text
                                                                      .length <
                                                                  20
                                                              ? AppStrings
                                                                  .textErrorDescription
                                                              : AppStrings
                                                                  .textErrorCheck,
                                    );
                                  });
                                }
                              } else {
                                setState(() {
                                  loanding = false;
                                });
                                Future.delayed(Duration(milliseconds: 5), () {
                                  _showDialog2(AppStrings.textErrorCoverGroup);
                                });
                              }
                            } else {
                              setState(() {
                                loanding = false;
                              });
                              Future.delayed(Duration(milliseconds: 5), () {
                                _showDialog2(AppStrings.textErrorImageGroup);
                              });
                            }
                          },
                        ),
                        Align(
                          alignment: Alignment(0.0, 3.8),
                          child: GestureDetector(
                            child: Material(
                              elevation: 20,
                              borderRadius: BorderRadius.circular(55.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: AppColors.white,
                                          spreadRadius: 5)
                                    ]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.strongCyan,
                                  ),
                                  height: 110,
                                  width: 110,
                                  child: _image == null
                                      ? InkWell(
                                          child: new Container(
                                            alignment: (Alignment(-1.0, 2.5)),
                                            decoration: new BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  widget._groups.logo,
                                                ),
                                              ),
                                              borderRadius:
                                                  new BorderRadius.all(
                                                const Radius.circular(
                                                  80.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            getImageFromGallery();
                                          })
                                      : InkWell(
                                          child: Container(
                                            alignment: (Alignment(-1.0, 2.5)),
                                            decoration: new BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: FileImage(_image),
                                              ),
                                              borderRadius:
                                                  new BorderRadius.all(
                                                const Radius.circular(80.0),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            getImageFromGallery();
                                          },
                                        ),
                                ),
                              ),
                            ),
                            onTap: () {
                              getImageFromGallery();
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 500,
                          left: 86,
                          right: 0,
                          child: Align(
                            alignment: Alignment(0.0, 0.0),
                            child: Material(
                              elevation: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.white,
                                      spreadRadius: 6,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.strongCyan,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loanding == true ? Loading() : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    Future.delayed(
      Duration.zero,
      () {
        _scaffolState.currentState!.showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            backgroundColor: AppColors.strongCyan,
            content: Text(
              AppStrings.updatedGroupText,
              style: Styles.advertisingTitle,
            ),
          ),
        );
      },
    );
  }

  void _showDialog2(String response) {
    // flutter defined function
    Future.delayed(
      Duration.zero,
      () {
        _scaffolState.currentState!.showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            backgroundColor: AppColors.red,
            content: Text(
              response,
              style: Styles.advertisingTitle,
            ),
          ),
        );
      },
    );
  }

  Future<String> uploadImage(var imageFile) async {
    var uid = Uuid().v1();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(AppStrings.postIdFirebase(uuid: uid));
    UploadTask uploadTask = ref.putFile(imageFile);

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  void postToFireStore({String? photo, String? userId}) async {
    FirebaseFirestore.instance
        .collection(AppStrings.instaUsers)
        .doc(userId)
        .update(
      {AppStrings.photoText: photo},
    );
  }

  List modalityToList(List selecciones) {
    List modality = [];
    if (selecciones[0]) {
      modality.add(AppStrings.urbanoText);
    }
    if (selecciones[1]) {
      modality.add(AppStrings.dowhillText);
    }
    if (selecciones[2]) {
      modality.add(AppStrings.MTBText);
    }
    if (selecciones[3]) {
      modality.add(AppStrings.rutaText);
    }
    return modality;
  }
}
