import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const OPENAI_KEY = String.fromEnvironment("OPENAI_KEY");

String apiOutputText = "";

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
        child: Text(apiOutputText, style: Theme.of(context).textTheme.bodyText1),
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
  int apiCallCounter = 0;
  int maxTokens = 50;
  double temperature = 0.3;
  String stop = "";

  String highlightedKeyword = "";
  String questionKeyword = "";

  double _formProgress = 0;

  void _apiCall() async {

    //building the prompt and setting params
    switch(apiCallCounter) {
      case 0: { //Todo: adapt temperature and other parameters in each switch
          apiRequestText = "This is the course content:\n\n"
              "- Introduction to user modeling\n"
              "- User profile acquisition and management\n"
              "- User modeling methods, e.g. Bayes networks\n\n"
              "Keywords: user modeling, user profile acquisition, user profile management, user modeling methods, bayes networks\n\n"
              "This is the course content:\n\n" + input1 + "\n\nKeywords:";
          maxTokens = 30;
          temperature = 0.45;
          stop = "This";
      }
      break;

      case 1: {
        print("HIGHGLITED_KW: "+highlightedKeyword);
        apiRequestText = "Name three keywords on this topic: recommender systems\n\n"
            "- Collaborative filtering\n"
            "- Multi-criteria recommender systems\n"
            "- Risk-aware recommender systems\n\n"
            "Name three different keywords on this topic: "+highlightedKeyword;
        maxTokens = 30;
        temperature = 0.45;
        stop = "Name";
      }
      break;

      case 2: {
        print("QUESTION_KW: "+questionKeyword);
        apiRequestText = "First topic: recommender systems\n\n"
            "a) Define the term “authentication.\n"
            "b) Briefly explain a method for non-intrusive user identification.\n"
            "c) Discuss whether the following statement is right or wrong: "
            "\“Implicit user profiling methods usually offer more control for the user over the data collected about herself/himself.\”\n"
            "d) What is the difference between a “Feature Augmentation (FA)” and “Feature Combination (FC)” hybrid recommender?\n\n"
            "Second topic: "+questionKeyword;
        maxTokens = 200;
        temperature = 0.45;
        stop = "Third";
      }
    }
    print("API_REQUEST_TEXT:\n" + apiRequestText);

    //contacting the API
    var result = await http.post(
      Uri.parse("https://api.openai.com/v1/engines/davinci/completions"),
      headers: {
        "Authorization": "Bearer $OPENAI_KEY",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": apiRequestText,
        "max_tokens": maxTokens,
        "temperature": temperature,
        "top_p": 1,
        "stop": stop,
        // "stop": "\n",
      }),
    );

    /// Decode the body and select the first choice
    var body = jsonDecode(result.body);
    apiOutputText = body["choices"][0]["text"];
    print("OUTPUT:\n" + apiOutputText);

    //handling the API response
    switch(apiCallCounter) {
      case 0: {
        List<String> splitA = apiOutputText.split(',');
        print("\n SPLITa:");
        splitA.forEach((element) =>
            print(element)
        );

        //dummyUserSelection
        highlightedKeyword = splitA[2];

        apiCallCounter++;
        _apiCall();
      }
      break;

      case 1: {
        List<String> splitB = apiOutputText.split('- ');
        print("\n SPLITb:");
        splitB.forEach((element) =>
            print(element)
        );

        //fixed to 2nd list entry, later on all
        questionKeyword = splitB[2];
        apiCallCounter++;
        _apiCall();
      }
      break;

      case 2: {
        apiCallCounter = 0;
      }
    }

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


          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                return states.contains(MaterialState.disabled) ? null : Colors.blue;
              }),
            ),
            onPressed: _apiCall, // UPDATED,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}