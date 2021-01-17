import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/radarr.dart';
import 'package:tuple/tuple.dart';

class RadarrMoviesRoute extends StatefulWidget {
    final ScrollController scrollController;

    RadarrMoviesRoute({
        Key key,
        @required this.scrollController,
    }): super(key: key);

    @override
    State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMoviesRoute> with AutomaticKeepAliveClientMixin {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
    
    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        super.initState();
        SchedulerBinding.instance.scheduleFrameCallback((_) => _refresh());
    }

    Future<void> _refresh() async {
        RadarrState _state = context.read<RadarrState>();
        _state.resetMovies();
        await Future.wait([
            _state.movies,
        ]);
    }

    @override
    Widget build(BuildContext context) {
        super.build(context);
        return Scaffold(
            key: _scaffoldKey,
            body: _body,
            appBar: _appBar,
        );
    }

    Widget get _appBar => LunaAppBar.empty(
        child: Container(), //TODO
        height: 62.0,
    );

    Widget get _body => LSRefreshIndicator(
        refreshKey: _refreshKey,
        onRefresh: _refresh,
        child: Selector<RadarrState, Tuple2<
            Future<List<RadarrMovie>>,
            Future<List<RadarrMovie>>
        >>(
            selector: (_, state) => Tuple2(
                state.movies,
                state.movies,
            ),
            builder: (context, tuple, _) => FutureBuilder(
                future: Future.wait([
                    tuple.item1,
                    tuple.item2,
                ]),
                builder: (context, AsyncSnapshot<List<Object>> snapshot) {
                    if(snapshot.hasError) {
                        if(snapshot.connectionState != ConnectionState.waiting) {
                            LunaLogger().error('Unable to fetch Radarr movies', snapshot.error, StackTrace.current);
                        }
                        return LSErrorMessage(onTapHandler: () async => _refreshKey.currentState.show());
                    }
                    if(snapshot.hasData) return snapshot.data.length == 0
                        ? _noMovies()
                        : snapshot.data.length > 2
                            ? _movies(snapshot.data[0])
                            : _movies(snapshot.data[0]);
                    return LSLoader();
                },
            ),
        ),
    );

    Widget _noMovies({ bool showButton = true }) => LSGenericMessage(
        text: 'No Movies Found',
        showButton: showButton,
        buttonText: 'Refresh',
        onTapHandler: () async => _refreshKey.currentState.show(),
    );

    Widget _movies(
        List<RadarrMovie> movies,
    ) => Selector<RadarrState, String>(
        selector: (_, state) => state.moviesSearchQuery,
        builder: (context, query, _) {
            List<RadarrMovie> _filtered = _filterAndSort(movies, query);
            return LSListView(
                controller: widget.scrollController,
                children: _filtered.length == 0
                    ? [_noMovies(showButton: false)]
                    : List.generate(
                        _filtered.length,
                        (index) => LSCardTile(title: LSTitle(text: _filtered[index].title)),
                    ),
            );
        }
    );

    List<RadarrMovie> _filterAndSort(List<RadarrMovie> movies, String query) {
        if(movies == null || movies.length == 0) return movies;
        RadarrState _state = context.read<RadarrState>();
        List<RadarrMovie> _filtered = new List<RadarrMovie>.from(movies);
        // Filter
        _filtered = _filtered.where((movie) {
            if(query != null && query.isNotEmpty) return movie.title.toLowerCase().contains(query.toLowerCase());
            return movie != null;
        }).toList();
        // Sort
        // TODO
        return _filtered;
    }
}
