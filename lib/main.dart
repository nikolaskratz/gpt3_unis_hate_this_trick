import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:group_button/group_button.dart';
import 'package:multiline/multiline.dart';


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

      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Image.asset('/home/niko/Documents/GPT3_Hackathon/gpt3_unis_hate_this_trick/assets/Frame3.png'),
                Card(child: InputForm(),)
              ],
            ),
          )
          // child: Column(
          //   children: [
          //     Card(child: InputForm(),),
          //     Image.asset('/home/niko/Documents/GPT3_Hackathon/gpt3_unis_hate_this_trick/assets/HomepageImage.png')
          //   ],
          // )
        ),
      ),
    );


    // return Scaffold(
    //
    //   backgroundColor: Colors.grey[200],
    //   body: Center(
    //     child: FractionallySizedBox(
    //       widthFactor: 0.8,
    //       heightFactor: 0.9,
    //       child: Card(
    //         child: InputForm(),
    //       ),
    //     ),
    //   ),
    // );
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

  String t1 = "";
  String t2 = "";
  String t3 = "";
  String t4 = "";

  String outputResult = "";

  List<String> splitA = [];

  double _formProgress = 0;

  void changeText(List<String> input) {
    while(input.length<6) {
      input.add(input[0]);
    }
    setState(() {
      t1 = input[0];
      t2 = input[1];
      t3 = input[2];
      t4 = input[3];
    });
  }

  void useHighlightedKeyword (int index) {
    highlightedKeyword = splitA[index];
    apiCallCounter++;
    _apiCall();
  }

  void updateResultOutput(String apiText) {
    setState(() {
      outputResult = apiText;
    });
  }

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
          temperature = 0.55;
          stop = "This is";
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
        temperature = 0.55;
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
        temperature = 0.65;
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

    // Decode the body and select the first choice
    var body = jsonDecode(result.body);
    apiOutputText = body["choices"][0]["text"];
    print("OUTPUT:\n" + apiOutputText);

    ///handling the API response
    switch(apiCallCounter) {
      case 0: {
        splitA = apiOutputText.split(',');
        print("\n SPLITa:");
        splitA.forEach((element) =>
            element=element.replaceAll("\n","")
        );
        splitA.forEach((element) =>
            print(element)
        );


        changeText(splitA);
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
        updateResultOutput(apiOutputText);
        apiCallCounter = 0;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // onChanged: null,  // NEW
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [



          Padding(
              padding: EdgeInsets.all(8.0),
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: TextField(
                  style: TextStyle(fontSize: 20),
                  maxLines: 13,
                  minLines: 13,
                  maxLength: 1000,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Put your course table of content here...'
                  ),
                  onChanged: (text) => setState(() {
                    input1 = text;
                  })
              ),


          )),

          // TextButton(
          //   style: ButtonStyle(
          //     foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          //       return states.contains(MaterialState.disabled) ? null : Colors.white;
          //     }),
          //     backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          //       return states.contains(MaterialState.disabled) ? null : Colors.blue;
          //     }),
          //
          //   ),
          //   onPressed: _apiCall, // UPDATED,
          //   child: Text('Submit'),
          // ),
          Container(
            height: 50.0,
            margin: EdgeInsets.all(10),
            child: RaisedButton(
              onPressed: _apiCall,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Container(
                  constraints:
                  BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Submit",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
            GroupButton(
                isRadio: true,
                spacing: 10,
                buttonHeight: 70,
                buttonWidth: 350,

                unselectedTextStyle: TextStyle(fontSize: 18, color: Colors.black),
                onSelected: (index, isSelected) => useHighlightedKeyword(index),
                selectedTextStyle: TextStyle(fontSize: 18),

                buttons: [t1,t2,t3,t4]),



          ),

          Text(outputResult, style: Theme.of(context).textTheme.headline5),
        ],
      ),
    );
  }
}