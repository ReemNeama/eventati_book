import 'package:eventati_book/screens/authentications/forgetpassword_screen.dart';
import 'package:eventati_book/screens/authentications/login_screen.dart';
import 'package:eventati_book/screens/authentications/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/responsive/responsive.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
            style: TextStyles.title.copyWith(
              fontSize: titleFontSize,
              color: Colors.white,
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
              style: TextStyles.title.copyWith(
                fontSize: titleFontSize,
                color: Colors.white,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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
        style: TextStyles.buttonText.copyWith(
          fontSize: fontSize,
          color: AppColors.primary,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding * 2,
            vertical: AppConstants.mediumPadding,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(width, 40)),
        backgroundColor: WidgetStateProperty.all(AppColors.primary),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
      child: Text(
        'Register',
        style: TextStyles.buttonText.copyWith(
          fontSize: fontSize,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgetpasswordScreen(),
              ),
            );
          },
          child: Text(
            'Forgot Password?',
            style: TextStyles.bodyMedium.copyWith(
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
