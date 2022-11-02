import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/group.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/group/group_list/group_list_screen_bloc.dart';
import 'package:biux/ui/screens/roads/roads_list/roads_list_screen_bloc.dart';
import 'package:biux/ui/widgets/list_group_widget.dart';
import 'package:biux/ui/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GroupListScreen extends StatelessWidget {
  GroupListScreen({Key? key}) : super(key: key);

  systemNavigator() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GroupListScreenBloc>();
    return WillPopScope(
      onWillPop: bloc.willPopScope,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: ListView(
          padding: const EdgeInsets.all(
            8.0,
          ),
          children: [
            Selector<GroupListScreenBloc, FocusNode>(
                selector: (_, bloc) => bloc.focusNodeCity,
                builder: (context, value, child) {
                  return WidgetSearchCity();
                }),
            if (bloc.focusNodeCity.hasFocus)
              ListCity(
                listCities: bloc.listCities,
              )
            else ...[
              SearchBarWidget(),
              Selector<GroupListScreenBloc, List<Member>>(
                selector: (_, bloc) => bloc.listMembers,
                builder: (context, listMembers, child) {
                  return GroupList(
                    groupList: bloc.listGroup,
                    listMembers: bloc.listMembers,
                    onTapJoin: bloc.onTapJoin,
                    onTapLeave: bloc.onTapLeave,
                    user: bloc.user,
                    loadData: bloc.loadData,
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class WidgetSearchCity extends StatelessWidget {
  WidgetSearchCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GroupListScreenBloc>();
    return Container(
        width: 350,
        margin: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: AppColors.gray,
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: bloc.searchCityController,
          onTap: bloc.setState,
          style: Styles.TextCityList,
          focusNode: bloc.focusNodeCity,
          onChanged: (value) {
            bloc.filterCities();
            if (bloc.searchCityController.text.isEmpty) bloc.getGroupList();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(
              10.0,
              15.0,
              20.0,
              15.0,
            ),
            border: InputBorder.none,
            hintText: AppStrings.searchCitie,
            hintStyle: Styles.TextSearch,
            prefixIcon: Image.asset(
              Images.kImageLocationGrey,
              height: 10,
              scale: 3.0,
            ),
            suffixIcon: bloc.focusNodeCity.hasFocus
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.gray,
                    ),
                    onPressed: () {
                      bloc.searchCityController.clear();
                      bloc.getGroupList();
                      bloc.getCities();
                      bloc.focusNodeCity.unfocus();
                      bloc.setState();
                    },
                  )
                : const SizedBox(),
          ),
        ));
  }
}

class ListCity extends StatelessWidget {
  List<City> listCities = [];
  ListCity({Key? key, required this.listCities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GroupListScreenBloc>();
    return Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(
              left: 25,
            ),
            horizontalTitleGap: 0,
            minLeadingWidth: 36,
            iconColor: AppColors.black,
            leading: Image.asset(
              Images.kImageLocation2,
              height: 20,
            ),
            title: Text(
              AppStrings.currentLocation,
              style: Styles.TextCityList,
            ),
            onTap: () {},
          ),
          Divider(
            color: AppColors.gray,
            height: 1,
          ),
          SingleChildScrollView(
            child: Wrap(
              children: listCities
                  .map(
                    (city) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(
                            left: 60,
                          ),
                          title: Text(
                            city.name,
                            style: Styles.TextCityList,
                          ),
                          onTap: () {
                            bloc.onTapCities(
                              city.name,
                            );
                          },
                        ),
                        Divider(
                          color: AppColors.gray,
                          height: 1,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
