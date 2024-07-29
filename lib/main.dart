// import 'package:mini_ml/firebase_options.dart';
import 'package:mini_ml/firebase_options_dev.dart';
import 'package:mini_ml/screens/login/login.dart';
import 'package:mini_ml/screens/home/home.dart';
import 'provider/app_provider.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // const String envFilePath = "/Users/kendricklawton/Desktop/mini_ml/.env";
  // try {
  //   await dotenv.load(fileName: envFilePath);
  // } catch (error) {
  //   throw Exception(error);
  // }

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
    options: DefaultFirebaseOptionsDev.currentPlatform,
  );
  runApp(
    const MiniML(),
  );
}

class MiniML extends StatelessWidget {
  const MiniML({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider()..fetchAppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'mini ML',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 0, 0)),
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                allowEnterRouteSnapshotting: false,
              ),
            },
          ),
        ),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return appProvider.auth.currentUser != null ? const Home() : const Login();
  }
}
