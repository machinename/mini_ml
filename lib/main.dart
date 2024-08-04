// Import necessary packages
import 'package:mini_ml/firebase_options_dev.dart'; // Import Firebase configuration for development
import 'package:mini_ml/screens/login/login.dart'; // Import the login screen widget
import 'package:mini_ml/screens/miscellaneous/home.dart'; // Import the home screen widget
import 'provider/app_provider.dart'; // Import the app provider for state management
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package for initialization
import 'package:flutter/material.dart'; // Import Flutter material design package
import 'package:provider/provider.dart'; // Import Provider package for state management

// To Do - Implement
// MultiProvider(
//   providers: [
//     Provider<Something>(create: (_) => Something()),
//     Provider<SomethingElse>(create: (_) => SomethingElse()),
//     Provider<AnotherThing>(create: (_) => AnotherThing()),
//   ],
//   child: someWidget,
// )

// Entry point of the application
void main() async {
  // Ensure that the Flutter engine is initialized before performing asynchronous operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with development configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptionsDev
        .currentPlatform, // Use development Firebase options
  );

  // Run the application
  runApp(
    const MiniML(), // Start the app with the MiniML widget as the root
  );
}

// The root widget of the application
class MiniML extends StatelessWidget {
  const MiniML({super.key});

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider to provide AppProvider to the widget tree
    return ChangeNotifierProvider(
      create: (context) => AppProvider()
        ..fetchAppData(), // Create AppProvider instance and fetch app data
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false, // Disable the debug banner in the app
        title: 'Mini ML', // Set the title of the app
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors
                .indigoAccent, // Define the color scheme with a seed color
          ),
          useMaterial3: true, // Enable Material Design 3
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                allowSnapshotting: false,
                allowEnterRouteSnapshotting:
                    false, // Define page transitions for Android
              ),
            },
          ),
        ),
        home:
            const AuthenticationWrapper(), // Set the initial route of the app to AuthenticationWrapper
      ),
    );
  }
}

// Widget that decides which screen to display based on authentication status
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AppProvider from the context to check the authentication status
    final appProvider = Provider.of<AppProvider>(context);

    // Check if the current user is authenticated
    return appProvider.auth.currentUser != null
        ? const Home() // Show Home screen if authenticated
        : const Login(); // Show Login screen if not authenticated
  }
}
