import 'package:flutter/material.dart';

class LunaListView extends StatefulWidget {
    final List<Widget> children;
    final EdgeInsetsGeometry padding;
    final ScrollController scrollController;
    final ScrollPhysics physics;

    LunaListView({
        Key key,
        @required this.children,
        this.scrollController,
        this.padding = const EdgeInsets.symmetric(vertical: 8.0),
        this.physics = const AlwaysScrollableScrollPhysics(),
    }) : super(key: key);

    @override
    State<StatefulWidget> createState() => _State();
}

class _State extends State<LunaListView> {
    ScrollController _scrollController;

    @override
    void initState() {
        super.initState();
        _scrollController = widget.scrollController ?? ScrollController();
    }

    @override
    Widget build(BuildContext context) => Scrollbar(
        controller: _scrollController,
        child: ListView(
            controller: _scrollController,
            children: widget.children,
            padding: widget.padding,
            physics: widget.physics,
        ),
    );
}
