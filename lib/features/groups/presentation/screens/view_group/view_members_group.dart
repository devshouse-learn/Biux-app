import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/groups/presentation/screens/view_group/view_group_bloc.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewMembersGroup extends StatelessWidget {
  ViewMembersGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ViewGroupBloc>();
    return SingleChildScrollView(
      child: Column(
        children:
            bloc.listMember
                .map(
                  (member) => Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(top: 20, left: 15),
                          child: GestureDetector(
                            onTap: () {
                              final imageProvider = CachedNetworkImageProvider(
                                member.photo,
                                cacheManager:
                                    OptimizedCacheManager.avatarInstance,
                              );
                              showImageViewer(
                                context,
                                imageProvider,
                                backgroundColor: ColorTokens.neutral40,
                                useSafeArea: true,
                                immersive: false,
                              );
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorTokens.neutral100,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 1.0,
                                    color: ColorTokens.neutral0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: member.photo,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  cacheManager:
                                      OptimizedCacheManager.avatarInstance,
                                  placeholder:
                                      (context, url) => Container(
                                        color: ColorTokens.neutral90,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: ColorTokens.neutral70,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: ColorTokens.neutral90,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: ColorTokens.neutral70,
                                        ),
                                      ),
                                ),
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
                                    child: ElevatedButton(
                                      child: Text(
                                        AppStrings.follow,
                                        style: Styles.containerTextName,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ButtonTheme(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    minWidth: 80,
                                    height: 40,
                                    child: ElevatedButton(
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
                  ),
                )
                .toList(),
      ),
    );
  }
}
