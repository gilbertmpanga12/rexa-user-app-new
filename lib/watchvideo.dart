import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/widgets.dart';



class WatchVideo extends StatefulWidget {
  final String photoUrl;
  final String serviceName;
  final bool isVideo;


  WatchVideo({this.photoUrl, this.serviceName, this.isVideo});

  WatchVideoState createState() => WatchVideoState();
}

class WatchVideoState extends State<WatchVideo> {
  String imageUrl;
  String ServiceName;
  bool _isVideo;
  VideoPlayerController _controller;
 Future<void> _initializeVideoPlayerFuture;


 
  initState() {
  
    imageUrl = widget.photoUrl;
    ServiceName = widget.serviceName;
    _isVideo = widget.isVideo;
    _controller = new VideoPlayerController.network(
     '$imageUrl'
    );

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
        _controller.play();
        setState(() {});
      });
 
super.initState();
  }

   @override
  void dispose() {
_controller.dispose();
super.dispose();

  }

  build(BuildContext context) {
// SizeConfig().init(context);
  return WillPopScope(child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stories',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
  future: _initializeVideoPlayerFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      // If the VideoPlayerController has finished initialization, use
      // the data it provides to limit the aspect ratio of the VideoPlayer.
      return Center(child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        // Use the VideoPlayer widget to display the video.
        child: VideoPlayer(_controller),
      ),);
    } else {
      // If the VideoPlayerController is still initializing, show a
      // loading spinner.
      return Center(child: SpinKitPulse(
  color: Colors.white,
  size: 66.0,
));
    }
  },
),floatingActionButton: FloatingActionButton(backgroundColor: Colors.white,
  onPressed: () {
    // Wrap the play or pause in a call to `setState`. This ensures the
    // correct icon is shown
    setState(() {
      // If the video is playing, pause it.
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        // If the video is paused, play it.
        _controller.play();
      }
    });
  },
  // Display the correct icon depending on the state of the player.
  child: Icon(
    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.blue[600],
  ),
),),
    ),onWillPop: (){
      Future<bool> shouldNavigate;
       _controller.pause().then((onValue){
         Navigator.of(context).pop();
         shouldNavigate =  Future.value(false);
       });
       return shouldNavigate;
    },);
  }
}
