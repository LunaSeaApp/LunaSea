import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import '../../nzbget.dart';

class NZBGetQueue extends StatefulWidget {
    static const ROUTE_NAME = '/nzbget/queue';
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

    NZBGetQueue({
        Key key,
        @required this.refreshIndicatorKey,
    }) : super(key: key);
    
    @override
    State<NZBGetQueue> createState() => _State();
}

class _State extends State<NZBGetQueue> with TickerProviderStateMixin {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    Timer _timer;
    Future _future;
    List<NZBGetQueueData> _queue = [];

    @override
    void initState() {
        super.initState();
        _refresh();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: _body,
        floatingActionButton: NZBGetQueueFAB(),
    );

    @override
    void dispose() {
        _timer?.cancel();
        super.dispose();
    }

    void _createTimer() => _timer = Timer(Duration(seconds: 1), () => _fetchWithoutMessage());

    Future<void> _refresh() async => setState(() {
        _future = _fetch();
    });

    Future<void> _fetchWithoutMessage() async {
        _fetch().then((_) => { if(mounted) setState(() {}) })
        .catchError((_) => _queue = null);
    }

    Future<bool> _fetch() async {
        NZBGetAPI _api = NZBGetAPI.from(Database.currentProfileObject);
        return _fetchStatus(_api)
        .then((_) => _fetchQueue(_api))
        .then((_) {
            if(_timer == null || !_timer.isActive) _createTimer();
            return true;
        })
        .catchError((error) {
            _queue = null;
            return Future.error(error);
        });
    }

    Future<void> _fetchQueue(NZBGetAPI api) async {
        final _model = Provider.of<NZBGetModel>(context, listen: false);
        return await api.getQueue(_model.speed, 100)
        .then((data) => _queue = data)
        .catchError((error) => Future.error(error));
    }

    Future<void> _fetchStatus(NZBGetAPI api) async {
        return await api.getStatus()
        .then((data) => _updateModuleState(data))
        .catchError((error) => Future.error(error));
    }

    void _updateModuleState(NZBGetStatusData data) {
        final _model = Provider.of<NZBGetModel>(context, listen: false);
        _model.paused = data.paused;
        _model.speed = data.speed;
        _model.currentSpeed = data.currentSpeed;
    }

    Widget get _body => LSRefreshIndicator(
        refreshKey: widget.refreshIndicatorKey,
        onRefresh: () => _fetchWithoutMessage(),
        child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
                if(
                    snapshot.connectionState == ConnectionState.done
                    && (snapshot.hasError || snapshot.data == null)
                ) return LSErrorMessage(onTapHandler: () => _refresh());
                return _list;
            },
        ),
    );

    Widget get _list => _queue == null
        ? LSErrorMessage(onTapHandler: () => _refresh())
        : _queue.length == 0
            ? LSGenericMessage(
                text: 'Empty Queue',
                showButton: true,
                buttonText: 'Refresh',
                onTapHandler: () => _fetchWithoutMessage(),
            )
            : _reorderableList;

    Widget get _reorderableList => Scrollbar(
        child: LSReorderableListView(
            onReorder: (oIndex, nIndex) async {
                if (oIndex > _queue.length) oIndex = _queue.length;
                if (oIndex < nIndex) nIndex--;
                NZBGetQueueData data = _queue[oIndex];
                if(mounted) {
                    setState(() {
                        _queue.remove(data);
                        _queue.insert(nIndex, data);
                    });
                }
                await NZBGetAPI.from(Database.currentProfileObject).moveQueue(data.id, (nIndex - oIndex))
                .then((_) => LSSnackBar(
                    context: context,
                    title: 'Moved Job in Queue',
                    message: data.name,
                    type: SNACKBAR_TYPE.success,
                ))
                .catchError((_) => LSSnackBar(
                    context: context,
                    title: 'Failed to Move Job',
                    message: Constants.CHECK_LOGS_MESSAGE,
                    type: SNACKBAR_TYPE.failure,
                ));
            },
            children: List.generate(
                _queue.length,
                (index) => NZBGetQueueTile(
                    key: Key(_queue[index].id.toString()),
                    data: _queue[index],
                ),
            ),
            padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        ),
    );
}
