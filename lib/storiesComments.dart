import 'package:cached_network_image/cached_network_image.dart';

import './styles_beauty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
// import './swiper.dart' as swiper;

class StoriesComments extends StatefulWidget {
  final String uid;
  StoriesComments({this.uid});

  StoriesCommentsState createState() => StoriesCommentsState();
}

class StoriesCommentsState extends State<StoriesComments> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _uid;
  String _commenter_name;
  String _photoUrl;
  String _userId;
  String _comment;
   final myController = TextEditingController();

  getProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _commenter_name = prefs.getString('fullName');
      _photoUrl = prefs.getString('profilePicture');
      _userId = prefs.getString('uid');

    });
  }

mutateCount(String uid, String comment) async{
Firestore.instance.collection('userService').document(uid).setData({
  'count': FieldValue.increment(1),
  'comment_sample': comment,
  'commenter_name': _commenter_name,
  'photoUrl': _photoUrl
},merge: true).then((onValue){
print('');
}).catchError((err){
  print(err);
});
}

  initState(){
    _uid = widget.uid;
    getProfile();
    super.initState();
  }
   @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  build(BuildContext context) {
    return WillPopScope(child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Comments",
     style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 20),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 3.0,

        ),
        body: Form(
          child: Column(children: <Widget>[
SizedBox(height: 10.5,),
            new Expanded(
              child: StreamBuilder(builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(child: Text('Loading comments...'),);
                }
                return  ListView.builder(itemBuilder: (context, int index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                     Container(child:  Row(
                        children: <Widget>[
                           Padding(
                                          child: Container(
                                            width: 30.5,
                                            height: 30.5,
                                            margin: EdgeInsets.only(top:0.8),
                                            decoration: new BoxDecoration(
                                              gradient: new LinearGradient(
                                                  colors: [
                                                    Colors.purple,
                                                    Colors.yellow
                                      ]),
//
                                              borderRadius: new BorderRadius
                                                      .all(
                                                  new Radius.circular(50.0)),
                                              border: new Border.all(
                                                color: Colors.grey[500],
                                                width: 0.9,
                                                style: BorderStyle.solid
                                              ),

                                            ),
                                            child: Container(
                                              width: 30.2,
                                              height: 30.2,

                                              decoration: new BoxDecoration(
                                                color: Colors.white,
                                                image: new DecorationImage(
                                                  image: new NetworkImage(
                                                      '${snapshot.data.documents[index]['photoUrl']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(50.0)),
                                                border: new Border.all(
                                                  color: Colors.white,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.only(
                                              top: 5.0,
                                              left: 5.0,
                                              right: 5.0,
                                              bottom: 1.0),
                                        ),
                          Text('${snapshot.data.documents[index]['commenter_name']}',
                            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Rukie'),)
                        ],
                      ),height:30),

                       Padding(
                        child:    Container(
                          
                          margin: EdgeInsets.all(0),
                  child: Text(
                   '${snapshot.data.documents[index]['comment']}',
                    style: TextStyle(color: Color(0xff203152)),
                  ),
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Color(0xffE8E8E8), borderRadius: BorderRadius.circular(8.0)),
                ),
                        padding: EdgeInsets.only(left: 40.0,top: 5.0,bottom: 0),
),
                    
                      SizedBox(height: 5.0,)
                    ],
                  );
                }, itemCount: snapshot.data.documents.length,);
              },stream: Firestore.instance.collection('comments').where('uid',isEqualTo: _uid).snapshots(),),),
            Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                ClipRRect(
              borderRadius: new BorderRadius.circular(30.0),
              child: CachedNetworkImage(
        imageUrl: "$_photoUrl",height: 40,width: 40,fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset('assets/images/blah.png',height: 45,width: 45,),
        errorWidget: (context, url, error) => Image.asset('assets/images/blah.png',height: 45,width: 45,),
     )),

                      new SizedBox(
                        width: 10.0,
                      ),

                      Expanded(
                        child: new TextFormField(
controller: myController,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            maxLines: 2,
                            
                            decoration: new InputDecoration(

                              suffixIcon: IconButton(
                                icon: Icon(FontAwesomeIcons.paperPlane,
                                  color: Colors.black,size: 23,), onPressed: () {
                                if (!_formKey.currentState.validate()) {
                                  return null;
                                }
                              
                                _formKey.currentState.save();
                                  
                                Firestore.instance.collection('comments').add({
                                  'userId': _userId,
                                  'commenter_name': _commenter_name,
                                  'photoUrl': _photoUrl,
                                  'comment':  _comment,
                                  'uid': _uid

                                }).then((val){
                                  mutateCount(_uid,_comment);
                                  Toast.show('Posted!',context,duration: 5,gravity: 1,backgroundColor: Colors.green);
                                  _formKey.currentState.reset();
                                  myController.clear();
//                                   setState(() {
// _comment = '';
//  });
                                
                                });
                              },),
                              border: InputBorder.none,
                              hintText: "Leave a comment",hintStyle: TextStyle(fontSize: 20,fontFamily: 'Rukie',fontWeight: FontWeight.w500)

                            ),
                            onSaved: (String val){
                              print('comment>>>>>>>>>>>>>>>>>>>>>>>>>>');
                              print(val);
                              print('comment');
                              print('val');
                              setState(() {
                                _comment = val;
                              });
                            },
                            validator: (String value) {
                              if (value.isEmpty && value.length <= 3000) {
                                return '';
                              } else {
                                return null;
                              }
                            }
                        ),
                      ),
                    ],
                  ),
                )
            )


          ],) ,
          key: _formKey,
        )),onWillPop: () async{
          Navigator.of(context).pop();
          // swiper.controllerPageView.jumpToPage(1);
          return Future.value(false);
        },);
  }
}
 