import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/radarr.dart';

class RadarrMoviesEditPathTile extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return LunaListTile(
            context: context,
            title: LunaText.title(text: 'Movie Path'),
            subtitle: LunaText.subtitle(text: context.watch<RadarrMoviesEditState>().path ?? Constants.TEXT_EMDASH),
            trailing: LunaIconButton(icon: Icons.arrow_forward_ios),
            onTap: () async => _onTap(context),
        );
    }

    Future<void> _onTap(BuildContext context) async {
        List _values = await LunaDialogs().editText(context, 'Movie Path', prefill: context.read<RadarrMoviesEditState>().path);
        if(_values[0]) context.read<RadarrMoviesEditState>().path = _values[1];
    }
}