import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:rexa/video_stories.dart';

import './spinner_animation.dart';
import './styles_beauty.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'audiospinner.dart';
import 'comments.dart';
import 'dimen.dart';
import 'notice_bar.dart';
import './swiper.dart' as swiper;

class VideoStoriesByUser extends StatefulWidget {
  final String userId;
  final String username;
  VideoStoriesByUser({this.userId,this.username});
  @override
  _VideoStoriesByUserState createState() => new _VideoStoriesByUserState();
}

class _VideoStoriesByUserState extends State<VideoStoriesByUser> {
final TextEditingController controller = TextEditingController();
bool isTextValid = false;
File fileToBeUploaded;
String uid;
@override
initState(){
  super.initState();
  _getPhoneNumber();
}

_getPhoneNumber() async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
   uid = prefs.getString('uid');
}

  Widget _videoStoriesByUser(BuildContext context){
    return StreamBuilder(stream: Firestore.instance.collection('userServiceVideos')
    .where('userId',isEqualTo: widget.userId)
              .orderBy('created_time', descending: true).snapshots(),builder: (BuildContext context,AsyncSnapshot<QuerySnapshot>snapshot){
                if(snapshot.hasError) return Center(child: Text('Oops something went wrong'),);
                
               switch (snapshot.connectionState) {
          case ConnectionState.waiting: return SpinKitPulse(
  color: Colors.white,
  size: 66.0,
);
          default:
            return snapshot.data.documents.length > 0 ? PageView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, position) {
          // AppVideoPlayer().
          return Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[AppVideoPlayer(url: '${snapshot.data.documents[position]['servicePhoto']}'), 
              onScreenControls(caption: '${snapshot.data.documents[position]['storyTitle']}',
              comment: '${snapshot.data.documents[position]['comment_sample']}',commenterPhotoUrl: '${snapshot.data.documents[position]['commenterPhotoUrl']}',
              commentNumbers: '${snapshot.data.documents[position]['commentNumbers']}',likes: '${snapshot.data.documents[position]['likes']}',username: '${snapshot.data.documents[position]['fullName']}',
              userPhotoUrl: '${snapshot.data.documents[position]['profilePicture']}',
              docID: '${snapshot.data.documents[position]['doc_id']}',
              uid: uid,shareUrl: '${snapshot.data.documents[position]['servicePhoto']}',
              userId: '${snapshot.data.documents[position]['userId']}',position: position,)],
            ),
          );
        },
        itemCount: snapshot.data.documents.length): Center(
          child: Text('Looks like no story has been shared.',style: TextStyle(color: Colors.white),),);
        }

                
              });
  }


Widget byUserHeader() {
  return Container(
    margin: EdgeInsets.only(top: 55),
    height: Dimen.headerHeight,
    child: Stack(children: <Widget>[
      Theme.of(context).platform == TargetPlatform.iOS ? Positioned(child: BackButton(color: Colors.white,onPressed: () async{
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  VideoStories()));
      },),left: 10.0,top: -14.0): SizedBox.shrink(),
      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(
            "Stories",
            style: TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Text("|",
            style: TextStyle(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text("By ${widget.username}",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        )
      ],
    )
    ],),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: new Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: <Widget>[
      _videoStoriesByUser(context),byUserHeader()],)
      ),onWillPop: () async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  VideoStories()));
        // swiper.controllerPageView.jumpToPage(2);
        return Future.value(false);
      },);
  }
}

class AppVideoPlayer extends StatefulWidget {
  final String url;
  // final int index;
  AppVideoPlayer({this.url});
  @override
  _AppVideoPlayerState createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
 VideoPlayerController _controller;
  @override
  void initState() {
    // print(widget.url);
    super.initState();
    _controller = VideoPlayerController.network(
        '${widget.url}')
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.initialized
          ? InkWell(child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),onTap: (){
              setState(() {
      if (_controller.value.isPlaying) {
        
        _controller.pause();
      } else {
        _controller.play();
      }
    });
            },)
          : SpinKitPulse(
  color: Colors.white,
  size: 66.0,
),
    );
  }

  @override
  void dispose() {
    super.dispose();
     _controller.pause();
    _controller.dispose();
  }
}


class onScreenControls extends StatefulWidget {
  final String username;
  final String caption;
  final String comment;
  final String likes;
  final String commentNumbers;
  final String userPhotoUrl;
  final String commenterPhotoUrl;
  final String docID;
  final String uid;
  final String shareUrl;
  final String userId;
  final int position;
  onScreenControls({this.username,this.caption,this.comment,this.likes,
  this.commentNumbers,this.userPhotoUrl,this.commenterPhotoUrl,this.docID,this.uid,
  this.shareUrl,this.userId, this.position});
  @override
  _onScreenControlsState createState() => new _onScreenControlsState();
}

class _onScreenControlsState extends State<onScreenControls> {
Set shouldTogglePlay = Set();
String  progress = '';

  Widget videoControlAction({IconData icon, String label, double size = 26,int index = 0}) {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: Column(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
        Padding(
          padding: EdgeInsets.only(
              top: Dimen.defaultTextSpacing, bottom: Dimen.defaultTextSpacing),
          child: Text(
            label ?? "",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        )
      ],
    ),
  );
}

downloadFile(String url,int index,String fullName, String docId) async {
  Dio dio = Dio();
  
  PermissionStatus permissionStatus = await askPermisionStorage();
   if (permissionStatus == PermissionStatus.granted) {
       String dirloc = "";
        if (Platform.isAndroid) {
          dirloc = (await getExternalStorageDirectory()).path;
        } else {
          dirloc = (await getExternalStorageDirectory()).path;
        }
        var randid = '/' + randomAlpha(5);
        try{
          FileUtils.mkdir([dirloc]);
          await dio.download(url, dirloc + randid + ".mp4",
              onReceiveProgress: (receivedBytes, totalBytes) {
           setState(() {
             shouldTogglePlay.add(index);
              progress =
                  ((receivedBytes / totalBytes) * 100).toInt().toString();
            });
           if(progress == '100'){ // dirloc + 
                   GallerySaver.saveVideo(File(dirloc + randid + ".mp4").path).then((bool path) {
         print('Saved $path');
        });
                }
          });
        }catch(err){
         print(err);
        }
        // set the path and navigate to watch video
      // path = dirloc + randid + ".mp4";
      
//  // store path to db
//    await Firestore.instance.collection('userService').document(docId)
//    .setData({'path':path},merge: true);
  //  shouldTogglePlay.remove(index);
   } else {
     _handleInvalidPermissions(permissionStatus);
   }
 }


 askPermisionStorage() async {
  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted && permission != PermissionStatus.disabled) {
      Map<PermissionGroup, PermissionStatus> permissionStatus = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      return permissionStatus[PermissionGroup.storage] ?? PermissionStatus.unknown;
      
    } else {
      return permission;
    }
}

void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to storage denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.disabled) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Storage is not available on device",
          details: null);
    }
  }


Widget controlStream({String uid, String docID}){
  return StreamBuilder(stream:  Firestore.instance.collection('users')
                .document('$uid').collection('likes')
                .document('$docID').snapshots(),builder: (BuildContext context, snapshot){
  try{
return videoControlAction(icon: FontAwesomeIcons.heart, label: '${widget.likes == '0' ? '' : widget.likes}',
                index: snapshot.data['likes']);
  }catch(e){
return videoControlAction(icon: FontAwesomeIcons.heart, label: '${widget.likes == '0' ? '' : widget.likes}',
                index: 0);
  }
        });

}
Widget videoDesc(String username,String caption,String comment) {
  return Container(
    padding: EdgeInsets.only(left: 16, bottom: 60),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 7, bottom: 7),
          child: Text(
            "@$username",
            style: TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        Flexible(child: Padding(
          padding: EdgeInsets.only(top: 4, bottom: 7),
          child: AutoSizeText(
  '$caption',overflow: TextOverflow.ellipsis,
 style: TextStyle(color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w300),wrapWords: true,softWrap: true,
 maxLines: 1,
),
        ),),
        Row(
          children: <Widget>[
           comment.isNotEmpty ? Icon(
              Icons.whatshot,
              size: 19,
              color: Colors.white,
            ): SizedBox.shrink(),
           Flexible(child: comment.length > 53 ? FLNoticeBar(
    text: '$comment',
   textStyle: TextStyle(color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w300),
): AutoSizeText(
  '$comment',
 style: TextStyle(color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w300),wrapWords: true,overflow: TextOverflow.ellipsis,
 maxLines: 1,softWrap: true
),)
          ],
        ),
      ],
    ),
  );
}

Widget userProfile() {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: Column(
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                        image: new CachedNetworkImageProvider(
                       '${widget.userPhotoUrl}'),
                          fit: BoxFit.cover,
                            ), // to be back here 
                  border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                  color: Colors.black,
                  shape: BoxShape.circle),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              height: 18,
              width: 18,
              child: Icon(Icons.add, size: 10, color: Colors.white),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 42, 84, 1),
                  shape: BoxShape.circle),
            )
          ],
        )
      ],
    ),
  );
}
String numberFormatter(String count){
 try{
int convertCount = int.parse(count);
 if(convertCount > 999){
   return '${convertCount/1000}k';
 }else if (convertCount > 999999){
   return '${convertCount/1000000}m';
 }

 return convertCount == 0 ? '': convertCount;
 }catch(err){
return '';
 }
 
}
  @override
  Widget build(BuildContext context) {
    return new Container(
    child: Row(
      children: <Widget>[
        Expanded(flex: 5, child: videoDesc(widget.username, widget.caption, widget.comment)),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(bottom: 60, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(child: userProfile(),onTap: (){
                },),
                InkWell(child: 
                controlStream(docID: '${widget.docID}',uid: '${widget.uid}'), onTap: (){
                  print('I get run ass');
                 try{
                  Firestore.instance.collection('users')
                .document('${widget.uid}').collection('likes')
                .document('${widget.docID}').get().then((onValue){
                  if(onValue.exists && onValue.data['likes'] == 1){
                      Firestore.instance.collection('users')
                        .document('${widget.uid}').collection('likes')
                        .document('${widget.docID}').setData({'likes': 0},merge: true)
                        .then((removeCount){
                          Firestore.instance.collection('userServiceVideos')
                .document('${widget.docID}').get().then((likesDecrement){
                  Firestore.instance.collection('userServiceVideos')
                .document('${widget.docID}').setData({'likes': likesDecrement.data['likes'] - 1},merge: true).then((isDone){
                  print('is done');
                });
                });
                        });
                  }else{
                    // print('I am running else');
                    Firestore.instance.collection('userServiceVideos')
                        .document('${widget.docID}').get().then((likeVal){
                          Firestore.instance.collection('userServiceVideos')
                        .document('${widget.docID}').setData({'likes': likeVal.data['likes'] + 1},merge: true).then((onValue){
                      Firestore.instance.collection('users')
                        .document('${widget.uid}').collection('likes')
                        .document('${widget.docID}').setData({'likes': 1},merge: true);
                        }).then((isDone){
                          print('doneZZZZZ');
                        });
                        });
                        
                  }
                });
                  }catch(err){
                  print('HONCHO');
               
                  }
                },),
                InkWell(child: videoControlAction(icon: FontAwesomeIcons.comment, 
                label: '${widget.commentNumbers == '0' ? '' : widget.commentNumbers}'),onTap: (){
                  // goes to comments CommentsWid
                  // _controller.pause();
                  // _controller.dispose();
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => CommentsWid(uid: '${widget.userId}',docId: '${widget.docID}',)));
                },),// numberFormatter(widget.comment)
                InkWell(child: videoControlAction(icon: FontAwesomeIcons.download,
                label: '$progress',index: shouldTogglePlay.contains(widget.position) ? 1 : 0),onTap: (){ // tashi
                  downloadFile(widget.shareUrl,widget.position,widget.username,widget.uid);
                
                  // _saveNetworkVideo(widget.shareUrl);
                   },),
                // GestureDetector(child: videoControlAction(
                //     icon: AppIcons.reply, label: "Share", size: 27),onTap: (){
                //       Share.share('${widget.caption} ${widget.shareUrl}');
                //     },),
              widget.commenterPhotoUrl != 'N/A' ?  SpinnerAnimation(body: audioSpinner(widget.commenterPhotoUrl)): SizedBox.shrink()
              ],
            ),
          ),
        )
      ],
    ),
  );
  }
}