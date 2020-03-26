import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import '../../sonarr.dart';

class SonarrAddSearchBar extends StatefulWidget {
    final Function callback;

    SonarrAddSearchBar({
        @required this.callback,
    });

    @override
    State<SonarrAddSearchBar> createState() => _State();
}

class _State extends State<SonarrAddSearchBar> {
    final TextEditingController _controller = TextEditingController();

    @override
    void initState() {
        super.initState();
        final model = Provider.of<SonarrModel>(context, listen: false);
        _controller.text = model.addSearchQuery;
    }

    @override
    Widget build(BuildContext context) => Consumer<SonarrModel>(
        builder: (context, model, widget) => LSTextInputBar(
            controller: _controller,
            onChanged: (text, updateController) => _onChange(model, text, updateController),
            onSubmitted: (_) => _onSubmit(),
        ),
    );

    void _onChange(SonarrModel model, String text, updateController) {
        model.addSearchQuery = text;
        if(updateController) _controller.text = text;
    }

    void _onSubmit() => widget.callback();
}