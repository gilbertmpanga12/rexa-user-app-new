import './subcollection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home>{

  void initState(){
  super.initState();
}

void _newTaskModalBottomSheet(context, String searchTerm) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
),
      context: context,
      builder: (BuildContext bc){
          return  Container(
            height: 260.0,
            child: StreamBuilder(stream: Firestore.instance.
              collection('subcategories').where('categoryName',isEqualTo: '$searchTerm')
              .snapshots(),
              builder: (context, snapshot){
              
                if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator(),);
                }
                if(snapshot.hasError){
                  print('Error is defiend');
                }

                return Scrollbar(
                  
                  child: ListView.separated(itemBuilder: (context,index){
                return Padding(child: ListTile(
            // trailing: Icon(Icons.keyboard_arrow_right,color: Colors.white,),
            title: new Text('${snapshot.data.documents[index]['subCatName']}', style: TextStyle(color: Colors.white,fontSize: 18.0),), // ${snapshot.data.documents[index]['categoryName']}
            onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context) {
  return Subcat(categoryName: snapshot.data.documents[index]['subCatName'],);
}));
                  
            },          
          ),padding: EdgeInsets.all(1.0),);
              },itemCount: snapshot.data.documents.length,
              separatorBuilder: (context,index) => Divider(color: Colors.transparent,),),);

              },),);
          
      }
    );
}


  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          leading:  AppBar(leading: Theme.of(context).platform == TargetPlatform.iOS ? BackButton(color: Colors.black,onPressed: () async{
        Navigator.popAndPushNamed(context, '/home'); 
      },): SizedBox.shrink(), backgroundColor: Colors.white,elevation: 0,),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 1.0,
          title: Text('Categories',style: TextStyle(
              fontSize: 20.0,letterSpacing: .4,
              color: Colors.black,fontFamily: 'Rukie',fontWeight: FontWeight.w600),),centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('saloonCategory').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError){
          return new Text('Error: ${snapshot.error}');
        }
        
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Center(child: CircularProgressIndicator(),);
          default:
            return snapshot.data.documents.length >= 0 ? ListView.separated(
              itemBuilder: (context, index){
                return  Padding(
                    padding: EdgeInsets.only(top: 6.0,bottom: 6.0),
                    child: ListTile(onTap: (){
          _newTaskModalBottomSheet(context,'${snapshot.data.documents[index]['categoryName']}');
          },
                  trailing: Icon(Icons.keyboard_arrow_right),
                  title: new Text('${snapshot.data.documents[index]['categoryName']}',style:TextStyle(
                                fontSize: 20.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,fontFamily: 'NunitoSans'),textAlign: TextAlign.left,) 
                  // subtitle: new Text(document['author']),
                ),);
              },itemCount: snapshot.data.documents.length ,separatorBuilder: (context, index) => Divider(),
            ): Center(child: Text('Services not yet added'),);
        }
      },
    )

    );

  }



}
