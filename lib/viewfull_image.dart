import 'dart:async';
import './swiper.dart' as tip;
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
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(leading: BackButton(color: Colors.yellow[800],onPressed: (){
          Navigator.of(context).pop();
          tip.controllerPageView.jumpToPage(1);
        },),
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
        ) : PhotoView(imageProvider: NetworkImage('$imageUrl')), ) ;
  }
}

// tip.controllerPageView.jumpToPage(1);