import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/groups/data/models/group.dart';
import 'package:biux/features/members/data/models/member.dart';
import 'package:biux/features/users/data/models/user.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupList extends StatelessWidget {
  final List<Group> groupList;
  final List<Member> listMembers;
  final BiuxUser user;
  final Function onTapLeave;
  final Function onTapJoin;
  final Function loadData;
  GroupList({
    Key? key,
    required this.groupList,
    required this.listMembers,
    required this.onTapLeave,
    required this.onTapJoin,
    required this.user,
    required this.loadData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 20,
          runSpacing: 15,
          children: groupList
              .map(
                (group) => Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      height: 170,
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorTokens.neutral60,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (group.name.length > 13)
                            Text(
                              group.name.replaceRange(
                                13,
                                group.name.length,
                                AppStrings.points,
                              ),
                              style: Styles.TextGroupList,
                            )
                          else
                            Text(group.name, style: Styles.TextGroupList),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                Images.kImageSocial,
                                color: ColorTokens.neutral0,
                                height: 20,
                              ),
                              const SizedBox(width: 15),
                              Text(
                                group.numberMembers.toString(),
                                style: Styles.TextGroupList,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.directions_bike,
                                  color: ColorTokens.neutral0,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                group.numberRoads.toString(),
                                style: Styles.TextGroupList,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 40, bottom: 50),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.viewGroupName,
                            arguments: {
                              'adminId': group.adminId,
                              'groupId': group.id,
                            },
                          );
                          loadData();
                        },
                        child: Container(
                          height: 86,
                          width: 85,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorTokens.neutral100,
                              width: 4,
                            ),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                group.logo,
                                cacheManager: OptimizedCacheManager.instance,
                              ),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                        ),
                      ),
                    ),
                    if (group.adminId == user.id)
                      Container(
                        margin: EdgeInsets.only(left: 23, top: 185),
                        child: ButtonTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          minWidth: 80,
                          height: 40,
                          child: ElevatedButtonTheme(
                            data: ElevatedButtonThemeData(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.only(left: 10, right: 10),
                                ),
                              ),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  ColorTokens.primary30,
                                ),
                              ),
                              child: Text(
                                l.t('edit_group'),
                                style: Styles.containerTextName,
                              ),
                              onPressed: () async {},
                            ),
                          ),
                        ),
                      )
                    else if (listMembers
                        .map((e) => e.groupId)
                        .contains(group.id))
                      Container(
                        margin: EdgeInsets.only(left: 26, top: 185),
                        child: ButtonTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          minWidth: 80,
                          height: 40,
                          child: ElevatedButtonTheme(
                            data: ElevatedButtonThemeData(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.only(left: 10, right: 10),
                                ),
                              ),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  ColorTokens.primary30,
                                ),
                              ),
                              child: Text(
                                l.t('leave_text'),
                                style: Styles.containerTextName,
                              ),
                              onPressed: () async {
                                List<Member> member = listMembers
                                    .where(
                                      (element) => element.groupId == group.id,
                                    )
                                    .toList();
                                onTapLeave(
                                  member.first.id,
                                  listMembers,
                                  group,
                                  group.numberMembers,
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: EdgeInsets.only(left: 40, top: 185),
                        child: ButtonTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          minWidth: 80,
                          height: 40,
                          child: ElevatedButtonTheme(
                            data: ElevatedButtonThemeData(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.only(left: 10, right: 10),
                                ),
                              ),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  ColorTokens.neutral100,
                                ),
                              ),
                              child: Text(
                                l.t('join_me'),
                                style: Styles.textLightBlack,
                              ),
                              onPressed: () async {
                                onTapJoin(
                                  Member(
                                    approved: true,
                                    groupId: group.id,
                                    userId: user.id,
                                  ),
                                  listMembers,
                                  group,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
