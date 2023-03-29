import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:m3_task/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_profile_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}


class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  final List<String> listOfRole = ["Executive","Manager"];
  final List<String> listOfGender = ["Male","Female"];
  final List<String> listOfDesignation = ["Dev","Test"];
  late List<PlatformFile> listOfFiles = [];


  static final _stateStreamController = StreamController<List>.broadcast();
  static StreamSink<List> get _sink => _stateStreamController.sink;
  static Stream<List> get _stream => _stateStreamController.stream;


  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _officialEmailController = TextEditingController();
  final TextEditingController _personalEmailController = TextEditingController();
  final TextEditingController _mobileNumController = TextEditingController();
  final TextEditingController _alternateNumController = TextEditingController();
  final TextEditingController _whatsAppNumController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _ctcController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _panNumController = TextEditingController();
  final TextEditingController _workLocController = TextEditingController();



  String role = "";
  String gender = "";
  String designation = "";
  bool loading = false;

  List<File> listOfUniqueFiles = [];

  var listOfEmployees = [];
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future deleteDialog(String docID,String name)
  {
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure to delete account $name."),
        actions: [
          TextButton(onPressed: ()async{
            await FirebaseFirestore.instance.collection('employees').doc(docID).delete();
            await getData();
            Navigator.of(context).pop();
          }, child: Text("Yes")),
          TextButton(onPressed: ()async{
            Navigator.of(context).pop();
          }, child: Text("No")),
        ],
      );
    });
  }

  Future viewAlertDialog(List<dynamic> listOfLinkAvailable)
  {
    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context,StateSetter setState){
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          title: const Text("View Documents"),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                listOfLinkAvailable.length!=0?textHeadInk("Documents Upload"):textHeadInk("No Documents Upload"),
                Column(
                  children: List.generate(listOfLinkAvailable.length,
                          (index) {
                    return Row(
                      children: [
                        IconButton(onPressed: ()async{
                          print(listOfLinkAvailable[index]);
                          _launchURL(listOfLinkAvailable[index].toString());
                        }, icon: Icon(Icons.remove_red_eye)),
                        Text("Click icon to open",style: TextStyle(fontSize: 13),)
                      ],
                    );
                          })
                )

              ],
            ),
          ),
        );
      }),
    );
  }

  /*------ open pop up to add files -------*/
  Future alertDialog1(constraints,docID,listData)
  {
    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context,StateSetter setState){
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          title: const Text("Add Employee"),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                textHeadInk("Documents Upload"),
                Column(
                  children: List.generate(listOfUniqueFiles.length, (index){
                    return  Row(
                      children: [
                        IconButton(onPressed: (){
                          setState((){
                            listOfUniqueFiles.removeAt(index);
                          });
                        }, icon: Icon(Icons.cancel)),
                        Expanded(child:
                        Text(listOfUniqueFiles[index].path.split("/")[listOfUniqueFiles[index].path.split("/").length-1].toString(),
                          style: TextStyle(overflow: TextOverflow.ellipsis,fontSize: 12),))
                      ],
                    );
                  }),
                ),
                MaterialButton(
                  color: Colors.purple,
                  onPressed: ()
                  async{
                    listOfUniqueFiles = await selectFilesFromDirectory();
                    if(listOfUniqueFiles.length!=0)
                    {
                      setState((){
                        listOfUniqueFiles;
                      });
                    }
                  },child: Text("Choose File"),),

                const SizedBox(height: 10,),

                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: loading?120:90,
                    child: MaterialButton(
                      elevation: 0,
                      onPressed: ()async{
                        setState((){
                          loading = true;
                        });

                        List<String> listOfLinks = await uploadFilesInStorageBucket();
                        for(int j=0;j<listData.length;j++)
                          {
                            listOfLinks.add(listData[j].toString());
                          }
                        await FirebaseFirestore.instance.collection("employees").doc(docID).update({"Documents":listOfLinks});
                        await getData();
                        setState((){
                          loading = false;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          Text("Submit"),
                          loading?const SizedBox(width: 10,):SizedBox(),
                          loading?SizedBox(
                            height:17,
                            width: 17,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              backgroundColor: Colors.black,
                            ),
                          ):SizedBox()
                        ],
                      ),
                      color: Colors.purple,),
                  ),
                )

              ],
            ),
          ),
        );
      }),
    );
  }

  /*-------- removeDuplicateFiles ------------*/
  List<File> removeDuplicateFiles(List<File> files) {
    List<String> filePaths = [];
    List<File> uniqueFiles = [];

    for (File file in files) {
      if (!filePaths.contains(file.path)) {
        uniqueFiles.add(file);
        filePaths.add(file.path);
      }
    }

    return uniqueFiles;
  }

  /*-------- select Files --------*/
 Future<List<File>> selectFilesFromDirectory()
  async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any,allowMultiple: true);
    if (result != null) {
      PlatformFile file = result.files.first;
      for(int i=0;i<result.files.length;i++)
      {
        listOfUniqueFiles.add(File(result.files[i].path!));
      }
      listOfUniqueFiles = removeDuplicateFiles(listOfUniqueFiles);
      print(listOfUniqueFiles);
    } else {
      // User canceled the picker
    }
    return listOfUniqueFiles;
  }

  /*-------- upload files in Storage bucket ---------*/
 Future<List<String>> uploadFilesInStorageBucket()
  async{
    List<String> listOfLinks = [];

    for(int i=0;i<listOfUniqueFiles.length;i++)
      {
        final FirebaseStorage storage = FirebaseStorage.instance;
        final Reference ref = storage.ref().child('employee/${DateTime.now().toString()+listOfUniqueFiles[i].path.split("/")[listOfUniqueFiles[i].path.split("/").length-1].toString()}');

        File filew = File(listOfUniqueFiles[i].path);

        TaskSnapshot? snapshot = await ref.putFile(filew);
        String downloadURL = await snapshot.ref.getDownloadURL();
        listOfLinks.add(downloadURL.toString());
      }
    return listOfLinks;
  }

  /*-------- alert dialog box ---------*/
  Future alertDialog()
  {
    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context,StateSetter setState){
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          title: const Text("Add Employee"),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textHeadInk("Role"),
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
                ),

                textHeadInk("First Name"),
                SizedBox(height: 45,child: textFieldController(_firstNameController, "First Name"),),

                textHeadInk("Last Name"),
                SizedBox(height: 45,child: textFieldController(_lastNameController, "Last Name"),),

                textHeadInk("Gender"),
                DropdownButton<String>(
                  value: gender,
                  hint: Text(gender),
                  items: [
                    const DropdownMenuItem<String>(
                      value: "",
                      child: Text("select gender",style: TextStyle(color:Colors.black),),
                    ),
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
                ),

                textHeadInk("Official Email"),
                SizedBox(height: 45,child: textFieldController(_officialEmailController, "Official email"),),


                textHeadInk("Personal Email"),
                SizedBox(height: 45,child: textFieldController(_personalEmailController, "Personal Email"),),


                textHeadInk("Mobile Number"),
                SizedBox(height: 45,child: textFieldController(_mobileNumController, "Mobile Number"),),


                textHeadInk("Alternate Mobile Number"),
                SizedBox(height: 45,child: textFieldController(_alternateNumController, "Alternate Mobile Number"),),



                textHeadInk("Whatsapp Number"),
                SizedBox(height: 45,child: textFieldController(_whatsAppNumController, "Whatsapp Number"),),


                textHeadInk("Password"),
                SizedBox(height: 45,child: textFieldController(_passwordController, "Password"),),

                textHeadInk("Confirm Password"),
                SizedBox(height: 45,child: textFieldController(_confirmPassController, "Confirm Password"),),

                textHeadInk("Address"),
                SizedBox(height: 45,child: textFieldController(_addressController, "Address"),),

                textHeadInk("Landmark"),
                SizedBox(height: 45,child: textFieldController(_landmarkController, "Landmark"),),

                textHeadInk("City"),
                SizedBox(height: 45,child: textFieldController(_cityController, "City"),),

                textHeadInk("State"),
                SizedBox(height: 45,child: textFieldController(_stateController, "State"),),

                textHeadInk("Pin Code"),
                SizedBox(height: 45,child: textFieldController(_pinCodeController, "Pin Code"),),


                textHeadInk("CTC"),
                SizedBox(height: 45,child: textFieldController(_ctcController, "CTC"),),


                textHeadInk("Bank Name"),
                SizedBox(height: 45,child: textFieldController(_bankNameController, "Bank Name"),),


                textHeadInk("Bank Account Number"),
                SizedBox(height: 45,child: textFieldController(_bankAccountController, "Bank Account Number"),),


                textHeadInk("Bank IFSC Code"),
                SizedBox(height: 45,child: textFieldController(_ifscCodeController, "Bank IFSC Code"),),

                textHeadInk("PAN Number"),
                SizedBox(height: 45,child: textFieldController(_panNumController, "PAN Number"),),


                role=="Executive"?textHeadInk("Designation"):SizedBox(),
                role=="Executive"?DropdownButton<String>(
                  value: designation,
                  hint: Text(designation),
                  items: [
                    const DropdownMenuItem<String>(
                      value: "",
                      child: Text("select designation",style: TextStyle(color:Colors.black),),
                    ),
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
                    print(listOfRole);
                  },
                ):SizedBox(),

                textHeadInk("Work Location"),
                SizedBox(height: 50,child: textFieldController(_workLocController, "Work Location"),),

                textHeadInk("Documents Upload"),
                Column(
                  children: List.generate(listOfUniqueFiles.length, (index){
                    return  Row(
                      children: [
                        IconButton(onPressed: (){
                          setState((){
                            listOfUniqueFiles.removeAt(index);
                          });
                        }, icon: Icon(Icons.cancel)),
                        Expanded(child:
                        Text(listOfUniqueFiles[index].path.split("/")[listOfUniqueFiles[index].path.split("/").length-1].toString(),
                          style: TextStyle(overflow: TextOverflow.ellipsis,fontSize: 12),))
                      ],
                    );
                  }),
                ),
               MaterialButton(
                 color: Colors.purple,
                 onPressed: ()
               async{
                listOfUniqueFiles = await selectFilesFromDirectory();
                if(listOfUniqueFiles.length!=0)
                  {
                    setState((){
                      listOfUniqueFiles;
                    });
                  }
               },child: Text("Choose File"),),

               const SizedBox(height: 10,),

               Align(
                 alignment: Alignment.center,
                 child: SizedBox(
                   width: loading?120:90,
                   child: MaterialButton(
                     elevation: 0,
                     onPressed: ()async{
                       setState((){
                         loading = true;
                       });
                       Map<String,dynamic> data = {};
                       data = {"Role":role,"First Name":_firstNameController.text.toString(),"Last Name":_lastNameController.text.toString(),
                         "Gender":gender,"Official Email":_officialEmailController.text.toString(),"Personal Email":_personalEmailController.text.toString(),
                         "Mobile Number":_mobileNumController.text.toString(),"Alternate Mobile Number":_alternateNumController.text.toString(),
                         "Whatsapp Number":_whatsAppNumController.text.toString(),"Password":_passwordController.text.toString(),
                         "Confirm Password":_confirmPassController.text.toString(),"Address":_addressController.text.toString(),
                         "Landmark":_landmarkController.text.toString(),"City":_cityController.text.toString(),"State":_stateController.text.toString(),
                         "Pin Code":_pinCodeController.text.toString(),"CTC":_ctcController.text.toString(),"Bank Name":_bankNameController.text.toString(),
                         "Bank Account Number":_bankAccountController.text.toString(),"Bank IFSC Code":_ifscCodeController.text.toString(),
                         "PAN Number":_panNumController.text.toString(),"Work Location":_workLocController.text.toString(),"Status":true,
                       "Designation":designation,"time":DateTime.now()};
                       data["Documents"] = await uploadFilesInStorageBucket();
                       await FirebaseFirestore.instance.collection("employees").add(data);
                       await getData();
                       setState((){
                         loading = false;
                       });
                       Navigator.of(ctx).pop();
                     },
                     child: Row(
                       children: [
                         Text("Submit"),
                         loading?const SizedBox(width: 10,):SizedBox(),
                         loading?SizedBox(
                           height:17,
                           width: 17,
                           child: CircularProgressIndicator(
                             color: Colors.white,
                             backgroundColor: Colors.black,
                           ),
                         ):SizedBox()
                       ],
                     ),
                     color: Colors.purple,),
                 ),
               )

              ],
            ),
          ),
        );
      }),
    );
  }

  getData()
  async{
    await FirebaseFirestore.instance.collection("employees").get().then((value)
    {
  listOfEmployees = [];
      for(int i=0;i<value.docs.length;i++)
        {
          print(value.docs[i].id);
          var data = value.docs[i].data();
          data["id"] = value.docs[i].id;
          listOfEmployees.add(data);
        }
      _sink.add(listOfEmployees);
      print(listOfEmployees);
    });
  }

  @override
  void initState()
  {
    getData();
    super.initState();
  }

  int expandedInt = 2;

  int numberOfManagers(list)
  {
    int count = 0;
    for(int i=0;i<list.length;i++)
      {
        if(list[i]["Role"]!="Executive"){
          count+=1;
        }
      }
    return count;
  }

  int numberOfExecutives(list)
  {
    int count = 0;
    for(int i=0;i<list.length;i++)
    {
      if(list[i]["Role"]=="Executive"){
        count+=1;
      }
    }
    return count;
  }

  int numberOfMaleManagers(list)
  {
    int count = 0;
    for(int i=0;i<list.length;i++)
    {
      if(list[i]["Role"]!="Executive" && list[i]["Gender"]=="Male"){
        count+=1;
      }
    }
    return count;
  }
  int numberOfFemaleManagers(list)
  {
    int count = 0;
    for(int i=0;i<list.length;i++)
    {
      if(list[i]["Role"]!="Executive" && list[i]["Gender"]=="Female"){
        count+=1;
      }
    }
    return count;
  }
  int numberOfMaleExecutives(list)
  {
    int count = 0;
    for(int i=0;i<list.length;i++)
    {
      if(list[i]["Role"]=="Executive" && list[i]["Gender"]=="Male"){
        count+=1;
      }
    }
    return count;
  }
  int numberOfFemaleExecutives(list)
  {
    int count = 0;
    for(int i=0;i<list.length;i++)
    {
      if(list[i]["Role"]=="Executive" && list[i]["Gender"]=="Female"){
        count+=1;
      }
    }
    return count;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        onPressed: ()async{
          _firstNameController.text ='';
              _lastNameController.text = '';
              _officialEmailController.text = '';
                  _personalEmailController.text = '';
                  _mobileNumController.text = '';
                  _alternateNumController.text = '';
                  _whatsAppNumController.text = '';
                  _passwordController.text = '';
                  _confirmPassController.text = '';
                  _addressController.text = '';
                  _landmarkController.text = '';
                  _cityController.text = '';
                  _stateController.text = '';
                  _pinCodeController.text = '';
                  _ctcController.text = '';
                  _bankNameController.text = '';
                  _bankAccountController.text = '';
                  _ifscCodeController.text = '';
                  _panNumController.text = '';
                  _workLocController.text = '';
                  await alertDialog();
        },
      ),
      appBar: AppBar(
        elevation: 0,
        leading: SizedBox(),
        backgroundColor: Colors.purple,
        title: Text("Dashboard"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context,constraints)
        {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: StreamBuilder(
                    stream: _stream,
                    builder: (context,snapshot)
                    {
                      if(snapshot.hasData)
                      {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              margin: EdgeInsets.all(10),
                              height: 300,
                              width: constraints.maxWidth,
                              color: Colors.grey,
                              child: Column(
                                children: [
                                  Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("Total Number Of Employees:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(snapshot.data!.length.toString(),overflow: TextOverflow.ellipsis,))
                                    ],
                                  )),
                                  Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("Total Number Of Managers:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(numberOfManagers(snapshot.data).toString(),overflow: TextOverflow.ellipsis,))
                                    ],
                                  )),Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("Total Number Of Executives:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(numberOfExecutives(snapshot.data).toString(),overflow:
                                          TextOverflow.ellipsis,))
                                    ],
                                  )),Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("No Of Male Executives:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(numberOfMaleExecutives(snapshot.data).toString(),overflow:
                                          TextOverflow.ellipsis,))
                                    ],
                                  )),
                                  Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("No: Of Female Executives:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(numberOfFemaleExecutives(snapshot.data).toString(),overflow:
                                          TextOverflow.ellipsis,))
                                    ],
                                  )),Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("No: Of Male Managers:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(numberOfMaleManagers(snapshot.data).toString(),overflow:
                                          TextOverflow.ellipsis,))
                                    ],
                                  )),
                                  Expanded(child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex:2,
                                          child: Text("No: Of Female Managers:"
                                            ,overflow: TextOverflow.ellipsis,)),
                                      Expanded(
                                          flex: 1,
                                          child:
                                          Text(numberOfFemaleManagers(snapshot.data).toString(),overflow:
                                          TextOverflow.ellipsis,))
                                    ],
                                  ))
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: List.generate(snapshot.data!.length, (index) {
                                  return Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.only(left: 10),
                                    height: 320,
                                    width: constraints.maxWidth,
                                    color: Colors.grey,
                                    child: Column(
                                      children: [
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Sr no:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text((index+1).toString(),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Emp ID:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["id"],overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Emp Name:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["First Name"].toString()+" "+snapshot.data![index]["Last Name"].toString(),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),

                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Gender:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["Gender"].toString()
                                                    ,overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Role:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["Role"].toString(),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        snapshot.data![index]["Role"]=="Executive"?
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Designation:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["Designation"].toString(),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )):SizedBox(),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Mobile Numbers:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["Mobile Number"].toString()+" , "+
                                                    snapshot.data![index]["Whatsapp Number"].toString(),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Email:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["Official Email"].toString(),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Reg Date:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["time"].toDate().toString().substring(0,10),overflow: TextOverflow.ellipsis,))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Documents"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:Row(
                                                  children: [
                                                    IconButton(onPressed: (){
                                                      viewAlertDialog(snapshot.data![index]["Documents"]);
                                                    }, icon: Icon(Icons.remove_red_eye_outlined,size: 20,)),
                                                    const SizedBox(width: 10,),
                                                    IconButton(onPressed: ()async{
                                                      listOfUniqueFiles = [];
                                                      await alertDialog1(constraints, snapshot.data![index]["id"].toString(),snapshot.data![index]["Documents"]!=null?snapshot.data![index]["Documents"]:[]);
                                                    }, icon: Icon(Icons.add,size: 20,))
                                                  ],
                                                ))
                                          ],
                                        )),
                                        const SizedBox(height: 10,),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Action:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:Row(
                                                  children: [
                                                    IconButton(onPressed: (){
                                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                          EditProfileScreen(doccId: snapshot.data![index]["id"],)));
                                                    }, icon: Icon(Icons.edit,size: 20,)),
                                                    IconButton(onPressed: ()async{
                                                      await deleteDialog(snapshot.data![index]["id"],
                                                          snapshot.data![index]["First Name"]+" "+snapshot.data![index]['Last Name']);
                                                    }, icon: Icon(Icons.delete,size: 20,)),

                                                  ],
                                                ))
                                          ],
                                        )),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                                flex:1,
                                                child: Text("Status:"
                                                  ,overflow: TextOverflow.ellipsis,)),
                                            Expanded(
                                                flex: expandedInt,
                                                child:
                                                Text(snapshot.data![index]["Status"]?"Active".toString():"In Active",overflow: TextOverflow.ellipsis,))
                                          ],
                                        ))
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            )
                          ],
                        );
                      }
                      else
                      {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.purple,
                            backgroundColor: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ),
              )
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //
              //       // MaterialButton(onPressed: ()
              //       // async{
              //       //   // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any,allowMultiple: true);
              //       //   // if (result != null) {
              //       //   //   PlatformFile file = result.files.first;
              //       //   //   for(int i=0;i<result.files.length;i++)
              //       //   //     {
              //       //   //       listOfUniqueFiles.add(File(result.files[i].path!));
              //       //   //     }
              //       //   //   listOfUniqueFiles = removeDuplicateFiles(listOfUniqueFiles);
              //       //   //   print(listOfUniqueFiles);
              //       //   // } else {
              //       //   //   // User canceled the picker
              //       //   // }
              //       //
              //       //   await alertDialog(constraints);
              //       // },
              //       // child: Text("Add Employee",style: TextStyle(color: Colors.white),),
              //       // color: Colors.purple,)
              //   ],
              // ),
            ),
          );
        },
      ),
    );
  }
}
