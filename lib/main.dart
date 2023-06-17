import 'package:e_videncija/globals/main_theme.dart';
import 'package:e_videncija/providers/user_provider.dart';
import 'package:e_videncija/utils/preload_image.dart';
import 'package:e_videncija/views/init.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadImage(const AssetImage('assets/images/e_videncija_icon.png'));
  await loadImage(const AssetImage('assets/images/e_videncija_icon_white.png'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'eVidencija',
        theme: EvidencijaTheme().theme,
        home: const Init(),
      ),
    );
  }
}
