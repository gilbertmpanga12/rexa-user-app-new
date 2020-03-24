// import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class WebViewer extends StatefulWidget {
  final String website;
  final String uid;
  final bool shouldToggle;
  final String bookingUrl;
  final String shippingUrl;
  


  WebViewer({this.website,this.uid, this.shouldToggle, this.bookingUrl, this.shippingUrl});

  @override
  _WebViewerState createState() => new _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  String _url;
  String _uid;
  String _loading = 'Loading...';
  bool _isLoadingPage;
  String _shippingAddress;
  bool _shouldToggle;
  String _shippingUrl;
  String _bookingUrl;
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  String shippingPlaceholder = 'SHIPPING ';
  String bookingPlaceholder = 'MORE BOOKING +';



  
  // Completer<WebViewController> _controller = Completer<WebViewController>();
  @override
  void initState() {
    _isLoadingPage = true;
    _url = widget.website;
    _uid = widget.uid;
    _shouldToggle = widget.shouldToggle;
    _shippingUrl = widget.shippingUrl;
    _bookingUrl = widget.bookingUrl;
    // countUrlClicks();
    super.initState();
  }

  @override
  void dispose(){
    flutterWebviewPlugin.close();
    super.dispose();
  }


shipUrl(String website) async {
  // if(_shouldToggle) {
  //   setState(() {
  //   shippingPlaceholder = '....';
  // });
  // }else{
  //   setState(() {
  //  bookingPlaceholder = '....';
  // });
  // }
flutterWebviewPlugin.reloadUrl(website).then((onValue){
  setState(() {
    _shouldToggle = !_shouldToggle;
  });
});

//  flutterWebviewPlugin.onProgressChanged.listen((onData){
//    print(onData);
//  });
  
  /*
  .then((onValue){
if(_shouldToggle) {
    setState(() {
    shippingPlaceholder = 'SHIPPING +';
  });
  }else{
    setState(() {
   bookingPlaceholder = 'MORE BOOKING +';
  });
  }
  });
  */
  // setState(() {
  //     _url = website;
  // });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebviewScaffold(
      url: _url,
      appBar: new AppBar(
        title: Text(
            '  Rexa',
            style:TextStyle(
                fontFamily: 'Monoton',
                color: Colors.black,
                fontSize: 23.0,
                letterSpacing: 0.8),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 1.3,
          actions: <Widget>[
            _shouldToggle ? InkWell(
              onTap: (){
                     if(_shippingAddress == 'null'){
Toast.show('Oops shipping address  not available', context,backgroundColor: Colors.red,duration: 5);
                    }else{
                    shipUrl(_shippingUrl);
                    }
            },
              highlightColor: Colors.grey,splashColor: Colors.grey,
              child: Padding(
              padding: EdgeInsets.only(top: 21.2,bottom: 16.6,left: 17.6,right: 16.6),
              child: Transform.rotate(
                angle: 26,
                child: Icon(Icons.local_airport,size: 30.0,color: Colors.blue[600]),),),) : InkWell(
              onTap: (){
                     if(_shippingAddress == 'null'){
Toast.show('Oops shipping address  not available', context,backgroundColor: Colors.red,duration: 5);
                    }else{
                    shipUrl(_bookingUrl);
                    }
            },
              highlightColor: Colors.grey,splashColor: Colors.grey,
              child: Padding(
              padding: EdgeInsets.only(top: 21.2,bottom: 16.6,left: 1,right: 16.6),
              child: Icon(FontAwesomeIcons.shoppingCart,size: 20.0,color: Colors.yellow[800]),),)
          ],
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      scrollBar: true,
      initialChild: Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator()
        ),
      ),
    ));
  }
}