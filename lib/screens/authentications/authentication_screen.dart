import 'package:eventati_book/screens/authentications/forgetpassword_screen.dart';
import 'package:eventati_book/screens/authentications/login_screen.dart';
import 'package:eventati_book/screens/authentications/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppConstants.largePadding * 2),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding * 2,
                    vertical: AppConstants.mediumPadding,
                  ),
                ),
                minimumSize: WidgetStateProperty.all(const Size(200, 40)),
                backgroundColor: WidgetStateProperty.all(Colors.white),
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                ),
              ),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: AppConstants.smallPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding * 2,
                    vertical: AppConstants.mediumPadding,
                  ),
                ),
                minimumSize: WidgetStateProperty.all(const Size(200, 40)),
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).primaryColor,
                ),
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                ),
              ),
              child: const Text(
                "Register",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: AppConstants.smallPadding),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: AppConstants.mediumPadding),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetpasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
