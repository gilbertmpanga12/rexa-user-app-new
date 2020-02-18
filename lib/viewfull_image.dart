import 'dart:async';
import 'package:Elyte/swiper.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import './watchvideo.dart';

class ViewImage extends StatefulWidget {
  final String photoUrl;
  final String serviceName;
  final bool isVideo;

  ViewImage({this.photoUrl, this.serviceName, this.isVideo});

  ViewImageState createState() => ViewImageState();
}

class ViewImageState extends State<ViewImage> {
  String imageUrl;
  String ServiceName;
  bool _isVideo;


  initState() {
    imageUrl = widget.photoUrl;
    ServiceName = widget.serviceName;
    _isVideo = widget.isVideo;
    

    print(imageUrl);
    super.initState();
  }

  build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            '${ServiceName[0].toUpperCase() + ServiceName.substring(
                  1,
                )}',
            style: TextStyle(fontSize: 20.0,letterSpacing: .4,
              color: Colors.black,fontFamily: 'NunitoSans',fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.yellow[800]),
        ),
        body: _isVideo ?  Column(
          children: <Widget>[
            Expanded(child: Center(
          child: WatchVideo(isVideo: _isVideo ,photoUrl: imageUrl ,serviceName: ServiceName,)
        ),)
          ],
        ) : PhotoView(imageProvider: NetworkImage('$imageUrl')), ),onWillPop: (){
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => Swiper()));
            return Future.value(false);
        },) ;
  }
}
