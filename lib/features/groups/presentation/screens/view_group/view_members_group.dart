import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/groups/presentation/screens/view_group/view_group_bloc.dart';
import 'package:biux/shared/services/optimized_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ViewMembersGroup extends StatelessWidget {
  ViewMembersGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final bloc = context.watch<ViewGroupBloc>();
    return SingleChildScrollView(
      child: Column(
        children: bloc.listMember
            .map(
              (member) => GestureDetector(
                onTap: () {
                  // Navegar al perfil del usuario
                  context.push('/user-profile/${member.id}');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 20, left: 15),
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
                              placeholder: (context, url) => Container(
                                color: ColorTokens.neutral90,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: ColorTokens.neutral70,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
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
                      Expanded(
                        child: Container(
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
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorTokens.primary30,
                                      foregroundColor: ColorTokens.neutral100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      minimumSize: Size(80, 40),
                                    ),
                                    child: Text(
                                      l.t('view_profile'),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      context.push(
                                        '/user-profile/${member.id}',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Icono indicador de navegación
                      Container(
                        margin: EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.chevron_right,
                          color: ColorTokens.neutral60,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
