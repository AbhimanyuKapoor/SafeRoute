import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saferoute/services/auth/bloc/auth_bloc.dart';
import 'package:saferoute/services/auth/bloc/auth_event.dart';
import 'package:saferoute/services/auth/bloc/auth_state.dart';
import 'package:saferoute/utilities/dialogs/error_dialog.dart';
import 'package:saferoute/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              'We could not process your request, Please make sure you are a registered user by going back one step',
            );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background with map pattern
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF0F4F8),
                    Color(0xFFE1E8ED),
                    Color(0xFFD6E4F0),
                  ],
                ),
              ),
            ),
            // Map-like pattern overlay
            Positioned.fill(child: CustomPaint(painter: MapPatternPainter())),
            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 60,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No worries, we\'ll help you reset it',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F8C8D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 48),

                      // Reset Password Form Card
                      Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Info Text
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF7F9FC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(
                                    0xFF4A90E2,
                                  ).withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF4A90E2),
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Enter your email and we\'ll send you a password reset link.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2C3E50),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),

                            // Email Field
                            TextField(
                              controller: _controller,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              autofocus: true,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF2C3E50),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Your email address',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: 22,
                                ),
                                filled: true,
                                fillColor: Color(0xFFF7F9FC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE8ECF1),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF4A90E2),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Send Reset Link Button
                            ElevatedButton(
                              onPressed: () {
                                final email = _controller.text;
                                context.read<AuthBloc>().add(
                                  AuthEventForgotPassword(email: email),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Back to Login Button
                            TextButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthEventLogout(),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 18,
                                    color: Color(0xFF4A90E2),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: Color(0xFF4A90E2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
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

// Custom painter for map-like pattern in background
class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4A90E2).withValues(alpha: 0.03)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 60) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw random "roads"
    final roadPaint = Paint()
      ..color = Color(0xFF4A90E2).withValues(alpha: 0.05)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.2, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
