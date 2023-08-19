import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String pass = "";

  bool isHiddenPassword = true;

  final _formKey = GlobalKey<FormState>();

  Widget buildForgotPass(){
    return Container(
      alignment: Alignment.centerRight,
      child :   MaterialButton(
        onPressed: () {},
        padding: EdgeInsets.only(right: 0),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildSignUpBtn(){
    return GestureDetector(
      onTap: () {Navigator.pushNamed(context, '/registerPage');},
      child: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                  text: 'Don\'t have an Account? ',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                  )
              ),
              TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )
              )
            ]
        ),
      ),
    );
  }

  signInWithEmailAndPassword() async{
    try {
       await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found for that email."),
          ),
        );
       // print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong password provided for that user."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50,),
            Padding(
              padding: EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("NoTA", style:TextStyle(color: Colors.white, fontSize:40,fontWeight: FontWeight.bold,fontFamily:'Raleway'),),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: 60.0,
                  horizontal: 30.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10),)
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Text("Welcome Back!", style:TextStyle(color: Colors.black, fontSize: 30,fontFamily:'Raleway'),),

                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 20,),
                                Text(
                                  'Email or username',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    //       boxShadow: [BoxShadow(
                                    //       color: Color.fromRGBO(22, 224, 32, 0.298),
                                    //       blurRadius: 20,
                                    //        offset: Offset(0, 10)
                                    //  ),]
                                  ),
                                  child: TextField(
                                    onChanged: (value) {
                                      email = value;
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(top: 14),
                                        prefixIcon: Icon(
                                          Icons.email,
                                          color: Colors.teal,
                                        ),
                                        hintText: 'Email or username',
                                        hintStyle: TextStyle(
                                          color: Colors.black38,
                                        )
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Text(
                                  'Password',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextField(
                                    onChanged: (value) {
                                      email = value;
                                    },
                                    obscureText: isHiddenPassword,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(top: 14),
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Colors.teal,
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: _togglePasswordView,
                                          child: Icon(
                                            isHiddenPassword ? Icons.visibility :Icons.visibility_off,
                                          ),
                                        ),
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                          color: Colors.black38,
                                        )
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        SizedBox(height: 20,),
                        buildForgotPass(),
                        SizedBox(height: 30,),
                        Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  signInWithEmailAndPassword();
                                }
                              },
                              style: ElevatedButton.styleFrom(fixedSize: const Size(150, 70),shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),),backgroundColor: Colors.teal, foregroundColor: Colors.white),
                              child: Text(
                                "Login",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40,),
                        buildSignUpBtn(),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  void _togglePasswordView(){
    if(isHiddenPassword == true){
      isHiddenPassword = false;
    }else{
      isHiddenPassword = true;
    }
    setState(() {});
  }
}