import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/medical_provider.dart';
import 'providers/connectivity_provider.dart';
import 'theme/app_theme.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/patient_dashboard.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProxyProvider<ConnectivityProvider, MedicalProvider>(
          create: (context) => MedicalProvider(context.read<ConnectivityProvider>()),
          update: (context, connectivity, previous) => 
              previous ?? MedicalProvider(connectivity),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappyHUB',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return auth.userRole == 'doctor'
                ? const DoctorDashboard()
                : const PatientDashboard();
          }

          return FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 3000)),
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
                child: snapshot.connectionState != ConnectionState.done
                    ? const SplashScreen(key: ValueKey('splash'))
                    : const LoginScreen(key: ValueKey('login')),
              );
            },
          );
        },
      ),
    );
  }
}
