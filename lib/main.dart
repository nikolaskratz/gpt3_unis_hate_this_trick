import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(UnisHateThisTrick());

class UnisHateThisTrick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => InputScreen(),
        '/welcome': (context) => WelcomeScreen(),

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

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome!', style: Theme.of(context).textTheme.headline2),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _usernameTextController = TextEditingController();

  double _formProgress = 0;

  void _showWelcomeScreen() {
    Navigator.of(context).pushNamed('/welcome');
  }



  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: null,  // NEW
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
                maxLength: 300,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Put some example exam questions here...'
                ),
              )
          ),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 15,
                minLines: 10,
                maxLength: 300,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Put your course table of content here...'
                ),
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
            onPressed: _showWelcomeScreen, // UPDATED,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
