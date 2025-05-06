import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/responsive/responsive.dart';
import 'package:eventati_book/routing/routing.dart';

/// Main authentication screen that provides options to login, register, or reset password
class AuthScreen extends StatefulWidget {
  /// Creates an authentication screen
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: OrientationResponsiveBuilder(
          portraitBuilder: (context, constraints) {
            // Portrait mode: vertical layout
            return _buildPortraitLayout(context);
          },
          landscapeBuilder: (context, constraints) {
            // Landscape mode: horizontal layout
            return _buildLandscapeLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final bool isTablet = UIUtils.isTablet(context);
    final double titleFontSize = isTablet ? 60.0 : 50.0;
    final double buttonWidth = isTablet ? 300.0 : 200.0;
    final double buttonFontSize = isTablet ? 20.0 : 18.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: titleFontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height:
              isTablet
                  ? AppConstants.largePadding * 3
                  : AppConstants.largePadding * 2,
        ),
        _buildLoginButton(context, buttonWidth, buttonFontSize),
        const SizedBox(height: AppConstants.smallPadding),
        _buildRegisterButton(context, buttonWidth, buttonFontSize),
        const SizedBox(height: AppConstants.smallPadding),
        _buildForgotPasswordLink(context, buttonFontSize),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final bool isTablet = UIUtils.isTablet(context);
    final double titleFontSize = isTablet ? 50.0 : 40.0;
    final double buttonWidth = isTablet ? 250.0 : 180.0;
    final double buttonFontSize = isTablet ? 18.0 : 16.0;

    return Row(
      children: [
        // Left side: App title
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Right side: Buttons
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoginButton(context, buttonWidth, buttonFontSize),
              const SizedBox(height: AppConstants.smallPadding),
              _buildRegisterButton(context, buttonWidth, buttonFontSize),
              const SizedBox(height: AppConstants.smallPadding),
              _buildForgotPasswordLink(context, buttonFontSize),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    double width,
    double fontSize,
  ) {
    return ElevatedButton(
      onPressed: () {
        NavigationUtils.navigateToNamed(context, RouteNames.login);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding * 2,
            vertical: AppConstants.mediumPadding,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(width, 40)),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
      child: Text(
        'Login',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildRegisterButton(
    BuildContext context,
    double width,
    double fontSize,
  ) {
    return ElevatedButton(
      onPressed: () {
        NavigationUtils.navigateToNamed(context, RouteNames.register);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding * 2,
            vertical: AppConstants.mediumPadding,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(width, 40)),
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).primaryColor,
        ),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
      child: Text(
        'Register',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context, double fontSize) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: AppConstants.mediumPadding),
        child: InkWell(
          onTap: () {
            NavigationUtils.navigateToNamed(context, RouteNames.forgotPassword);
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
