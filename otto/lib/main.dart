import 'package:flutter/material.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(const NavigationBarApp());

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.dark()),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.white,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.signal_wifi_4_bar_sharp),
            label: 'Conexión',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.audiotrack,
            ),
            label: 'Otto',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.info,
            ),
            label: 'Ayuda',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        Center(child: Text('CONEXIONES', style: theme.textTheme.headlineLarge)),

        /// Notifications page
        Center(child: Text('CANCIONES', style: theme.textTheme.headlineLarge)),

        /// Messages page
        Center(child: Text('AYUDA', style: theme.textTheme.headlineLarge)),
      ][currentPageIndex],
    );
  }
}
