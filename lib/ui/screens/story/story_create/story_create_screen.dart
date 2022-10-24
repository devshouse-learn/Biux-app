import 'dart:io';
import 'package:biux/config/colors.dart';
import 'package:biux/config/images.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/data/models/story.dart';
import 'package:biux/data/repositories/authentication_repository.dart';
import 'package:biux/ui/screens/story/story_create/story_create_bloc.dart';
import 'package:biux/ui/widgets/tags_story_widgets.dart';
import 'package:biux/ui/widgets/text_form_field_biux_widget.dart';
import 'package:biux/utils/bytes_utils.dart';
import 'package:biux/utils/snackbar_utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class StoryCreateScreen extends StatelessWidget {
  const StoryCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppbarCreateStory(),
      body: Column(
        children: [
          Expanded(
            child: _CarouselImagesSelected(),
          ),
          Expanded(
            child: Consumer<StoryCreateBloc>(
              builder: (context, bloc, child) {
                return GallerySection(
                  imgList: bloc.imgList,
                  entitiesList: bloc.entitiesList,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GallerySection extends StatefulWidget {
  final List<AssetEntity> imgList;
  final List<AssetEntity> entitiesList;

  const GallerySection({
    Key? key,
    required this.imgList,
    required this.entitiesList,
  }) : super(key: key);

  @override
  _GallerySectionState createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  final int _sizePerPage = 50;
  AssetPathEntity? _path;
  int _totalEntitiesCount = 0;
  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  Future<void> _requestAssets() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    if (!ps.hasAccess) {
      setState(
        () {
          _isLoading = false;
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUtils.customSnackBar(
          content: AppStrings.permissionNotAccessibleCreateStory,
          backgroundColor: AppColors.darkBlue,
        ),
      );
      return;
    }
    await PhotoManager.clearFileCache();
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      filterOption: _filterOptionGroup,
      type: RequestType.image,
    );
    if (!mounted) {
      return;
    }
    if (paths.isEmpty) {
      setState(
        () {
          _isLoading = false;
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUtils.customSnackBar(
          content: AppStrings.pathsNotFoundCreateStory,
          backgroundColor: AppColors.darkBlue,
        ),
      );
      return;
    }
    setState(() {
      _path = paths.first;
    });
    _totalEntitiesCount = await _path!.assetCountAsync;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    Future.delayed(
      Duration.zero,
      () {
        final bloc = context.read<StoryCreateBloc>();
        setState(
          () {
            bloc.initialEntities(entitiesList: entities);
            _isLoading = false;
            _hasMoreToLoad = widget.entitiesList.length < _totalEntitiesCount;
          },
        );
      },
    );
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    Future.delayed(
      Duration.zero,
      () {
        final bloc = context.read<StoryCreateBloc>();
        setState(
          () {
            bloc.addAllEntities(entitiesList: entities);
            _page++;
            _hasMoreToLoad = widget.entitiesList.length < _totalEntitiesCount;
            _isLoadingMore = false;
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final bloc = context.watch<StoryCreateBloc>();
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    if (_path == null) {
      return const Center(
        child: Text(
          AppStrings.pathsRequestCreateStory,
        ),
      );
    }
    if (widget.entitiesList.isNotEmpty != true) {
      return const Center(
        child: Text(
          AppStrings.assetsNotFoundCreateStory,
        ),
      );
    }
    return GridView.custom(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == widget.entitiesList.length - 8 &&
              !_isLoadingMore &&
              _hasMoreToLoad) {
            _loadMoreAsset();
          }
          final AssetEntity entity = widget.entitiesList[index];
          return ImageItemWidget(
            key: ValueKey<int>(index),
            imgList: widget.imgList,
            entity: entity,
            onTap: () {
              if (widget.imgList.length < 3 ||
                  widget.imgList.contains(entity)) {
                if (widget.imgList.contains(entity)) {
                  bloc.deleteImageSeleted(image: entity);
                } else {
                  bloc.addImageSeleted(image: entity);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBarUtils.customSnackBar(
                    content: AppStrings.warnignNoMoreImages,
                    backgroundColor: AppColors.darkBlue,
                  ),
                );
              }
            },
            option: const ThumbnailOption(
              size: ThumbnailSize.square(200),
            ),
          );
        },
        childCount: widget.entitiesList.length,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<int>) {
            return key.value;
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }
}

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    Key? key,
    required this.entity,
    required this.option,
    required this.imgList,
    this.onTap,
  }) : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;
  final List<AssetEntity> imgList;

  Widget buildContent(BuildContext context) {
    return _buildImageWidget(
      context,
      entity,
      option,
    );
  }

  Widget _buildImageWidget(
    BuildContext context,
    AssetEntity entity,
    ThumbnailOption option,
  ) {
    final Widget image = AssetEntityImage(
      entity,
      isOriginal: false,
      thumbnailSize: option.size,
      thumbnailFormat: option.format,
      fit: BoxFit.cover,
    );
    final Widget imageStack = Stack(
      children: <Widget>[
        Positioned.fill(child: image),
        PositionedDirectional(
          top: 4,
          end: 4,
          child: Image.asset(
            Images.kDeselectedImage,
            height: 20,
            width: 20,
          ),
        ),
      ],
    );
    if (imgList.contains(entity)) {
      return Stack(
        children: <Widget>[
          Positioned.fill(child: image),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: Image.asset(
              Images.kSelectedImage,
              height: 20,
              width: 20,
            ),
          ),
        ],
      );
    }
    return imageStack;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: buildContent(context),
    );
  }
}

class _AppbarCreateStory extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StoryCreateBloc>();
    return AppBar(
      backgroundColor: AppColors.darkBlue,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
        ),
        onPressed: () {},
      ),
      title: Text(
        AppStrings.titleAppBarCreateStory,
        style: Styles.noDateText,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
          ),
          onPressed: () {
            if (bloc.imgList.isNotEmpty) {
              showDialogCreateStory(
                context: context,
                onSave: (listTags, description) async {
                  final userId = AuthenticationRepository().getUserId;
                  final user = await bloc.getUser(id: userId);
                  final creationDate = DateTime.now();
                  final story = Story(
                    description: description,
                    tags: listTags,
                    creationDate: creationDate.toString(),
                    user: user,
                  );
                  final result = await bloc.createStory(
                    story: story,
                    list: bloc.imgList,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBarUtils.customSnackBar(
                      content: result
                          ? AppStrings.textSuccessfulCreateStory
                          : AppStrings.textErrorCreateStory,
                      backgroundColor:
                          result ? AppColors.strongCyan : AppColors.redAccent,
                    ),
                  );
                  if (result) {
                    Navigator.pop(context, true);
                  }
                },
              );
            }
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}

class _CarouselImagesSelected extends StatelessWidget {
  _CarouselImagesSelected({Key? key}) : super(key: key);

  final CarouselController _controller = CarouselController();
  final ImagePicker _picker = ImagePicker();

  void _takePhoto({required StoryCreateBloc bloc}) async {
    XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null && pickedFile.path != null) {
      final fileBytes = await pickedFile.readAsBytes();
      final entity = await PhotoManager.editor.saveImage(
        fileBytes,
        title: pickedFile.name,
      );
      bloc.addEntity(entity: entity!);
      bloc.addImageSeleted(image: entity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StoryCreateBloc>();
    final sizeScreen = MediaQuery.of(context).size;
    final List<Widget> imageSliders = bloc.imgList
        .map(
          (item) => Container(
            child: StreamBuilder<Object>(
              stream: null,
              builder: (context, snapshot) {
                final sizeScreen = MediaQuery.of(context).size;
                return Stack(
                  children: <Widget>[
                    AssetEntityImage(
                      item,
                      width: sizeScreen.width,
                      fit: BoxFit.cover,
                    ),
                  ],
                );
              },
            ),
          ),
        )
        .toList();
    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            items: imageSliders,
            carouselController: _controller,
            options: CarouselOptions(
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              initialPage: 0,
              enlargeCenterPage: false,
              height: sizeScreen.height * 0.5,
              onPageChanged: (index, reason) {
                bloc.changeCurrent(current: index);
              },
            ),
          ),
        ),
        ColoredBox(
          color: AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bloc.imgList.asMap().entries.map(
                  (entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        margin: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 4.0,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.black,
                          ),
                          color: (bloc.current == entry.key
                              ? AppColors.strongCyan
                              : AppColors.darkBlue),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.galleryCreateStory,
                      style: Styles.titleGallery,
                    ),
                    if (bloc.imgList.length < 3)
                      CircleAvatar(
                        backgroundColor: AppColors.darkBlue,
                        child: IconButton(
                          color: AppColors.white,
                          onPressed: () async {
                            _takePhoto(bloc: bloc);
                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                          ),
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

void showDialogCreateStory({
  required context,
  required Function(List<String>, String) onSave,
}) async {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _labelsController = TextEditingController();
  final List<String> listTags = [];
  return await showDialog(
    context: context,
    builder: (context) {
      final sizeScreen = MediaQuery.of(context).size;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.zero,
            alignment: Alignment.bottomCenter,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            scrollable: true,
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormFieldBiuxWidget(
                      text: AppStrings.descriptionStory,
                      controller: _descriptionController,
                      padding: const EdgeInsets.all(10),
                      maxLine: 6,
                      radiusCircular: 20,
                      autofocus: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppStrings.textValidatorDescriptionStory;
                        }
                        return null;
                      },
                    ),
                    TextFormFieldBiuxWidget(
                      text: AppStrings.tagsStory,
                      controller: _labelsController,
                      padding: const EdgeInsets.all(10),
                      radiusCircular: 20,
                      onFieldSubmitted: (value) => listTags.add(value),
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: listTags
                          .map(
                            (e) => TagsStoryWidget(
                              labelText: e,
                              onPressed: () => setState(
                                () => listTags.removeWhere(
                                  (element) => element == e,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 250,
                        child: TextButton(
                          style: Styles().textButtonStyle,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              onSave(
                                listTags,
                                _descriptionController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            AppStrings.postText,
                            style: Styles.containerNameUser,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: sizeScreen.width,
              ),
            ],
          );
        },
      );
    },
  );
}
