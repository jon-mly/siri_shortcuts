import 'dart:async';

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

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _siriShortcutsPlugin.listenForShortcuts.listen(_onShortcutEvent);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onShortcutEvent(ShortcutDetail detail) {
    print(detail.activityType);
    print(detail.userInfo);
  }

  Future<void> createExampleShortcut() async {
    final result = await _siriShortcutsPlugin.createShortcut(
      ShortcutOptions(
          activityType: 'testShortcut',
          title: 'Raccourci test',
          description:
              "Déclenche une action de test qui écrira dans la console que l'action a été reçue",
          suggestedInvocationPhrase: 'Déclenche mon nouveau raccourci',
          eligibility: ShortcutEligibility(
            search: false,
            prediction: false,
            handOff: false,
            publicIndexing: false,
          ),
          userInfo: {
            'hi': 'there',
          },
          keywords: [
            "test",
            "dev"
          ]),
    );

    print(result.status);
    print(result.phrase);
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
            onPressed: createExampleShortcut,
            child: const Text('Create / Edit Shortcut'),
          ),
        ),
      ),
    );
  }
}
