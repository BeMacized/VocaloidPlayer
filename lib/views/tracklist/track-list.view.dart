import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/models/media/track.dart';
import 'package:voc_amp/models/utils/failure.dart';
import 'package:voc_amp/providers/track-list-view.provider.dart';
import 'package:voc_amp/views/tracklist/widgets/track-list-header.dart';
import 'package:voc_amp/widgets/default-pane.dart';
import 'package:voc_amp/widgets/failure-block.dart';
import 'package:voc_amp/widgets/track-list-item.dart';

class TrackListView extends StatefulWidget {
  final TrackList trackList;

  TrackListView({@required this.trackList});

  @override
  _TrackListViewState createState() => _TrackListViewState();
}

class _TrackListViewState extends State<TrackListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
//      if (Provider.of<TrackListViewProvider>(context).trackList == null)
      Provider.of<TrackListViewProvider>(context)
        ..setTrackList(widget.trackList)
        ..fetchTracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Consumer<TrackListViewProvider>(
          builder: (context, vp, child) =>
              vp.tracks?.fold(
                (failure) => _buildErrorPane(failure),
                (tracks) => _buildContentPane(vp.trackList, tracks),
              ) ??
              Container(),
        ),
        Consumer<TrackListViewProvider>(
          builder: (context, vp, child) =>
              _buildLoadingPane(vp.state == ProviderState.loading),
        ),
      ],
    );
  }

  Widget _buildErrorPane(Failure failure) {
    return Positioned.fill(
      child: DefaultPane(
        child: Column(
          children: <Widget>[
            AppBar(),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FailureBlock(
                        failure: failure,
                        onRetry: () {
                          Provider.of<TrackListViewProvider>(context)
                              .fetchTracks();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPane(bool active) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !active,
        child: AnimatedOpacity(
          opacity: active ? 1.0 : 0.0,
          duration: Duration(milliseconds: 250),
          child: DefaultPane(
            child: Column(
              children: <Widget>[
                AppBar(),
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentPane(TrackList trackList, List<Track> tracks) {
    return Positioned.fill(
      child: CustomScrollView(
        slivers: [
          TrackListHeader(trackList: trackList),
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          ...tracks.map((track) {
            return SliverToBoxAdapter(child: TrackListItem(track: track));
          }),
        ],
      ),
    );
  }
}
