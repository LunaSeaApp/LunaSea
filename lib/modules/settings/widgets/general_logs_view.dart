import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import '../../settings.dart';

class SettingsGeneralViewLogsTile extends StatelessWidget {
    @override
    Widget build(BuildContext context) => LSCardTile(
        title: LSTitle(text: 'View Logs'),
        subtitle: LSSubtitle(text: 'View all recorded logs'),
        trailing: LSIconButton(icon: Icons.developer_mode),
        onTap: () async => _viewLogs(context),
    );

    Future<void> _viewLogs(BuildContext context) async => Navigator.of(context).pushNamed(SettingsGeneralLogsTypes.ROUTE_NAME);
}