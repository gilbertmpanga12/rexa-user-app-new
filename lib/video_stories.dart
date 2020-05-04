
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_utils/file_utils.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rexa/strings.dart';
import 'package:rexa/videostoriesbyuser.dart';

import './spinner_animation.dart';
import './styles_beauty.dart';
import './video_stories.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'app_services/localizer.dart';
import 'audiospinner.dart';
import 'comments.dart';
import 'dimen.dart';
import './home_header.dart';
import 'notice_bar.dart';
import './swiper.dart' as swipe;


class VideoStories extends StatefulWidget {
  final String userId;
  final String username;
  VideoStories({this.userId,this.username});
  @override
  _VideoStoriesState createState() => new _VideoStoriesState();
}

class _VideoStoriesState extends State<VideoStories> {
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

  Widget _videoStories(BuildContext context){
    return StreamBuilder(stream: Firestore.instance.collection('userServiceVideos')
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
              userId: '${snapshot.data.documents[position]['userId']}',postion: position,)],
            ),
          );
        },
        itemCount: snapshot.data.documents.length): Center(
          child: Text('Looks like no story has been shared.',style: TextStyle(color: Colors.white),),);
        }

                
              });
  }


void _settingModalBottomSheet(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
),
      elevation: 3.0,backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            // Center(child: Padding(child: 
            // Text('What\'s new ?',style: 
            // TextStyle(color: Colors.white,
            // fontWeight: FontWeight.w600,fontSize: 28.6,
            // letterSpacing: .9,
            // fontFamily:'Merienda'),
            // textAlign: TextAlign.center),padding: EdgeInsets.only(top:18.0,bottom: 1.0,left: 18.0,right: 18.0),)),
            // Padding(child: 
            // Text('Share with the world',style: 
            // TextStyle(
            //   wordSpacing: -0.800,
            //   color: Colors.white,
            // fontWeight: FontWeight.w400,fontSize: 17.3,
            // letterSpacing: .9,
            // fontFamily:'NunitoSans'),
            // textAlign: TextAlign.center),padding: EdgeInsets.all(1.0),),
            SizedBox(height: 20.0,),
            // ListView.builder(itemBuilder: (BuildContext),) inputBar()
           Padding(child:Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
           SizedBox(width: 13.0),
           InkWell(child: Icon(FontAwesomeIcons.image,
                size: 20.0, color: Color(0xff203152),),onTap: (){
                  shouldFromCamera(context);
                },),SizedBox(width: 5.0),
            Expanded(
              child: TextField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(500)
                ],
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                 maxLines: null,
                 controller: controller,
                decoration: InputDecoration(
                  errorText: isTextValid ? 'Storie Can\'t Be Blank' : null,
                  hintText: 'Share a video story',hintStyle:  TextStyle(
                    fontFamily: 'Rukie',fontSize: 20, 
                    fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            ),
           
            SizedBox(width: 8.0),
            InkWell(
              onTap: (){
                 shouldPickVideo(context);
              },
              child: Icon(FontAwesomeIcons.video,
                size: 20.0, color: Color(0xff203152)),),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    ),
          ),
          SizedBox(
            width: 5.0,
          ),
          InkWell(
            onTap: () {
              postImage(fileToBeUploaded);
            },
            child: CircleAvatar(
              child: Icon(FontAwesomeIcons.paperPlane),
            ),
          ),
        ],
      ),
    ),          padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))

          ],);
        }).whenComplete((){
controller.clear();
fileToBeUploaded = null;

        });
  }

  Widget inputBar(){
return  null;
    } 

   shouldPickVideo(BuildContext context) async {
      FocusScope.of(context).unfocus(focusPrevious: true);
    ImagePicker.pickVideo(source: ImageSource.gallery).then((image) {
      if(image == null){
      return;
      }
     fileToBeUploaded = image;
    });
  }

shouldFromCamera(BuildContext context) async{
   FocusScope.of(context).unfocus(focusPrevious: true);
  ImagePicker.pickVideo(source: ImageSource.camera).then((image) {
      if(image == null){
      return;
      }
     fileToBeUploaded = image;
    });
}

postImage(File image) async {
    // final url = randomAlpha(10);
    var storyTitle = controller.text.replaceAll("\n", " "); 
     controller.text.isEmpty ? isTextValid = true : isTextValid = false;
    if(isTextValid){
      return;
    }
    Navigator.of(context).pop();
 showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20.0))
),
            content: Row(
              children: <Widget>[
                Container(
                  child: CircularProgressIndicator(),
                  margin: EdgeInsets.only(right: 10.0),
                ),
                Container(
                  child: SizedBox(
                    width: 180.0,
                    child: SizedBox(
                        width: 200.0,
                        child:
                    Text(
                      '${DemoLocalizations.of(context).processing}',
                      style: TextStyle(fontSize: 17.0),
                    ),),
                  ),
                )
              ],
            ),
          );
        });
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = randomAlpha(10);
    final defaultVideo = 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/snowyscreen.gif?alt=media&token=35458d60-5e73-4e7e-ae13-aad26ff095ec';
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('${url}');
    final StorageUploadTask task =  firebaseStorageRef.putFile(image);


    task.onComplete.then((image) {
      
      firebaseStorageRef.getDownloadURL().then((result) {
        // final Map<String, dynamic> service = {
        //   'servicePhoto': result.toString(),
        //   'userId': prefs.getString('uid'),
        //   'fullName': prefs.getString('fullName'),
        //   'profilePicture': prefs.getString('profilePicture'),
        //   'isVideo': true,
        //   'storyTitle': storyTitle ,
        //   'hours': DateTime.now().hour,
        //   'doc_id': url,
        //   'videoDefault': defaultVideo,
        //   'path': 'N/A',
        //   'isChat': false
        // };
Firestore.instance.collection('userServiceVideos').document(url).setData({
'userId': prefs.getString('uid'),
'servicePhoto': result.toString(),
'fullName': prefs.getString('fullName'),
'created_time': DateTime.now(),
'doc_id': url,
'rating': '0',
'profilePicture': prefs.getString('profilePicture'),
'isRatedID': '',
'isVideo': true,
'comment_sample': '',
'count': '0',
'storyTitle': storyTitle ,
'full_date':  DateTime.now(),
'videoDefault': defaultVideo,
'path': 'N/A','commentNumbers':0,'likes':0,'commenterPhotoUrl':'N/A'
}).then((onValue){
Navigator.of(context,rootNavigator: true).pop();
              Fluttertoast.showToast(
        msg: "Uploaded Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    
controller.clear();
}).catchError((onError){
  Navigator.of(context,rootNavigator: true).pop();
             Fluttertoast.showToast(
        msg: "Oops something went wrong!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
            print('succ*********');
            throw Exception('Oops something wrong');
});

        
      });
    });
  }



  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: new Scaffold(
    
      backgroundColor: Colors.black,
      body: Stack(children: <Widget>[
      _videoStories(context), homeHeader(context)],),// ,homeHeader()
      floatingActionButton: FloatingActionButton(mini: true,
            onPressed: () {
               _settingModalBottomSheet(context);
            },
            child: Icon(
              Icons.add,
              color: Colors.blue[600]
            ),
            backgroundColor: Colors.white,focusElevation: 4.0,
            
          ),floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
      ),onWillPop: () async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  StylesBeautyWidget()));
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
  //     SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeRight,
  //     DeviceOrientation.landscapeLeft,
  // ]);
    super.initState();
    _controller = VideoPlayerController.network(
        '${widget.url}',)
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
              child: VideoPlayer(_controller,),
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
  //     SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeRight,
  //     DeviceOrientation.landscapeLeft,
  // ]);
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
  final int postion;
  
  onScreenControls({this.username,this.caption,this.comment,this.likes,
  this.commentNumbers,this.userPhotoUrl,this.commenterPhotoUrl,this.docID,this.uid,
  this.shareUrl,this.userId,this.postion});
  @override
  _onScreenControlsState createState() => new _onScreenControlsState();
}

class _onScreenControlsState extends State<onScreenControls> {
Set shouldTogglePlay = Set();
String  progress = '';
  Widget videoControlAction({IconData icon, String label, double size = 26,int index=0}) {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: Column(
      children: <Widget>[
        Icon(
          icon,
          color: index == 1 ? Colors.red: Colors.white,
          size: size,
        ),
        Padding(
          padding: EdgeInsets.only(
              top: Dimen.defaultTextSpacing, bottom: Dimen.defaultTextSpacing),
          child: Text(
            label ?? "",
            style: TextStyle(fontSize: 10, color: index == 1 ? Colors.red: Colors.white),
          ),
        )
      ],
    ),
  );
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


//  String basename(String path) => context.basename(path);
 
downloadFile(String url,int index,String fullName, String docId) async {
  PermissionStatus permissionStatus = await askPermisionStorage();
   if (permissionStatus == PermissionStatus.granted) {
      //  String dirloc = "";
      //   if (Platform.isAndroid) {
      //     dirloc = (await getExternalStorageDirectory()).path;
      //   } else {
      //     dirloc = (await getExternalStorageDirectory()).path;
      //   }
        var randid = '/' + randomAlpha(5);
        try{
          http.Client _client = new http.Client();
          var req = await _client.get(Uri.parse(url));
          var bytes = req.bodyBytes;
          String dir = (await getExternalStorageDirectory()).path;
          File file = new File('$dir/$randid');
          await file.writeAsBytes(bytes);
          print('File size:${await file.length()}');
          print(file.path);
        // GallerySaver.saveVideo(File(dirloc + randid + ".mp4").path).then((bool path) {
        //  print('Saved $path');
        // });
          return file;
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
                  Navigator.pushReplacement(context, 
                  MaterialPageRoute(builder: (context) => VideoStoriesByUser(userId: widget.userId,username: widget.username,)));
                },),
                InkWell(child: 
                controlStream(docID: '${widget.docID}',uid: '${widget.uid}'), onTap: (){
                
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
                },),
                InkWell(child: videoControlAction(icon: FontAwesomeIcons.download,
                label: '$progress',index: shouldTogglePlay.contains(widget.postion) ? 1 : 0),onTap: (){ // tashi
                  downloadFile(widget.shareUrl,widget.postion,widget.username,widget.uid);
                
                  // _saveNetworkVideo(widget.shareUrl);
                   },),// numberFormatter(widget.comment)
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