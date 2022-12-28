import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_upload_serveer_flutter/upload_screen.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? image;
  final _picker = ImagePicker();
  bool showSpiner = false;

  Future getImage() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    } else {
      print("Image not selected!!");
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showSpiner = true;
    });

    var stream = http.ByteStream(image!.openRead());
    var length = await image!.length();
    var uri = Uri.parse('https://fakestoreapi.com/products');
    var request = http.MultipartRequest('POST', uri);

    request.fields['title'] = 'Static Title';

    var multipart = http.MultipartFile('image', stream, length);

    request.files.add(multipart);

    var response = await request.send();

    if(response.statusCode==200){
      setState(() {
        showSpiner = false;
      });
      print("Uploaded");
      print(response.stream.toString());
    }else{
      setState(() {
        showSpiner = false;
      });
      print("Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpiner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload Image'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                getImage();
              },
              child: Container(
                child: image == null
                    ? const Center(
                        child: Text('Please Pick Image'),
                      )
                    : Container(
                        child: Center(
                          child: Image.file(
                            File(image!.path).absolute,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: GestureDetector(
                onTap: (){
                  uploadImage();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  height: 50,
                  child:  const Center(
                    child: Text('Upload'),
                  ),

                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
