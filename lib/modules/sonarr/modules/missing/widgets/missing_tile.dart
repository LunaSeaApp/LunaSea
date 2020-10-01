import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class SonarrMissingTile extends StatefulWidget {
    final SonarrMissingRecord record;

    SonarrMissingTile({
        Key key,
        @required this.record,
    }) : super(key: key);

    @override
    State<SonarrMissingTile> createState() => _State();
}

class _State extends State<SonarrMissingTile> {
    final double _height = 90.0;
    final double _width = 60.0;
    final double _padding = 8.0;

    @override
    Widget build(BuildContext context) => Selector<SonarrState, Future<SonarrMissing>>(
        selector: (_, state) => state.missing,
        builder: (context, series, _) => LSCard(
            child: InkWell(
                child: Row(
                    children: [
                        _poster,
                        Expanded(child: _information),
                        _trailing,
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                ),
                borderRadius: BorderRadius.circular(Constants.UI_BORDER_RADIUS),
                onTap: _tileOnTap,
                onLongPress: _tileOnLongPress,
            ),
            decoration: LSCardBackground(
                uri: Provider.of<SonarrState>(context, listen: false).getBannerURL(widget.record.seriesId),
                headers: Provider.of<SonarrState>(context, listen: false).headers,
            ),
        ),
    );

    Widget get _poster => LSNetworkImage(
        url: Provider.of<SonarrState>(context, listen: false).getPosterURL(widget.record.seriesId),
        placeholder: 'assets/images/sonarr/noseriesposter.png',
        height: _height,
        width: _width,
        headers: Provider.of<SonarrState>(context, listen: false).headers.cast<String, String>(),
    );

    Widget get _information => Padding(
        child: Container(
            child: Column(
                children: [
                    LSTitle(text: widget.record.series.title, darken: !widget.record.monitored, maxLines: 1),
                    _subtitleOne,
                    _subtitleTwo,
                    _subtitleThree,
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
            ),
            height: (_height-(_padding*2)),
        ),
        padding: EdgeInsets.all(_padding),
    );

    Widget get _trailing => Container(
        child: Padding(
            child: LSIconButton(
                icon: Icons.search,
                onPressed: () { /** TODO **/ },
                onLongPress: () { /** TODO  **/ },
            ),
            padding: EdgeInsets.only(right: 12.0),
        ),
        height: _height,
    );

    Widget get _subtitleOne => RichText(
        text: TextSpan(
            style: TextStyle(
                fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                color: widget.record.monitored ? Colors.white70 : Colors.white30,
            ),
            children: [
                TextSpan(text: widget.record.seasonNumber == 0 ? 'Specials ' : 'Season ${widget.record.seasonNumber} '),
                TextSpan(text: Constants.TEXT_EMDASH),
                TextSpan(text: 'Episode ${widget.record.episodeNumber}'),
            ],
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
    );

    Widget get _subtitleTwo => RichText(
        text: TextSpan(
            style: TextStyle(
                fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                color: widget.record.monitored ? Colors.white70 : Colors.white30,
            ),
            children: [
                TextSpan(
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                    ),
                    text: widget.record.title ?? 'Unknown Title',
                ),
            ],
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
    );

    Widget get _subtitleThree => RichText(
        text: TextSpan(
            style: TextStyle(
                fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                color: LunaColours.red,
                fontWeight: FontWeight.w600,
            ),
            children: [
                TextSpan(text: widget.record.airDateUtc == null
                    ? 'Aired'
                    : 'Aired ${DateTime.now().lsDateTime_ageString(widget.record.airDateUtc?.toLocal())}'),
            ],
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
    );

    Future<void> _tileOnTap() async => SonarrSeriesSeasonDetailsRouter.navigateTo(
        context,
        seriesId: widget.record.seriesId,
        seasonNumber: widget.record.seasonNumber,
    );

    Future<void> _tileOnLongPress() async =>  SonarrSeriesDetailsRouter.navigateTo(
        context,
        seriesId: widget.record.seriesId,
    );
}