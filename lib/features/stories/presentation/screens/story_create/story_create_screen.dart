import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/config/styles.dart';
import 'package:biux/features/stories/data/models/story.dart';
import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';
import 'package:biux/features/stories/presentation/screens/story_create/story_create_bloc.dart';
import 'package:biux/core/utils/snackbar_utils.dart';
import 'package:biux/shared/widgets/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

class StoryCreateScreen extends StatelessWidget {
  const StoryCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppbarCreateStory(),
      body: Column(
        children: [
          Expanded(child: _CarouselImagesSelected()),
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
    setState(() {
      _isLoading = true;
    });
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    if (!ps.hasAccess) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUtils.customSnackBar(
          content: AppStrings.permissionNotAccessibleCreateStory,
          backgroundColor: ColorTokens.primary30,
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
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarUtils.customSnackBar(
          content: AppStrings.pathsNotFoundCreateStory,
          backgroundColor: ColorTokens.primary30,
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
    Future.delayed(Duration.zero, () {
      final bloc = context.read<StoryCreateBloc>();
      setState(() {
        bloc.initialEntities(entitiesList: entities);
        _isLoading = false;
        _hasMoreToLoad = widget.entitiesList.length < _totalEntitiesCount;
      });
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    Future.delayed(Duration.zero, () {
      final bloc = context.read<StoryCreateBloc>();
      setState(() {
        bloc.addAllEntities(entitiesList: entities);
        _page++;
        _hasMoreToLoad = widget.entitiesList.length < _totalEntitiesCount;
        _isLoadingMore = false;
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    final bloc = context.watch<StoryCreateBloc>();
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_path == null) {
      return const Center(child: Text(AppStrings.pathsRequestCreateStory));
    }
    if (widget.entitiesList.isNotEmpty != true) {
      return const Center(child: Text(AppStrings.assetsNotFoundCreateStory));
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
                    backgroundColor: ColorTokens.primary30,
                  ),
                );
              }
            },
            option: const ThumbnailOption(size: ThumbnailSize.square(200)),
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
    return _buildImageWidget(context, entity, option);
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
          child: Image.asset(Images.kDeselectedImage, height: 20, width: 20),
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
            child: Image.asset(Images.kSelectedImage, height: 20, width: 20),
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
      backgroundColor: ColorTokens.primary30,
      leading: IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
      title: Text(
        AppStrings.titleAppBarCreateStory,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ColorTokens.primary30,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: Icon(Icons.check, size: 20),
            label: Text(
              'Publicar',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            onPressed: () {
              if (bloc.imgList.isNotEmpty) {
                showDialogCreateStory(
                  context: context,
                  onSave: (description, isAdvertisement) async {
                    final userId = AuthenticationRepository().getUserId;
                    final user = await bloc.getUser(id: userId);
                    final creationDate = DateTime.now();
                    final story = Story(
                      description: description,
                      tags: [],
                      creationDate: creationDate.toString(),
                      user: user,
                      isAdvertisement: isAdvertisement,
                    );
                    bloc.changeLoading(true);
                    final result = await bloc.createStory(
                      story: story,
                      list: bloc.imgList,
                    );
                    bloc.changeLoading(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBarUtils.customSnackBar(
                        content: result
                            ? AppStrings.textSuccessfulCreateStory
                            : AppStrings.textErrorCreateStory,
                        backgroundColor: result
                            ? ColorTokens.secondary50
                            : ColorTokens.error50,
                      ),
                    );
                    if (result) {
                      Navigator.pop(context, true);
                    }
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBarUtils.customSnackBar(
                    content: 'Selecciona al menos una foto',
                    backgroundColor: ColorTokens.error50,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}

class _CarouselImagesSelected extends StatelessWidget {
  _CarouselImagesSelected({Key? key}) : super(key: key);

  final CarouselSliderController _controller = CarouselSliderController();
  final ImagePicker _picker = ImagePicker();

  void _takePhoto({required StoryCreateBloc bloc}) async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();
      final entity = await PhotoManager.editor.saveImage(
        fileBytes,
        title: pickedFile.name,
        filename: pickedFile.name,
      );
      bloc.addEntity(entity: entity);
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
            width: sizeScreen.width,
            height: sizeScreen.height * 0.5,
            color: Colors.black,
            child: Center(
              child: AssetEntityImage(
                item,
                width: sizeScreen.width,
                height: sizeScreen.height * 0.5,
                fit: BoxFit.contain,
                isOriginal: false,
              ),
            ),
          ),
        )
        .toList();

    // Mostrar placeholder cuando no hay imágenes seleccionadas
    if (bloc.imgList.isEmpty) {
      imageSliders.add(
        Container(
          width: sizeScreen.width,
          height: sizeScreen.height * 0.5,
          color: Colors.grey[900],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 80,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Selecciona hasta 3 fotos',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                child: CarouselSlider(
                  items: imageSliders,
                  carouselController: _controller,
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enlargeCenterPage: false,
                    aspectRatio: 1.0,
                    onPageChanged: (index, reason) {
                      bloc.changeCurrent(current: index);
                    },
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: ColorTokens.neutral100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bloc.imgList.asMap().entries.map((entry) {
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
                            border: Border.all(color: ColorTokens.neutral0),
                            color: (bloc.current == entry.key
                                ? ColorTokens.secondary50
                                : ColorTokens.primary30),
                          ),
                        ),
                      );
                    }).toList(),
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
                            backgroundColor: ColorTokens.primary30,
                            child: IconButton(
                              color: ColorTokens.neutral100,
                              onPressed: () async {
                                _takePhoto(bloc: bloc);
                              },
                              icon: Icon(Icons.camera_alt_outlined),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (bloc.loading) Loading(),
      ],
    );
  }
}

void showDialogCreateStory({
  required context,
  required Function(String, bool) onSave,
}) async {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isAdvertisement = false;

  return await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ColorTokens.neutral100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.bottomCenter,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del diálogo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: ColorTokens.primary30,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Crear Historia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.primary30,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Campo de descripción
                    TextFormFieldBiuxWidget(
                      text: AppStrings.descriptionStory,
                      controller: _descriptionController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      maxLine: 6,
                      radiusCircular: 12,
                      autofocus: true,
                      validator: (value) {
                        // Descripción es opcional
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Sección de Publicidad con diseño innovador
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isAdvertisement
                              ? [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA500),
                                ] // Oro a naranja
                              : [ColorTokens.neutral10, ColorTokens.neutral20],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAdvertisement
                              ? Color(0xFFFFD700)
                              : ColorTokens.neutral30,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Encabezado de publicidad con animación
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: _isAdvertisement
                                        ? Color(0xFFFFD700)
                                        : ColorTokens.neutral60,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Impulsa tu historia',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _isAdvertisement
                                          ? Color(0xFF1A1A1A)
                                          : ColorTokens.neutral80,
                                    ),
                                  ),
                                  if (_isAdvertisement)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'PREMIUM',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1A1A1A),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Switch(
                                  value: _isAdvertisement,
                                  activeThumbColor: Color(0xFFFFD700),
                                  activeTrackColor: Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.3),
                                  inactiveTrackColor: ColorTokens.neutral30,
                                  inactiveThumbColor: ColorTokens.neutral60,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAdvertisement = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          if (_isAdvertisement) ...[
                            const SizedBox(height: 12),
                            Divider(
                              color: Color(0xFFFFD700).withValues(alpha: 0.3),
                              height: 1,
                            ),
                            const SizedBox(height: 12),

                            // Descripción y beneficios
                            Text(
                              '✨ Tu historia aparecerá con un distintivo especial y mayor alcance a todos los usuarios',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Beneficios en chips
                            Wrap(
                              spacing: 6,
                              children: [
                                _buildAdvertisementBadge('🎯 Alcance +500%'),
                                _buildAdvertisementBadge('⭐ Destaque premium'),
                                _buildAdvertisementBadge(
                                  '📊 Más interacciones',
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            Text(
                              'Activa la publicidad para impulsar tu historia y alcanzar más usuarios',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorTokens.neutral70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botón de publicar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAdvertisement
                              ? Color(0xFFFFD700)
                              : ColorTokens.primary30,
                          foregroundColor: _isAdvertisement
                              ? Color(0xFF1A1A1A)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _isAdvertisement ? 8 : 2,
                          shadowColor: _isAdvertisement
                              ? Color(0xFFFFD700).withValues(alpha: 0.5)
                              : null,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            onSave(
                              _descriptionController.text,
                              _isAdvertisement,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        icon: Icon(
                          _isAdvertisement ? Icons.flash_on : Icons.send,
                          size: 20,
                        ),
                        label: Text(
                          _isAdvertisement
                              ? 'Publicar como Publicidad'
                              : 'Publicar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildAdvertisementBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Color(0xFFFFD700).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Color(0xFFFFD700), width: 1),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    ),
  );
}
