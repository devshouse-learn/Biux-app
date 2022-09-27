import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/repositories/users/user_repository.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/ui/screens/group/ui/screens/groups_screen.dart';
import 'package:flutter/material.dart';
import 'package:biux/data/repositories/groups/groups_repository.dart';

class GroupsList extends StatefulWidget {
  final int? id;
  final VoidCallback? onReassemble;
  GroupsList({
    this.id,
    this.onReassemble,
  });
  _GruposListaState createState() => _GruposListaState();
}

class _GruposListaState extends State<GroupsList> {
  late BiuxUser _user;
  late String _city = "";
  late City cityData;
  late City city;
  late String username;
  late bool valCity = false;
  late List<Group> listGroups;
  List<Group> filteredList = [];
  final cityController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  TextEditingController controller = new TextEditingController();
  // getUserProfile() async {
  //   String? username = await LocalStorage().obtenerUsuario();

  //   user = await UsuariosRepositorio().obtenerPersona(username!);
  // }

  // getUserProfile() {
  //   Future.delayed(Duration.zero, () {
  //     setState(() async {

  //     });
  //   });
  // }
  late List<String> listStringCities;
  late List<City> listCities;
  void initState() {
    super.initState();
    _user = BiuxUser();
    cityData = City();
    city = City();
    listGroups = [];
    listCities = [];
    listStringCities = [];
    Future.delayed(Duration.zero, () async {
      String? username = await LocalStorage().getUser();
      _user = await UserRepository().getPerson(username!);
      city = await UserRepository().getSpecifiCities(_user.cityId);

      listGroups = await GroupsRepository().getGroups(
        valCity == false ? city.name : _city,
      );
      this.setState(() {
        listGroups.sort(
          (a, b) => a.numberMembers.compareTo(b.numberMembers),
        );
      });
      filteredList = await GroupsRepository().getGroups(
        valCity == false ? city.name : _city,
      );
      this.setState(() {
        filteredList.sort(
          (a, b) => a.numberMembers.compareTo(b.numberMembers),
        );
      });
      listCities = await UserRepository().getCities();
      setState(() {
        listCities.forEach(
          (e) => listStringCities.add(e.name),
        );
      });
      if (cityController.text == '') {
        cityController.text = city.name;
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //   _getMoreData();
      }
    });
  }

  onItemChanged(String value) {
    setState(() {
      filteredList = listGroups
          .where((string) =>
              string.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          Container(
            height: 20,
          ),
          Center(
            child: Text(
              AppStrings.gruposText,
              style: Styles.centerText,
            ),
          ),
          Container(
            height: 5,
          ),
          Column(
            children: <Widget>[
              SizedBox(
                width: 320,
                child: SimpleAutoCompleteTextField(
                  key: key,
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.black)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.black),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                    hintText: AppStrings.selectCity,
                    prefixIcon: GestureDetector(
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.gray,
                      ),
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
                      setState(() async {
                        listGroups = await GroupsRepository()
                            .getGroups(cityController.text);
                        this.setState(() {
                          listGroups.sort((a, b) =>
                              a.numberMembers.compareTo(b.numberMembers));
                        });
                        filteredList = await GroupsRepository()
                            .getGroups(cityController.text);
                        this.setState(() {
                          filteredList.sort((a, b) =>
                              a.numberMembers.compareTo(b.numberMembers));
                        });
                      });
                      if (text != "") {
                        _city = text;
                        cityData = await UserRepository().getCityId(text);
                        if (cityData.name != "") {
                          _city = listStringCities.first;
                        }
                      }
                    },
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  onChanged: onItemChanged,
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: AppStrings.searchGroups,
                    hintText: "",
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.gray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Column(),
              ),
              //  PublicidadTipoGrupo(),
              Column(
                children: _listGroups(filteredList.reversed.toList()),
              ),
              Align(
                alignment: Alignment.center,
                child: filteredList.isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(
                                child: Text(
                                  AppStrings.firstCreateGroupText,
                                  style: Styles.fontWeightBold,
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container(),
              ),
            ],
          )
        ],
      ),
    );
  }

  _listGroups(List<Group> group) {
    List<Widget> listGroups = [];

    for (Group group in group) {
      listGroups.add(
        Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: GroupsScreen(
            group,
          ),
        ),
      );
    }

    return listGroups;
  }

  // Future<void> _pullRefresh() async {
  //   listadoGrupos = [];

  //   listadoGrupos = await GruposRepositorio().obtenerGrupos(_user.ciudadId!);
  //   setState(() {
  //     listadoGrupos
  //         .sort((a, b) => a.numeroMiembros!.compareTo(b.numeroMiembros!));
  //   });

  //   filteredList = await GruposRepositorio().obtenerGrupos(_user.ciudadId!);
  //   setState(() {
  //     filteredList
  //         .sort((a, b) => a.numeroMiembros!.compareTo(b.numeroMiembros!));
  //   });

  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels ==
  //         _scrollController.position.maxScrollExtent) {
  //       //   _getMoreData();
  //     }
  //   });

  //   this.setState(() => {});
  // }
}
