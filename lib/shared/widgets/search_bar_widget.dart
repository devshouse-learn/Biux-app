import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/groups/presentation/screens/group_list/group_list_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorTokens.neutral60,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: bloc.searchGroupController,
        onChanged: (value) {
          bloc.filterCroup();
        },
        onTap: bloc.setState,
        focusNode: bloc.focusNodeGrupo,
        style: Styles.TextCityList,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
            10.0,
            15.0,
            20.0,
            15.0,
          ),
          border: InputBorder.none,
          hintText: AppStrings.search,
          hintStyle: Styles.TextSearch,
          prefixIcon: Icon(
            Icons.search,
            color: ColorTokens.neutral60,
          ),
          suffixIcon: bloc.focusNodeGrupo.hasFocus
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ColorTokens.neutral60,
                  ),
                  onPressed: () {
                    bloc.searchGroupController.clear();
                    bloc.getGroupList();
                    bloc.focusNodeGrupo.unfocus();
                    bloc.setState();
                  },
                )
              : SizedBox(),
        ),
      ),
    );
  }
}


