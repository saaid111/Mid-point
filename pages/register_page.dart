import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_week/components/my_button.dart';
import 'package:study_week/components/my_textfield.dart';
import 'package:study_week/components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap}); 
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
 
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // Sign user up
  void signUserUp() async {
  // Show loading animation
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    // Firebase user create
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: usernameController.text,
      password: passwordController.text,
    );

    // If successful, pop the loading dialog
    
    Navigator.pop(context);

  } on FirebaseAuthException catch (e) {
    // Pop the loading dialog
   
    Navigator.pop(context);

    //print('FirebaseAuthException: ${e.code}');

    // Show an error message based on the exception
    if (e.code == 'invalid-credential') {
      wrongEmailMessage();
      
    } 
    
    //wrong password
    else if (e.code == 'wrong-password') {
      wrongPasswordMessage();
      
    }
  }
}


  //wrong email popup
  void wrongEmailMessage() {
  showDialog(
    context: context, // This context must be valid
    builder: (context) {
      return const AlertDialog(
        title: Text('Incorrect email or password'),
      );
    },
  );
}

void wrongPasswordMessage() {
  showDialog(
    context: context, // This context must be valid
    builder: (context) {
      return AlertDialog(
        title: Text('Incorrect email or password'),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Logo
                const Icon(Icons.lock, size: 100),

                const SizedBox(height: 50),

                // Welcome text
                Text(
                  'Welcome to StudyWeek',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 25),

                // Email text field
                MyTextField(
                  controller: usernameController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 14),

                // Password text field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Forgot password
                

                const SizedBox(height: 10),

                // Sign in button
                MyButton(
                  text: "sign Up",
                  onTap: signUserUp,
                ),

                const SizedBox(height: 20),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Google Sign-in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    // Google button
                    SquareTile(imagePath: 'lib/images/google.jpg'),
                    SizedBox(width: 25),
                  ],
                ),

                const SizedBox(height: 20),

                // Not a member? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already signed up?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

