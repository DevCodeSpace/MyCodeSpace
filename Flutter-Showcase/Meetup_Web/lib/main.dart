import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web_rtc/screens/login_dialog.dart';
import 'package:web_rtc/services/auth_service.dart';

import 'firebase_options.dart';
import 'screens/call_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/firebase_signaling_service.dart';
import 'services/webrtc_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const WebRTCApp());
}

class WebRTCApp extends StatefulWidget {
  const WebRTCApp({super.key});

  @override
  State<WebRTCApp> createState() => _WebRTCAppState();
}

class _WebRTCAppState extends State<WebRTCApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _lastProcessedUri;

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinking() async {
    appLinks = AppLinks();

    // Handle initial link (opened app from closed state)
    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Handle incoming links (app running in background/foreground)
    final sub = appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Error listening to incoming links: $err');
      },
    );
    _linkSubscription = sub;
  }

  void _handleDeepLink(Uri uri) {
    if (_lastProcessedUri == uri) {
      debugPrint('Ignoring duplicate deep link: $uri');
      return;
    }
    _lastProcessedUri = uri;
    Timer(const Duration(seconds: 2), () {
      if (_lastProcessedUri == uri) {
        _lastProcessedUri = null;
      }
    });

    debugPrint('Received deep link: $uri');

    // Support schemes:
    // - https://webrtc-demo-e307f.web.app/join/<roomId>
    // - codexmeet://join/<roomId>

    String? roomId;

    if (uri.scheme == 'codexmeet') {
      if (uri.host == 'join') {
        if (uri.pathSegments.isNotEmpty) {
          roomId = uri.pathSegments[0];
        }
      } else if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'join') {
        if (uri.pathSegments.length > 1) {
          roomId = uri.pathSegments[1];
        }
      }
    } else if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (uri.host == 'webrtc-demo-e307f.web.app') {
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'join') {
          if (uri.pathSegments.length > 1) {
            roomId = uri.pathSegments[1];
          }
        }
        // Fallback for hash-based URLs, e.g. /#/join/EAF780D1
        if (roomId == null && uri.fragment.isNotEmpty) {
          final fragmentUri = Uri.parse(uri.fragment);
          if (fragmentUri.pathSegments.isNotEmpty && fragmentUri.pathSegments[0] == 'join') {
            if (fragmentUri.pathSegments.length > 1) {
              roomId = fragmentUri.pathSegments[1];
            }
          }
        }
      }
    }

    if (roomId != null && roomId.isNotEmpty) {
      final cleanRoomId = roomId.toUpperCase();
      debugPrint('Navigating to room from deep link: $cleanRoomId');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/call', (route) => route.isFirst, arguments: {'roomId': cleanRoomId, 'createRoom': false});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Color(0xFF029AFF), brightness: Brightness.light);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        Provider<FirebaseSignalingService>(create: (_) => FirebaseSignalingService()),
        ChangeNotifierProvider<WebRTCService>(create: (context) => WebRTCService(signalingService: context.read<FirebaseSignalingService>())),
      ],
      child: MaterialApp(
        title: 'CodeX Meet',
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          textTheme: GoogleFonts.googleSansFlexTextTheme(ThemeData.light().textTheme),
          scaffoldBackgroundColor: Colors.white, //grey[50]
          appBarTheme: AppBarTheme(backgroundColor: Colors.white, elevation: 0),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[800],
            contentTextStyle: GoogleFonts.googleSans(color: Colors.white, fontSize: 14),
            behavior: SnackBarBehavior.floating,
            insetPadding: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            width: kIsWeb ? 320 : null,
          ),
          tooltipTheme: TooltipThemeData(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(120)),
            textStyle: GoogleFonts.googleSans(color: Colors.white, fontSize: 12),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            hintStyle: GoogleFonts.googleSans(color: Colors.grey[400], fontSize: 14),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');

    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'join') {
      final roomId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (roomId != null && roomId.isNotEmpty) {
        return MaterialPageRoute(
          builder: (_) => RootAuthGuard(child: CallScreen(roomId: roomId.toUpperCase(), createRoom: false)),
        );
      }
    }
    if (settings.name == '/call') {
      final args = settings.arguments as Map<String, dynamic>?;
      final roomId = args?['roomId'] as String?;
      final createRoom = args?['createRoom'] as bool? ?? false;
      if (roomId != null && roomId.isNotEmpty) {
        return MaterialPageRoute(
          builder: (_) => RootAuthGuard(
            child: CallScreen(roomId: roomId.toUpperCase(), createRoom: createRoom),
          ),
        );
      }
    }
    if (settings.name == '/profile') {
      return MaterialPageRoute(builder: (_) => const RootAuthGuard(child: ProfileScreen()));
    }
    return MaterialPageRoute(builder: (_) => RootAuthGuard(child: HomeScreen()));
  }
}

class RootAuthGuard extends StatefulWidget {
  final Widget child;
  const RootAuthGuard({super.key, required this.child});

  @override
  State<RootAuthGuard> createState() => _RootAuthGuardState();
}

class _RootAuthGuardState extends State<RootAuthGuard> {
  bool _isDialogOpen = false;
  BuildContext? _dialogContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authService = Provider.of<AuthService>(context);

    if (authService.user != null && _isDialogOpen && _dialogContext != null) {
      if (Navigator.of(_dialogContext!).canPop()) {
        Navigator.of(_dialogContext!).pop();
      }
      _isDialogOpen = false;
      _dialogContext = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.user != null) {
      return widget.child;
    }

    if (!authService.isLoading && !_isDialogOpen) {
      _isDialogOpen = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authService.user != null) {
          _isDialogOpen = false;
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            _dialogContext = dialogContext;
            return LoginDialog(authProvider: authService);
          },
        ).then((_) {
          if (mounted) {
            setState(() {
              _isDialogOpen = false;
              _dialogContext = null;
            });
          }
        });
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: authService.isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF029AFF)))
            : Image.asset('assets/image/logo.png', width: 100),
      ),
    );
  }
}
