import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const OPENAI_KEY = String.fromEnvironment("OPENAI_KEY");

String text = "";

void main() => runApp(UnisHateThisTrick());

class UnisHateThisTrick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => InputScreen(),
        '/output': (context) => OutputScreen(),

      },
    );
  }
}

class InputScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.9,
          child: Card(
            child: InputForm(),
          ),
        ),
      ),
    );
  }
}

class OutputScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(text, style: Theme.of(context).textTheme.bodyText1),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  String apiRequestText = "";
  String input1 = "";
  String input2 = "";

  double _formProgress = 0;

  void _showOutputScreen() async {
    // Navigator.of(context).pushNamed('/output');
    // print("input1:"+input1);
    // print("input2:"+input2);
    apiRequestText = "This is the course content:\n\n" +input1 +
        "\n\nThese are example questions on the course content:\n\n" +input2 +
        "\n\n Generate more exam questions:";
    print(apiRequestText);

    var result = await http.post(
      Uri.parse("https://api.openai.com/v1/engines/davinci/completions"),
      headers: {
        "Authorization": "Bearer $OPENAI_KEY",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": apiRequestText,
        "max_tokens": 100,
        "temperature": 0.6,
        "top_p": 1,
        // "stop": "\n",
      }),
    );

    /// Decode the body and select the first choice
    var body = jsonDecode(result.body);
    text = body["choices"][0]["text"];
    print(text);
    Navigator.of(context).pushNamed('/output');
    //
    // apiRequestText += text;
    //
    // /// Store the response message
    // setState(() {
    //   messages.add(Message(text.trim(), false));
    // });

  }

  void sendAPI (String request) {
    // apiRequestText = apiRequestText + request;
    // print(apiRequestText);
    print(request);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // onChanged: null,  // NEW
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _formProgress),
          Text('UnisHateThisTrick', style: Theme
              .of(context)
              .textTheme
              .headline4),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(

                maxLines: 15,
                minLines: 10,
                maxLength: 3000,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Put your course table of content here...'
                ),
                onChanged: (text) => setState(() {
                  input1 = text;
                }),

          )),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 15,
                minLines: 10,
                maxLength: 3000,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Put some example exam questions here...'
                ),
                onChanged: (text) => setState(() {
                  input2 = text;
                }),

              )
          ),

          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.blue;
              }),
            ),
            onPressed: _showOutputScreen, // UPDATED,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}