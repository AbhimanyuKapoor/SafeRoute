import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saferoute/services/auth/bloc/auth_bloc.dart';
import 'package:saferoute/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => __VerifyEmailViewState();
}

class __VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  children: [
                    SizedBox(height: 40),

                    // Icon Section
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
                        Icons.mark_email_unread_rounded,
                        size: 60,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We\'ve sent you a verification link',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7F8C8D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 48),

                    // Verification Info Card
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
                          // Success message
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF4A90E2).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: 48,
                                  color: Color(0xFF4A90E2),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Check Your Inbox',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'We\'ve sent you an email with a verification link. Please check your inbox and follow the instructions to verify your account.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2C3E50),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Divider with text
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Color(0xFFE8ECF1),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Didn\'t receive it?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7F8C8D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Color(0xFFE8ECF1),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          // Resend Email Button
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                const AuthEventSendEmailVerification(),
                              );
                            },
                            icon: Icon(Icons.send, size: 20),
                            label: Text(
                              'Resend Verification Email',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A90E2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Back to Login Button
                          OutlinedButton.icon(
                            onPressed: () async {
                              context.read<AuthBloc>().add(
                                const AuthEventLogout(),
                              );
                            },
                            icon: Icon(Icons.arrow_back, size: 20),
                            label: Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF4A90E2),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Color(0xFF4A90E2),
                                width: 2,
                              ),
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
