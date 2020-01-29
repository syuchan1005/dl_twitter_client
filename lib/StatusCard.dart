import 'package:chewie/chewie.dart';
import 'package:dl_twitter/Consts.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StatusCard extends StatefulWidget {
  StatusCard({Key key, this.status}) : super(key: key);

  final dynamic status;

  @override
  StatusCardState createState() => StatusCardState(status: this.status);
}

class StatusCardState extends State<StatusCard> {
  final dynamic status;

  StatusCardState({ this.status });

  VideoPlayerController _controller;
  ChewieController _chewieController;
  List<Widget> _media;

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_media == null) {
      _media = (this.status['media'] as List<dynamic>)
          .map((m) {
        if (m['type'] == 'photo') {
          return Padding(
            padding: EdgeInsets.all(8),
            child: Image.network(
              '$host/media/${m['id']}${m['ext']}',
              height: 200,
            ),
          );
        } else if (m['type'] == 'video') {
          setState(() {
            _controller = VideoPlayerController.network(
              '$host/media/${m['id']}${m['ext']}',
            );
            _chewieController = ChewieController(
              videoPlayerController: _controller,
              autoInitialize: true,
            );
          });
          return Padding(
            padding: EdgeInsets.all(8),
            child: Chewie(
              controller: _chewieController,
            ),
          );
        }
        return Text('Unknown mediaType: ${m['type']}');
      }).toList();
    }
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    this.status['user']['name'],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '@${this.status['user']['screenName']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 150, 150, 150),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Text(this.status['text']),
          ),
          Column(
            children: _media,
          ),
        ],
      ),
    );
  }
}