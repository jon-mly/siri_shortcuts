import 'package:flutter/material.dart';
import 'package:siri_shortcuts/siri_shortcuts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _siriShortcutsPlugin = SiriShortcuts();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Siri Shortcuts'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final result = await _siriShortcutsPlugin.createShortcut(
                ShortcutOptions(
                  activityType: 'a',
                  title: 'Hello',
                  suggestedInvocationPhrase: 'Nepal',
                  userInfo: {
                    'hi': 'there',
                  },
                ),
              );

              print(result.status);
              print(result.phrase);
            },
            child: const Text('Create Shortcut'),
          ),
        ),
      ),
    );
  }
}
