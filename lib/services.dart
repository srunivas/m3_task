import 'package:flutter/material.dart';



/*-------- textHeadInk --------*/
Widget textHeadInk(String title)
{
  return Padding(padding: EdgeInsets.only(top: 10),
  child: Text(title,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.black),),);
}

/*-------- text field ---------*/
Widget textFieldController(TextEditingController _controller,String hintText)
{
  return Padding(padding: EdgeInsets.only(top: 10,),
  child: TextField(
    controller: _controller,
    keyboardType: hintText=="Mobile Number" || hintText=="Whatsapp Number" || hintText=="Alternate Mobile Number"
        || hintText=="Pin Code" || hintText=="Bank Account Number"?
    TextInputType.number:null,
    decoration: InputDecoration(
        hintText: hintText,

        contentPadding: EdgeInsets.only(left: 10),
        hintStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.black)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey)
        )
    ),
  ),);
}