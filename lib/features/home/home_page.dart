import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // Bottom navigation bar example
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return BottomNavigationBar(
            backgroundColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.unselectedItemColor,
            selectedLabelStyle: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedLabelStyle,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: l10n.translation,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: l10n.settings,
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  AppNavigator.pushNamed(context, AppRoutes.home);
                  break;
                case 1:
                  AppNavigator.pushNamed(context, AppRoutes.settings);
                  break;
                case 2:
                  AppNavigator.pushNamed(context, AppRoutes.profile);
                  break;
                case 3:
                  AppNavigator.pushNamed(context, AppRoutes.about);
                  break;
              }
            },
          );
        },
      ),
    );
  }
}
