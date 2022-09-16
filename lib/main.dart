import 'package:co2fzs_admin/models/user.dart' as model;
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/screens/locations/add_location_screen.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/screens/classes/request_screen.dart';
import 'package:co2fzs_admin/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/responsive/mobile_screen_layout.dart';
import 'package:co2fzs_admin/responsive/responsive_layout_screen.dart';
import 'package:co2fzs_admin/responsive/web_screen_layout.dart';
import 'package:co2fzs_admin/screens/auth/login_screen.dart';
import 'package:co2fzs_admin/screens/auth/signup_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: CO2FZSCONFIG.options,
    );
  } else {
    await Firebase.initializeApp();
  }
  //FirebaseAuth.instance.signOut();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'CO2fzs-Admin',
        theme: ThemeData(
          textTheme: const TextTheme(
            headline1: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 34,
                fontFamily: "Rubik",
                color: textColor),
            headline2: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              fontFamily: "Rubik",
              color: textColor,
            ),
            headline3: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              fontFamily: "Rubik",
              color: textColor,
            ),
            headline4: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 50,
              fontFamily: "Rubik",
              color: textColor,
            ),
            bodyText1: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 16,
                fontFamily: "Rubik",
                color: textColor),
            bodyText2: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
        routes: {
          ClassesScreen.routeName: (_) => const ClassesScreen(),
          AddLocationScreen.routeName: (_) => AddLocationScreen(),
          RequestScreen.routeName: (_) => RequestScreen(),
        },
        // home: const ResponsiveLayout(
        //   webScreenLayout: WebScreenLayout(),
        //   mobileScreenLayout: MobileScreenLayout(),
        // ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return const ResponsiveLayout(
                    webScreenLayout: WebScreenLayout(),
                    mobileScreenLayout: MobileScreenLayout(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              return LoginScreen();
            }),
      ),
    );
  }
}
