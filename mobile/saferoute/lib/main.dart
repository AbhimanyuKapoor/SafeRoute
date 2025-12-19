import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:saferoute/constants/routes.dart';
import 'package:saferoute/helpers/loading/loading_screen.dart';
import 'package:saferoute/services/auth/bloc/auth_bloc.dart';
import 'package:saferoute/services/auth/bloc/auth_event.dart';
import 'package:saferoute/services/auth/bloc/auth_state.dart';
import 'package:saferoute/services/auth/firebase_auth_provider.dart';
import 'package:saferoute/views/forgot_password_view.dart';
import 'package:saferoute/views/login_view.dart';
import 'package:saferoute/views/map_view.dart';
import 'package:saferoute/views/register_view.dart';
import 'package:saferoute/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {mapViewRoute: (context) => const MapView()},
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialise());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a momment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MapView();
        } else if (state is AuthStateNeedsverification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegsitering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}
