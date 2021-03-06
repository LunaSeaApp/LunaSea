import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';

class TautulliLibrariesDetailsNavigationBar extends StatelessWidget {
  final PageController pageController;
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());

  static const List<IconData> icons = [
    Icons.info_outline,
    Icons.people,
  ];

  static const List<String> titles = [
    'Information',
    'User Stats',
  ];

  TautulliLibrariesDetailsNavigationBar({
    Key key,
    @required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LunaBottomNavigationBar(
      pageController: pageController,
      scrollControllers: scrollControllers,
      icons: icons,
      titles: titles,
    );
  }
}
