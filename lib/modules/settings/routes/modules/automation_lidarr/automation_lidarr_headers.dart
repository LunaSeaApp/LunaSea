import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';

class SettingsModulesLidarrHeaders extends StatefulWidget {
    static const ROUTE_NAME = '/settings/modules/lidarr/headers';
    
    @override
    State<SettingsModulesLidarrHeaders> createState() => _State();
}

class _State extends State<SettingsModulesLidarrHeaders> {
    ProfileHiveObject _profile = Database.currentProfileObject;

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: _appBar,
        body: _body,
    );

    Widget get _appBar => LSAppBar(title: 'Custom Headers');

    Widget get _body => ValueListenableBuilder(
        valueListenable: Database.profilesBox.listenable(),
        builder: (context, profile, widget) => LSListView(
            children: <Widget>[
                ..._headers,
            ],
        ),
    );

    List<Widget> get _headers => [
        LSHeader(
            text: 'Custom Headers',
            subtitle: 'Define custom headers that will be attached to every request made to the module.\n\nPlease note that using custom headers for authentication methods may cause images to stop loading within LunaSea.',
        ),
        if((_profile.getLidarr()['headers'] as Map).isEmpty) LSGenericMessage(
            text: 'No Custom Headers Added',
        ),
        ..._list,
        LSDivider(),
        LSButton(
            text: 'Add Header',
            onTap: () async => _showAddPrompt(),
        ),
    ];

    List get _list {
        Map<String, dynamic> headers = Map<String, dynamic>.from(_profile.getLidarr()['headers']);
        List list = [];
        headers.forEach((key, value) => list.add(LSCardTile(
            title: LSTitle(text: key.toString()),
            subtitle: LSSubtitle(text: value.toString()),
            trailing: LSIconButton(
                icon: Icons.delete,
                color: LSColors.red,
                onPressed: () async => _deleteIndexer(key.toString(), value.toString()),
            ),
        )));
        list.sort((a,b) => (a.title as LSTitle).text.compareTo((b.title as LSTitle).text));
        return list;
    }

    Future<void> _showAddPrompt() async {
        List results = await LSDialogSettings.addHeader(context);
        if(results[0]) switch(results[1]) {
            case 1: _showAuthenticationPrompt(); break;
            case 100: _showCustomPrompt(); break;
            default: break;
        }
    }

    Future<void> _showAuthenticationPrompt() async {
        List results = await LSDialogSettings.addAuthenticationHeader(context);
        if(results[0]) {
            Map<String, dynamic> _headers = Map<String, dynamic>.from(_profile.getLidarr()['headers']);
            String _auth = base64.encode(utf8.encode('${results[1]}:${results[2]}'));
            _headers.addAll({'Authorization': 'Basic $_auth'});
            _profile.lidarrHeaders = _headers;
            _profile.save();
        }
    }

    Future<void> _showCustomPrompt() async {
        List results = await LSDialogSettings.addCustomHeader(context);
        if(results[0]) {
            Map<String, dynamic> _headers = Map<String, dynamic>.from(_profile.getLidarr()['headers']);
            _headers.addAll({results[1]: results[2]});
            _profile.lidarrHeaders = _headers;
            _profile.save();
        }
    }

    Future<void> _deleteIndexer(String key, String value) async {
        List results = await LSDialogSettings.deleteHeader(context);
        if(results[0]) {
            Map<String, dynamic> _headers = Map<String, dynamic>.from(_profile.getLidarr()['headers']);
            _headers.remove(key);
            _profile.lidarrHeaders = _headers;
            _profile.save();
            LSSnackBar(
                context: context,
                message: key,
                title: 'Header Deleted',
                type: SNACKBAR_TYPE.success,
            );
        }
    }
}
