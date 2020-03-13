import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/widgets/ui.dart';
import 'package:lunasea/routes/lidarr/routes.dart';

class Lidarr extends StatefulWidget {
    static const ROUTE_NAME = '/lidarr';

    @override
    State<Lidarr> createState() => _State();
}

class _State extends State<Lidarr> {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    int _currIndex = 0;
    String _profileState = Database.currentProfileObject.toString();
    LidarrAPI _api = LidarrAPI.from(Database.currentProfileObject);

    final List _refreshKeys = [
        GlobalKey<RefreshIndicatorState>(),
        GlobalKey<RefreshIndicatorState>(),
        GlobalKey<RefreshIndicatorState>(),
    ];

    final List<Icon> _navbarIcons = [
        Icon(CustomIcons.music),
        Icon(CustomIcons.calendar_missing),
        Icon(CustomIcons.history)
    ];

    final List<String> _navbarTitles = [
        'Catalogue',
        'Missing',
        'History',
    ];

    @override
    Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: Database.lunaSeaBox.listenable(keys: ['profile']),
        builder: (context, box, widget) {
            if(_profileState != Database.currentProfileObject.toString()) _refreshProfile();
            return Scaffold(
                key: _scaffoldKey,
                body: _body,
                drawer: _drawer,
                appBar: _appBar,
                bottomNavigationBar: _bottomNavigationBar,
            );
        },
    );

    Widget get _drawer => LSDrawer(page: 'lidarr');

    Widget get _bottomNavigationBar => LSBottomNavigationBar(
        index: _currIndex,
        icons: _navbarIcons,
        titles: _navbarTitles,
        onTap: _navOnTap,
    );

    List<Widget> get _tabs => [
        LidarrCatalogue(refreshIndicatorKey: _refreshKeys[0]),
        LidarrMissing(refreshIndicatorKey: _refreshKeys[1]),
        LidarrHistory(refreshIndicatorKey: _refreshKeys[2]),
    ];

    Widget get _body => Stack(
        children: List.generate(_tabs.length, (index) => Offstage(
            offstage: _currIndex != index,
            child: TickerMode(
                enabled: _currIndex == index,
                child: _api.enabled
                    ? _tabs[index]
                    : LSNotEnabled('Lidarr'),
            ),
        )),
    );

    Widget get _appBar => LSAppBar(
        title: 'Lidarr',
        actions: _api.enabled
            ? <Widget>[
                IconButton(
                    icon: Elements.getIcon(Icons.add),
                    tooltip: 'Add Artist',
                    onPressed: () async => _enterAddArtist(),
                ),
                IconButton(
                    icon: Elements.getIcon(Icons.more_vert),
                    tooltip: 'More Settings',
                    onPressed: () async => _handlePopup(context),
                )
            ]
            : null,
    );

    Future<void> _enterAddArtist() async {
        final dynamic result = await Navigator.of(context).pushNamed(LidarrAddSearch.ROUTE_NAME);
        // //Handle the result
        if(result != null && result[0] == 'artist_added') {
            Notifications.showSnackBar(_scaffoldKey, 'Added ${result[1]}');
            _refreshAllPages();
        }
    }

    Future<void> _handlePopup(BuildContext context) async {
        
        List<dynamic> values = await LidarrDialogs.showSettingsPrompt(context);
        if(values[0]) switch(values[1]) {
            case 'web_gui': await _api.host?.toString()?.lsLinks_OpenLink(); break;
            case 'update_library': await _api.updateLibrary()
                ? Notifications.showSnackBar(_scaffoldKey, 'Updating entire library...')
                : Notifications.showSnackBar(_scaffoldKey, 'Failed to update entire library');
                break;
            case 'rss_sync': await _api.triggerRssSync()
                ? Notifications.showSnackBar(_scaffoldKey, 'Running RSS sync...')
                : Notifications.showSnackBar(_scaffoldKey, 'Failed to run RSS sync');
                break;
            case 'backup': await _api.triggerBackup()
                ? Notifications.showSnackBar(_scaffoldKey, 'Backing up database...')
                : Notifications.showSnackBar(_scaffoldKey, 'Failed to backup database');
                break;
            case 'missing_search': {
                List<dynamic> values = await LidarrDialogs.showSearchMissingPrompt(context);
                if(values[0]) await _api.searchAllMissing()
                    ? Notifications.showSnackBar(_scaffoldKey, 'Searching for all missing albums...')
                    : Notifications.showSnackBar(_scaffoldKey, 'Failed to search for all missing albums');
                break;
            }
        }
    }

    void _navOnTap(int index) => setState(() => _currIndex = index);

    void _refreshProfile() {
        _api = LidarrAPI.from(Database.currentProfileObject);
        _profileState = Database.currentProfileObject.toString();
        _refreshAllPages();
    }

    void _refreshAllPages() {
        for(var key in _refreshKeys) key?.currentState?.show();
    }
}
