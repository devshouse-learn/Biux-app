import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/router/router_path.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/member.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/ui/screens/group/my_groups/my_groups_bloc.dart';
import 'package:biux/ui/widgets/list_group_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyGroupsScreen extends StatelessWidget {
  const MyGroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MyGroupsBloc>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _AppBarMyGroups(user: bloc.user, loadData: bloc.getGroups),
      body: ListView(
        padding: const EdgeInsets.all(
          8.0,
        ),
        children: [
          Selector<MyGroupsBloc, List<Member>>(
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
        ],
      ),
    );
  }
}

class _AppBarMyGroups extends StatelessWidget implements PreferredSizeWidget {
  BiuxUser user;
  final Function loadData;
  _AppBarMyGroups({Key? key, required this.user, required this.loadData})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBlue,
      title: Row(
        children: [
          Text(
            '${AppStrings.MyGroupText} ',
          ),
          Text(
            AppStrings.APP_NAME.toUpperCase(),
            style: Styles.mainMenuTextBiux,
          ),
        ],
      ),
      actions: [
        if (user.groupId.isEmpty)
          Container(
            height: 32,
            width: 32,
            margin: EdgeInsets.only(
              right: 30,
            ),
            child: GestureDetector(
              onTap: () async {
                Navigator.pushNamed(
                  context,
                  AppRoutes.groupCreateRoute,
                );
                loadData();
              },
              child: Image.asset(
                Images.kImageAdd,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        60,
      );
}
