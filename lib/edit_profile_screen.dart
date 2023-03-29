import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:m3_task/main.dart';
class EditProfileScreen extends StatefulWidget {
  String? doccId;
  EditProfileScreen({Key? key,@required this.doccId}) : super(key: key);
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {


  final TextEditingController _empFirstNameEditingController = TextEditingController();
  final TextEditingController _empLastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  @override
  void initState()
  {
    getData();
    super.initState();
  }
  String role = '';
  getData()
  async{
    await  FirebaseFirestore.instance.collection("employees").doc(widget.doccId).get().then((value)
    {
      print(value.data()!["id"]);
      _empFirstNameEditingController.text = value.data()!["First Name"];
      _empLastNameController.text = value.data()!["Last Name"];
      role = value.data()!['Role'];
      role=='Executive'?designation=value.data()!['Designation']:designation ='';
      _mobileNumberController.text = value.data()!['Mobile Number'].toString();
      _whatsAppController.text = value.data()!['Whatsapp Number'].toString();
      _emailController.text = value.data()!['Official Email'].toString();
      status = value.data()!['Status'];
      gender = value.data()!["Gender"];
    });
    setState(() {
    });
  }
  bool loading = false;
  int expandedInt = 2;
  String designation = '';
  String gender = '';
  bool? status;
  final List<String> listOfRole = ["Executive","Manager"];

  final List<String> listOfGender = ["Male","Female"];
  final List<String> listOfDesignation = ["Dev","Test"];
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Edit profile Screen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(left: 10),
              height: 350,
              width: width,
              color: Colors.grey,
              child: Column(
                children: [
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Emp first Name:"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          SizedBox(height: 45,child: TextField(
                            controller: _empFirstNameEditingController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: 'edit emp first name',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                )
                            ),
                          ),)
                      )
                    ],
                  )),
                  const SizedBox(height: 10,),
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Emp Last Name:"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          SizedBox(height: 45,child: TextField(
                            controller: _empLastNameController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: 'edit emp last name',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                )
                            ),
                          ),)
                      )
                    ],
                  )),
                  const SizedBox(height: 10,),

                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Gender :"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          gender!=''?SizedBox(height: 45,child:
                         DropdownButton<String>(
                            value: gender,
                            hint: Text(gender),
                            items: [
                              // const DropdownMenuItem<String>(
                              //   value: "",
                              //   child: Text("select gender",style: TextStyle(color:Colors.black),),
                              // ),
                              ...listOfGender.map((e) {
                                return DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e.toString()),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                gender = value!;
                              });
                              print(listOfRole);
                            },
                          ),):SizedBox()
                      )
                    ],
                  )),

                  const SizedBox(height: 10,),
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Role :"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          SizedBox(height: 45,child:
                          DropdownButton<String>(
                            value: role,
                            hint: Text(role),
                            items: [
                              const DropdownMenuItem<String>(
                                value: "",
                                child: Text("select role",style: TextStyle(color:Colors.black),),
                              ),
                              ...listOfRole.map((e) {
                                return DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e.toString()),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                role = value!;
                              });
                              print(listOfRole);
                            },
                          ),)
                      )
                    ],
                  )),
                  role=='Executive'?
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Designation :"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                         role!=''?SizedBox(height: 45,child:
                          DropdownButton<String>(
                            value: designation,
                            hint: Text(designation),
                            items: [
                              // const DropdownMenuItem<String>(
                              //   value: "",
                              //   child: Text("select designation",style: TextStyle(color:Colors.black),),
                              // ),
                              ...listOfDesignation.map((e) {
                                return DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(e.toString()),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                designation = value!;
                              });
                            },
                          ),):SizedBox()
                      )
                    ],
                  )):SizedBox(),

                  const SizedBox(height: 10,),
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Mobile Number:"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          SizedBox(height: 45,child: TextField(
                            controller: _mobileNumberController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: 'edit mobile number',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                )
                            ),
                          ),)
                      )
                    ],
                  )),

                  const SizedBox(height: 10,),

                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Whatsapp Number:"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          SizedBox(height: 45,child: TextField(
                            controller: _whatsAppController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: 'edit whatapp number',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                )
                            ),
                          ),)
                      )
                    ],
                  )),


                  const SizedBox(height: 10,),
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Email :"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          SizedBox(height: 45,child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: 'edit Email',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                )
                            ),
                          ),)
                      )
                    ],
                  )),

                  const SizedBox(height: 10,),
                  Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          flex:1,
                          child: Text("Status :"
                            ,overflow: TextOverflow.ellipsis,)),
                      Expanded(
                          flex: expandedInt,
                          child:
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(height: 45,child: status!=null?
                            Switch(
                              onChanged: (vale){
                                print(vale);
                                setState(() {
                                  status =vale;
                                });
                              },
                              value: status!,
                            ):SizedBox(),),
                          )
                      )
                    ],
                  )),

                ],
              ),
            ),
            const SizedBox(height: 10,),
            MaterialButton(onPressed: ()async{
              setState(() {
                loading = true;
              });
              await FirebaseFirestore.instance.collection('employees').doc(widget.doccId).update({
                'First Name':_empFirstNameEditingController.text,
                'Last Name':_empLastNameController.text,
                'Role':role,
                'Gender':gender,
                'Designation':designation,
                'Mobile Number':_mobileNumberController.text,
                'Whatsapp Number':_whatsAppController.text,
                'Official Email':_emailController.text,
                'Status':status!=null?status!?true:false:true,
              });
              setState(() {
                loading=false;
              });
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const MyHome()));
            },
              color: Colors.purple,
              child: loading?SizedBox(
                width: 70,
                child: Row(
                  children: [
                    Text("update "),
                    const SizedBox(width: 5,),
                    SizedBox(
                      height:17,
                      width: 17,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.black,
                      ),
                    )
                  ],
                ),
              ):Text("update"),)
          ],
        ),
      ),
    );
  }
}
