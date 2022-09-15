import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/state.dart';
import 'package:biux/data/models/country.dart';
import 'package:biux/data/models/road.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';
import 'package:biux/data/repositories/members/members_repository.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/advertising/advertising_type_road.dart';
import 'package:biux/ui/screens/roads/ui/screens/create_road.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/repositories/roads/roads_repository.dart';
import 'button_road.dart';

class MenuRoads extends StatefulWidget {
  final int? indexPage;
  MenuRoads({this.indexPage});
  _MenuRoadsState createState() => _MenuRoadsState();
}

class _MenuRoadsState extends State<MenuRoads> {
  var _currentItemSelected = AppStrings.ibagueTolima;
  late List<Road> listRoads;
  ScrollController _scrollController = ScrollController();
  int offset = 1;
  int limit = 20;
  late BiuxUser _user;
  late String _city = "";
  late City cityData;
  late City city;
  String nofound = AppStrings.noRodadasAvailable;
  final cityController = TextEditingController();
  late List<String> listStringCities;
  late List<City> listCities;
  var cityId;
  var _group;

  void initState() {
    super.initState();
    listRoads = [];
    listStringCities = [];
    listCities = [];
    _user = BiuxUser();
    cityData = City();
    city = City(
      name: "",
      state: '0',
      id: '0',
    );
    _getUserData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        ++offset;
        _getMoreData();
      }
    });
  }

  _getUserData() async {
    Future.delayed(
      Duration.zero,
      () async {
        String? username = await LocalStorage().getUser();
        _user = await UserRepository().getPerson(username!);
        city = await UserRepository().getSpecifiCities(_user.cityId!);
        listRoads = await RoadsRepository().getRoads(
          limit,
          offset,
          _user.cityId!,
        );
        this.setState(
          () => {
            // listadoRodadas.sort((a, b) => a.fechaHora.compareTo(b.fechaHora)),
            // listadoRodadas.removeLast(),
          },
        );
        listCities = await UserRepository().getCities();
        setState(() {
          listCities.forEach(
            (e) => listStringCities.add(e.name),
          );
        });
        if (cityController.text == '') {
          cityController.text = city.name;
          cityId = city.id;
        }
        var nMember = await MembersRepository().getMyGroupsUser(_user.id!);
        _group = await GroupsRepository().getSpecificGroup(
          _user.groupId!,
        );
      },
    );
  }

  _getMoreData() async {
    List<Road> siguienteRodadas = await RoadsRepository().getRoads(
      limit,
      offset,
      cityId,
    );
    listRoads.addAll(siguienteRodadas);
    setState(() {});
  }

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: Scaffold(
        body: ListView(
          shrinkWrap: true,
          controller: _scrollController,
          children: <Widget>[
            Container(
              height: 20,
            ),
            Center(
              child: Text(
                AppStrings.rolled,
                style: Styles.centerText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                child: SimpleAutoCompleteTextField(
                  key: key,
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.black,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.black,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(
                      10.0,
                      15.0,
                      20.0,
                      15.0,
                    ),
                    hintText: AppStrings.selectCity,
                    prefixIcon: GestureDetector(
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.grey,
                      ),
                      onTap: () {
                        cityController..text = city.name;
                        setState(() {});
                      },
                    ),
                    hintStyle: Styles.sizedBoxHint,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                  ),
                  controller: cityController,
                  suggestions: listStringCities,
                  style: Styles.accentTextThemeBlack,
                  textChanged: (text) {
                    listStringCities.first = text;
                  },
                  clearOnSubmit: false,
                  textSubmitted: (text) => setState(
                    () async {
                      if (text != "") {
                        _city = text;
                        offset = 1;
                        cityData = await UserRepository().getCityId(text);
                        cityId = cityData.id;
                        listRoads = await RoadsRepository().getRoads(
                          limit,
                          offset,
                          cityData.id,
                        );
                        setState(() {});
                        List<Road> siguienteRodadas =
                            await RoadsRepository().getRoads(
                          limit,
                          offset,
                          cityData.id,
                        );
                        setState(() {});
                        listRoads.addAll(siguienteRodadas);
                        setState(() {});
                        if (cityData.name != "") {
                          _city = listStringCities.first;
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.red,
                              content: Text(
                                AppStrings.cityNotExist,
                                style: Styles.advertisingTitle,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                AdvertisingTypeRoad(
                  indexPage: widget.indexPage,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: Column(
                    children: _listRoads(listRoads
                        //.reversed.toList(),
                        ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: listRoads.isEmpty
                      ? Column(
                          children: [
                            Container(
                              child: Text(
                                nofound,
                                style: Styles.noGroupsTextBlack,
                              ),
                              height: 100,
                            ),
                            _user.cityId == cityId
                                ? FlatButton(
                                    color: AppColors.strongCyan,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        width: 3,
                                        color: AppColors.strongCyan,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.publishFirst,
                                      style: Styles.accentTextThemeWhite,
                                    ),
                                    onPressed: () async {
                                      _group != null
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        CreateRoad(),
                                              ),
                                            )
                                          : _validacionGroup();
                                      // Navigator.pop(context);
                                    },
                                  )
                                : Container()
                          ],
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: listRoads.length == 0
                              ? CircularProgressIndicator()
                              : Container(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _listRoads(List<Road> road) {
    List<Widget> listRoads = [];
    for (Road road in road) {
      listRoads.add(
        Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ), // set rounded corner radius
          ),
          child: ButtonRoad(
            road,
            _user,
            // posiblemente se tengo que llamar al grupo de la rodada
            Group(id: '')
          ),
        ),
      );
    }
    return listRoads;
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    offset = 1;
    listRoads = await RoadsRepository().getRoads(
      limit,
      offset,
      cityId,
    );
    this.setState(() => {});
    setState(() {});
  }

  void _onDropDownItemSelected(String newValueSelected) {
    setState(
      () {
        this._currentItemSelected = newValueSelected;
      },
    );
  }

  void _validacionGroup() {
    showDialog(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              width: 3,
              color: AppColors.greyishNavyBlue,
            ),
          ),
          content: Text(
            "",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppStrings.cancelText,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
                Container(
                  width: 20,
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      width: 3,
                      color: AppColors.greyishNavyBlue,
                    ),
                  ),
                  onPressed: () async {},
                  child: Text(
                    AppStrings.createGroupText,
                    style: Styles.accentTextThemeBlack,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
