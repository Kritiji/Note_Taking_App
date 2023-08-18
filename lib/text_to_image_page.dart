import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const apiKey = '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';

class TextToImagePage extends StatefulWidget {
  @override
  _TextToImagePageState createState() => _TextToImagePageState();
}

class _TextToImagePageState extends State<TextToImagePage> {
  var sizes = ["Small", "Medium", "Large"];
  var values = ["256x256", "512x512", "1024x1024"];
  String? dropValue;
  var textController = TextEditingController();
  String image = '';
  bool isLoaded = false;

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('AI Image Generator'),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "eg. 'A monkey on moon'",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  flex: 1,
                  child: DropdownButton(
                    value: dropValue,
                    hint: const Text("Select Size"),
                    items: List.generate(
                        sizes.length,
                        (index) => DropdownMenuItem(
                            value: values[index], child: Text(sizes[index]))),
                    onChanged: (value) {
                      setState(() {
                        dropValue= value.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: StadiumBorder(),
              ),
              onPressed: () async{
                if(textController.text.isNotEmpty && dropValue != null && dropValue!.isNotEmpty){
                  setState(() {
                    isLoaded = false;
                  });
                  try {
                    image = await Api.generateImage(textController.text, dropValue!);
                    setState(() {
                      isLoaded = true;
                    });
                  } catch (e) {
                    print("Failed to fetch image: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to fetch image. Please try again later."),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter both the query and size."),
                    ),
                  );
                }
              },
              child: Text('Generate'),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 520,
              child: Card(
                elevation: 4,
                child: isLoaded ? Image.network(image)
                    : Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    // Implement download functionality
                  },
                  child: Text('Download'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    // Implement share functionality
                  },
                  child: Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class Api{
  static final url = Uri.parse("https://api.openai.com/v1/images/generations");

  static final headers ={
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  static generateImage(String text, String size) async{
    var res = await http.post(url,headers: headers,
      body: jsonEncode(
      {
        "prompt": text,
        "n": 1,
        "size": size
      }
     )
    );
    print('Response status code: ${res.statusCode}');
    print('Response body: ${res.body}');
    if(res.statusCode == 200)
      {
        var data = jsonDecode(res.body.toString());
        return data['data'][0]['url'].toString();
      }
    else{
      print("Failed to fetch image. Status code: ${res.statusCode}");
      throw Exception("Failed to fetch image. Status code: ${res.statusCode}");
    }
  }
}
