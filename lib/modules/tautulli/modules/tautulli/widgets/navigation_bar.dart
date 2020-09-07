import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/tautulli.dart';
import 'package:tautulli/tautulli.dart';

class TautulliNavigationBar extends StatefulWidget {
    static const List<IconData> icons = [
        CustomIcons.monitoring,
        CustomIcons.user,
        CustomIcons.history,
        Icons.more_horiz,
    ];

    static const List<String> titles = [
        'Activity',
        'Users',
        'History',
        'More',
    ];

    final PageController pageController;

    TautulliNavigationBar({
        Key key,
        @required this.pageController,
    }): super(key: key);

    @override
    State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliNavigationBar> {
    @override
    Widget build(BuildContext context) => Consumer<TautulliState>(
        builder: (context, state, _) => Container(
            child: SafeArea(
                top: false,
                child: Padding(
                    child: GNav(
                        gap: 8.0,
                        iconSize: 24.0,
                        padding: EdgeInsets.fromLTRB(18.0, 5.0, 12.0, 5.0),
                        duration: Duration(milliseconds: Constants.UI_NAVIGATION_SPEED),
                        tabBackgroundColor: Theme.of(context).canvasColor,
                        activeColor: LSColors.accent,
                        tabs: [
                            GButton(
                                icon: TautulliNavigationBar.icons[0],
                                text: TautulliNavigationBar.titles[0],
                                iconSize: 22.0,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                                    color: LSColors.accent,
                                ),
                                leading: FutureBuilder(
                                    future: state.activity,
                                    builder: (BuildContext context, AsyncSnapshot<TautulliActivity> snapshot) {
                                        if(
                                            state.navigationIndex != 0 &&
                                            snapshot.hasData &&
                                            snapshot.data.streamCount > 0
                                        ) {
                                            return Badge(
                                                badgeColor: LSColors.splash,
                                                elevation: 0,
                                                animationDuration: Duration(milliseconds: Constants.UI_NAVIGATION_SPEED),
                                                animationType: BadgeAnimationType.fade,
                                                shape: BadgeShape.circle,
                                                position: BadgePosition.topRight(
                                                    top: -15,
                                                    right: -15,
                                                ),
                                                badgeContent: Text(
                                                    snapshot.data.streamCount.toString(),
                                                    style: TextStyle(color: Colors.white),
                                                ),
                                                child: Icon(
                                                    TautulliNavigationBar.icons[0],
                                                    color: state.navigationIndex == 0
                                                        ? LSColors.accent
                                                        : Colors.white,
                                                ),
                                            );
                                        }
                                        return Icon(
                                            TautulliNavigationBar.icons[0],
                                            color: state.navigationIndex == 0
                                                ? LSColors.accent
                                                : Colors.white,
                                        );
                                    }
                                ),
                            ),
                            GButton(
                                icon: TautulliNavigationBar.icons[1],
                                text: TautulliNavigationBar.titles[1],
                                iconSize: 22.0,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                                    color: LSColors.accent,
                                ),
                            ),
                            GButton(
                                icon: TautulliNavigationBar.icons[2],
                                text: TautulliNavigationBar.titles[2],
                                iconSize: 22.0,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                                    color: LSColors.accent,
                                ),
                            ),
                            GButton(
                                icon: TautulliNavigationBar.icons[3],
                                text: TautulliNavigationBar.titles[3],
                                iconSize: 22.0,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                                    color: LSColors.accent,
                                ),
                            ),
                        ],
                        selectedIndex: state.navigationIndex,
                        onTabChange: _navOnTap,
                    ),
                    padding: EdgeInsets.all(12.0),
                ),
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                //LSColors.secondary,
            ),
        ),
    );

    Future<void> _navOnTap(int index) async {
        await widget.pageController.animateToPage(
            index,
            duration: Duration(milliseconds: Constants.UI_NAVIGATION_SPEED),
            curve: Curves.easeOutSine,
        );
        Provider.of<TautulliState>(context, listen: false).navigationIndex = index;
    }
}