import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reviews extends StatefulWidget {
  final String uid;
  Reviews({
this.uid
});
  @override
  _ReviewsState createState() => new _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
String _uid;
@override
void initState() {
 _uid = widget.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
          title: Text(
            'Reviews',
            style: TextStyle(color: Colors.black,fontFamily: 'Lexand',fontWeight: FontWeight.w900),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 1.0
      ),body: Column(children: <Widget>[

            new Expanded(
              child: StreamBuilder(builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(child: Text('Loading reviews...'),);
                }
                return  ListView.builder(itemBuilder: (context, int index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Row(
                        children: <Widget>[
                           Padding(
                                          child: Container(
                                              width: 48.2,
                                              height: 48.2,

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
                                          padding: EdgeInsets.only(
                                              top: 5.0,
                                              left: 5.0,
                                              right: 5.0,
                                              bottom: 1.0),
                                        ),
                          Padding(child: Text('${snapshot.data.documents[index]['commenter_name']}',
                            style: TextStyle(fontWeight: FontWeight.w900, ),),
                            padding: EdgeInsets.all(3.0),
                          )
                        ],
                      ),

                       Padding(
                        child:    Container(
                  child: Text(
                   '${snapshot.data.documents[index]['raterComment']}',
                    style: TextStyle(color: Color(0xff203152)),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Color(0xffE8E8E8), borderRadius: BorderRadius.circular(8.0)),
                ),
                        padding: EdgeInsets.only(left: 43.0,top: 1.0,bottom: 0),
),
                    
                      SizedBox(height: 10.0,)
                    ],
                  );
                }, itemCount: snapshot.data.documents.length,);
              },stream: Firestore.instance.collection('saloonServiceProvider').document(_uid)
              .collection('reviews').where('uid',isEqualTo: _uid).snapshots(),),),
           

          ],),);
  }
}