import 'dart:convert';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? image;
  final _picker = ImagePicker();
  bool showSpinner = false;
  var Result = '';

  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadImage();
      setState(() {});
    } else {
      print('no image selected');
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showSpinner = true;
    });

    String? filename = image?.path.split('/').last;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://f4a4-117-99-245-72.in.ngrok.io/upload'),
    );

    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(
      http.MultipartFile(
        'image',
        image!.readAsBytes().asStream(),
        image!.lengthSync(),
        filename: filename,
      ),
    );

    request.headers.addAll(headers);
    print("request: " + request.toString());
    var res = await request.send();
    var response = await http.Response.fromStream(res);

    var jsonData = jsonDecode(response.body);
    Result = jsonData['Result'];

    print(response.body);
    print("This is response: ${res.statusCode} ");
    print("This is response: ${res.statusCode} ");

    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });
      print('image uploaded');
    } else {
      print('failed');
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
            title: const Center(
          child: Text('Packet Originality Checking'),
        )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: Container(
                child: image == null
                    ? const Center(
                        child: Text(
                          'Click here to take photo',
                          style: TextStyle(fontSize: 25),
                        ),
                      )
                    : Center(
                        child: Image.file(
                          File(image!.path).absolute,
                          height: 400,
                          width: 400,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              Result,
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
