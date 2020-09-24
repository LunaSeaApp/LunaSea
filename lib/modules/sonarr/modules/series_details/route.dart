import 'package:fluro_fork/fluro_fork.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/scheduler.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class SonarrSeriesDetailsRouter {
    static const String ROUTE_NAME = '/sonarr/series/details/:seriesid';

    static Future<void> navigateTo(BuildContext context, {
        @required int seriesId,
    }) async => SonarrRouter.router.navigateTo(
        context,
        route(seriesId: seriesId),
    );

    static String route({
        String profile,
        @required int seriesId,
    }) => [
        ROUTE_NAME.replaceFirst(':seriesid', seriesId?.toString() ?? '-1'),
        if(profile != null) '/$profile',
    ].join();

    static void defineRoutes(Router router) {
        router.define(
            ROUTE_NAME + '/:profile',
            handler: Handler(handlerFunc: (context, params) => _SonarrSeriesDetailsRoute(
                profile: params['profile'] != null && params['profile'].length != 0 ? params['profile'][0] : null,
                seriesId: int.tryParse(params['seriesid'][0]) ?? -1,
            )),
            transitionType: LunaRouter.transitionType,
        );
        router.define(
            ROUTE_NAME,
            handler: Handler(handlerFunc: (context, params) => _SonarrSeriesDetailsRoute(
                profile: null,
                seriesId: int.tryParse(params['seriesid'][0]) ?? -1,
            )),
            transitionType: LunaRouter.transitionType,
        );
    }
}

class _SonarrSeriesDetailsRoute extends StatefulWidget {
    final String profile;
    final int seriesId;

    _SonarrSeriesDetailsRoute({
        Key key,
        @required this.profile,
        @required this.seriesId,
    }): super(key: key);

    @override
    State<StatefulWidget> createState() => _State();
}

class _State extends State<_SonarrSeriesDetailsRoute> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    PageController _pageController;

    @override
    void initState() {
        super.initState();
        _pageController = PageController(initialPage: SonarrDatabaseValue.NAVIGATION_INDEX_SERIES_DETAILS.data);
        SchedulerBinding.instance.scheduleFrameCallback((_) => _refresh());
    }

    Future<void> _refresh() async {
        SonarrState _state = Provider.of<SonarrState>(context, listen: false);
        SonarrSeries _series = await _state.api.series.getSeries(seriesId: widget.seriesId);
        List<SonarrSeries> allSeries = await _state.series;
        int _index = allSeries?.indexWhere((element) => element.id == widget.seriesId) ?? -1;
        if(_index >= 0) allSeries[_index] = _series;
        if(mounted) setState(() {});
    }

    SonarrSeries _findSeries(List<SonarrSeries> series) {
        return series.firstWhere(
            (series) => series.id == widget.seriesId,
            orElse: () => null,
        );
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: _appBar,
        bottomNavigationBar: _bottomNavigationBar,
        body: _body,
    );

    Widget get _appBar => LSAppBar(title: 'Series Details');

    Widget get _bottomNavigationBar => SonarrSeriesDetailsNavigationBar(pageController: _pageController);

    Widget get _body => Selector<SonarrState, Future<List<SonarrSeries>>>(
        selector: (_, state) => state.series,
        builder: (context, series, _) => FutureBuilder(
            future: series,
            builder: (context, AsyncSnapshot<List<SonarrSeries>> snapshot) {
                if(snapshot.hasError) {
                    if(snapshot.connectionState != ConnectionState.waiting) {
                        LunaLogger.error(
                            '_TautulliUserDetailsRoute',
                            '_body',
                            'Unable to pull Tautulli user table',
                            snapshot.error,
                            null,
                            uploadToSentry: !(snapshot.error is DioError),
                        );
                    }
                    return LSErrorMessage(onTapHandler: () => _refresh());
                }
                if(snapshot.hasData) {
                    SonarrSeries series = _findSeries(snapshot.data);
                    return series == null
                        ? _unknown
                        : PageView(
                            controller: _pageController,
                            children: _tabs(series),
                        );
                }
                return LSLoader();
            },
        ),
    );

    List<Widget> _tabs(SonarrSeries series) => [
        SonarrSeriesDetailsOverview(series: series),
        SonarrSeriesDetailsSeasonList(series: series),
    ];

    Widget get _unknown => LSGenericMessage(text: 'Series Not Found');
}