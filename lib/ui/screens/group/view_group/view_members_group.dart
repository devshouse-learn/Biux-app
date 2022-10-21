import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/ui/screens/group/view_group/view_group_bloc.dart';
import 'package:biux/ui/screens/zoom_screen/zoom_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewMembersGroup extends StatelessWidget {
  ViewMembersGroup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ViewGroupBloc>();
    return SingleChildScrollView(
      child: Wrap(
        children: bloc.listMember
            .map(
              (member) => Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 20, left: 15),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ZoomPage(
                                  member.photo,
                                  member.fullName,
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 1.0,
                                  color: AppColors.black,
                                )
                              ],
                              image: DecorationImage(
                                image: NetworkImage(member.photo),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, top: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              member.fullName,
                              style: Styles.TextGroupList,
                            ),
                            Text(
                              member.userName,
                              style: Styles.textLightBlack,
                            ),
                            Row(
                              children: [
                                ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  minWidth: 80,
                                  height: 40,
                                  child: RaisedButton(
                                    color: AppColors.darkBlue,
                                    child: Text(
                                      AppStrings.follow,
                                      style: Styles.containerTextName,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  minWidth: 80,
                                  height: 40,
                                  child: RaisedButton(
                                    color: AppColors.white,
                                    child: Text(
                                      AppStrings.deletedText,
                                      style: Styles.textLightBlack,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
