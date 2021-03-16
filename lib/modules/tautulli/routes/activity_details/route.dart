import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/tautulli.dart';
import 'package:tautulli/tautulli.dart';

class TautulliActivityDetailsRouter extends LunaPageRouter {
    TautulliActivityDetailsRouter() : super('/tautulli/activity/details/:sessionid');

    @override
    Future<void> navigateTo(BuildContext context, { @required String sessionId }) async => LunaRouter.router.navigateTo(context, route(sessionId: sessionId));

    @override
    String route({ @required String sessionId }) => fullRoute.replaceFirst(':sessionid', sessionId);

    @override
    void defineRoute(FluroRouter router) => router.define(
        fullRoute,
        handler: Handler(handlerFunc: (context, params) {
            String sessionId = params['sessionid'] == null || params['sessionid'].length == 0 ? null : params['sessionid'][0];
            return _TautulliActivityDetailsRoute(sessionId: sessionId);
        }),
        transitionType: LunaRouter.transitionType,
    );
}

class _TautulliActivityDetailsRoute extends StatefulWidget {
    final String sessionId;

    _TautulliActivityDetailsRoute({
        Key key,
        @required this.sessionId,
    }): super(key: key);

    @override
    State<StatefulWidget> createState() => _State();
}

class _State extends State<_TautulliActivityDetailsRoute> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

    Future<void> _refresh() async {
        context.read<TautulliState>().resetActivity();
        await context.read<TautulliState>().activity;
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: _appBar,
        body: _body,
    );

    Widget get _appBar => LunaAppBar(
        title: 'Activity Details',
        actions: [
            TautulliActivityDetailsUser(sessionId: widget.sessionId),
            TautulliActivityDetailsMetadata(sessionId: widget.sessionId),
        ]
    );

    Widget get _body => LSRefreshIndicator(
        refreshKey: _refreshKey,
        onRefresh: _refresh,
        child: Selector<TautulliState, Future<TautulliActivity>>(
            selector: (_, state) => state.activity,
            builder: (context, future, _) => FutureBuilder(
                future: future,
                builder: (context, AsyncSnapshot<TautulliActivity> snapshot) {
                    if(snapshot.hasError) {
                        if(snapshot.connectionState != ConnectionState.waiting) {
                            LunaLogger().error('Unable to pull Tautulli activity session', snapshot.error, StackTrace.current);
                        }
                        return LSErrorMessage(onTapHandler: () => _refresh());
                    }
                    if(snapshot.hasData) {
                        TautulliSession session = snapshot.data.sessions.firstWhere((element) => element.sessionId == widget.sessionId, orElse: () => null);
                        return session == null
                            ? _deadSession()
                            : _activeSession(session);
                    }       
                    return LSLoader();
                },
            ),
        ),
    );

    Widget _activeSession(TautulliSession session) => TautulliActivityDetailsInformation(session: session);

    Widget _deadSession() => LSGenericMessage(
        text: 'Session Ended',
        showButton: true,
        buttonText: 'Back',
        onTapHandler: () async => Navigator.of(context).pop(),
    );
}
