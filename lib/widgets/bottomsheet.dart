import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditSheets extends StatefulWidget {
  final String actionPlaceholder;
  EditSheets({this.actionPlaceholder});
  @override
  _EditSheetsState createState() => _EditSheetsState();
}

class _EditSheetsState extends State<EditSheets> {
final TextEditingController controller = TextEditingController();
bool _isTextValid = false;

void _submit() async{
print('submittint');
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
            Center(child: Padding(child: 
            Text('${widget.actionPlaceholder}',style: 
            TextStyle(color: Colors.white,
            fontWeight: FontWeight.w600,fontSize: 28.6,
            letterSpacing: .9,
            fontFamily:'Merienda'),
            textAlign: TextAlign.center),padding: EdgeInsets.only(top:18.0,bottom: 1.0,left: 18.0,right: 18.0),)),
            // Padding(child: 
            // Text('Share with the world',style: 
            // TextStyle(
            //   wordSpacing: -0.800,
            //   color: Colors.white,
            // fontWeight: FontWeight.w400,fontSize: 17.3,
            // letterSpacing: .9,
            // fontFamily:'NunitoSans'),
            // textAlign: TextAlign.center),padding: EdgeInsets.all(1.0),),
            SizedBox(height: 78.0,),
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
                  errorText: _isTextValid ? 'Field Can\'t Be Blank' : null,
                  hintText: 'HeadHunt',
                  border: InputBorder.none,
                ),
              ),
            ),
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
              _submit();
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

        });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}