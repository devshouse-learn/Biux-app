import 'package:biux/config/colors.dart';
import 'package:biux/config/styles.dart';
import 'package:biux/config/strings.dart';
import 'package:biux/data/models/story_item.dart';
import 'package:biux/data/repositories/stories/stories_repository.dart';
import 'package:biux/ui/screens/story/ui/screens/create_story.dart';
import 'package:flutter/material.dart';
import 'button_stories.dart';

class MenuStories extends StatefulWidget {
  // int id;
  // final VoidCallback onReassemble;
  // MenuHistorias({this.id, this.onReassemble});
  _MenuStoriesState createState() => _MenuStoriesState();
}

class _MenuStoriesState extends State<MenuStories> {
  late List<StoryItem> listStories;
  ScrollController _scrollController = ScrollController();
  // int offset = 1;
  void reassemble() {
    super.reassemble();
    if (listStories != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    listStories = [];
    Future.delayed(
      Duration.zero,
      () async {
        listStories = await StoriesRepository().getStoryItem();
        setState(
          () {},
        );
      },
    );
    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          //   _getMoreData();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          Container(
            height: 20,
          ),
          Center(
            child: Text(
              AppStrings.storyText,
              style: Styles.centerText,
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                child: Column(),
              ),
              Column(
                children: _listadoHistorias(
                  listStories.reversed.toList(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: listStories.length == 0
                    ? CircularProgressIndicator()
                    : Container(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 50,
        ),
        child: FloatingActionButton(
            elevation: 10,
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (BuildContext context) => CreateStory(),
                ),
              );
            },
            child: Icon(Icons.add),
            backgroundColor: AppColors.lightNavyBlue),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  _listadoHistorias(
    List<StoryItem> story,
  ) {
    List<Widget> listStories = [];
    for (StoryItem story in story) {
      listStories.add(
        Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ), // set rounded corner radius
          ),
          child: ButtonStory(
            storyItem: story,
          ),
        ),
      );
    }
    return listStories;
  }
}
