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

class _State extends State<_TautulliActivityDetailsRoute> with LunaScrollControllerMixin {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

    Future<void> _refresh() async {
        context.read<TautulliState>().resetActivity();
        await context.read<TautulliState>().activity;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: _appBar(),
            body: _body(),
        );
    }

    Widget _appBar() {
        return LunaAppBar(
            title: 'tautulli.ActivityDetails'.tr(),
            scrollControllers: [scrollController],
            actions: [
                TautulliActivityDetailsUserAction(sessionId: widget.sessionId),
                TautulliActivityDetailsMetadataAction(sessionId: widget.sessionId),
            ]
        );
    }

    Widget _body() {
        return LunaRefreshIndicator(
            context: context,
            key: _refreshKey,
            onRefresh: _refresh,
            child: FutureBuilder(
                future: context.select<TautulliState, Future<TautulliActivity>>((state) => state.activity),
                builder: (context, AsyncSnapshot<TautulliActivity> snapshot) {
                    if(snapshot.hasError) {
                        if(snapshot.connectionState != ConnectionState.waiting) LunaLogger().error(
                            'Unable to pull Tautulli activity session',
                            snapshot.error,
                            snapshot.stackTrace,
                        );
                        return LunaMessage.error(onTap: _refreshKey.currentState.show);
                    }
                    if(snapshot.hasData) {
                        TautulliSession session = snapshot.data.sessions.firstWhere((element) => element.sessionId == widget.sessionId, orElse: () => null);
                        return _session(session);
                    }       
                    return LunaLoader();
                },
            ),
        );
    }

    Widget _session(TautulliSession session) {
        if(session == null) return LunaMessage.goBack(
            context: context,
            text: 'tautulli.SessionEnded'.tr(),
        );
        return LunaListView(
            controller: scrollController,
            children: [
                TautulliActivityTile(session: session, disableOnTap: true),
                TautulliActivityDetailsTerminateSessionButton(session: session),
                LunaHeader(text: 'tautulli.Metadata'.tr()),
                TautulliActivityDetailsMetadataBlock(session: session),
                LunaHeader(text: 'tautulli.Player'.tr()),
                TautulliActivityDetailsPlayerBlock(session: session),
                LunaHeader(text: 'tautulli.Stream'.tr()),
                TautulliActivityDetailsStreamBlock(session: session),
            ],
        );
    }
}
