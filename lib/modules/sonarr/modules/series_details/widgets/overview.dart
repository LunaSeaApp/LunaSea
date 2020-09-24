import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class SonarrSeriesDetailsOverview extends StatelessWidget {
    final SonarrSeries series;
    final double _height = 105.0;
    final double _width = 70.0;
    final double _padding = 8.0;

    SonarrSeriesDetailsOverview({
        Key key,
        @required this.series,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) => LSListView(
        children: [
            _description(context),
            _information(context),
            _links,
        ],
    );

    Widget _information(BuildContext context) => LSTableBlock(
        children: [
            LSTableContent(title: 'monitored', body: series.monitored ? 'Yes' : 'No'),
            LSTableContent(title: 'path', body: series.path ?? 'Unknown'),
            LSTableContent(title: 'size', body: series.sizeOnDisk?.lsBytes_BytesToString(decimals: 1) ?? 'Unknown'),
            LSTableContent(title: 'type', body: series.seriesType?.value?.lsLanguage_Capitalize() ?? 'Unknown'),
            LSTableContent(title: 'quality profile', body: ''),
            if(Provider.of<SonarrState>(context, listen: false).enableVersion3) LSTableContent(title: 'language profile', body: ''),
            LSTableContent(title: '', body: ''),
            LSTableContent(title: 'status', body: series.status?.lsLanguage_Capitalize() ?? 'Unknown'),
            LSTableContent(title: 'runtime', body: series.lunaRuntime),
            LSTableContent(title: 'network', body: series.network ?? 'Unknown'),
            LSTableContent(title: 'next airing', body: series.lunaNextAiring),
            LSTableContent(title: 'air time', body: series.lunaAirTime),
            
        ],
    );

    Widget _description(BuildContext context) => LSCard(
        child: InkWell(
            child: Row(
                children: [
                    LSNetworkImage(
                        url: Provider.of<SonarrState>(context, listen: false).getPosterURL(series.id),
                        headers: Provider.of<SonarrState>(context, listen: false).headers.cast<String, String>(),
                        placeholder: 'assets/images/sonarr/noseriesposter.png',
                        height: _height,
                        width: _width,
                    ),
                    Expanded(
                        child: Padding(
                            child: Container(
                                child: Column(
                                    children: [
                                        LSTitle(text: series.title, maxLines: 1),
                                        Text(
                                            series.overview,
                                            maxLines: 4,
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: Constants.UI_FONT_SIZE_SUBTITLE,
                                            ),
                                        ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                ),
                                height: (_height-(_padding*2)),
                            ),
                            padding: EdgeInsets.all(_padding),
                        ),
                    ),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
            ),
            borderRadius: BorderRadius.circular(Constants.UI_BORDER_RADIUS),
            onTap: () async => LunaDialogs.textPreview(context, series.title, series.overview),
        ),
        decoration: LSCardBackground(
            uri: Provider.of<SonarrState>(context, listen: false).getFanartURL(series.id),
            headers: Provider.of<SonarrState>(context, listen: false).headers,
        ),
    );

    Widget get _links => LSContainerRow(
        children: [
            if(series.imdbId != '') Expanded(
                child: LSCard(
                    child: InkWell(
                        child: Padding(
                            child: Image.asset(
                                'assets/images/services/imdb.png',
                                height: 21.0,
                            ),
                            padding: EdgeInsets.all(18.0),
                        ),
                        borderRadius: BorderRadius.circular(Constants.UI_BORDER_RADIUS),
                        onTap: () async => await series?.imdbId?.lsLinks_OpenIMDB(),
                    ),
                    reducedMargin: true,
                ),
            ),
            if(series.tvdbId != 0) Expanded(
                child: LSCard(
                    child: InkWell(
                        child: Padding(
                            child: Image.asset(
                                'assets/images/services/thetvdb.png',
                                height: 23.0,
                            ),
                            padding: EdgeInsets.all(17.0),
                        ),
                        borderRadius: BorderRadius.circular(Constants.UI_BORDER_RADIUS),
                        onTap: () async => await series?.tvdbId?.toString()?.lsLinks_OpenTVDB(),
                    ),
                    reducedMargin: true,
                ),
            ),
            if(series.tvMazeId != 0) Expanded(
                child: LSCard(
                    child: InkWell(
                        child: Padding(
                            child: Image.asset(
                                'assets/images/services/tvmaze.png',
                                height: 21.0,
                            ),
                            padding: EdgeInsets.all(18.0),
                        ),
                        borderRadius: BorderRadius.circular(Constants.UI_BORDER_RADIUS),
                        onTap: () async => await series?.tvMazeId?.toString()?.lsLinks_OpenTVMaze(),
                    ),
                    reducedMargin: true,
                ),
            ),
        ],
    );
}