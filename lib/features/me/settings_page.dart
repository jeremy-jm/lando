import 'package:flutter/material.dart';
import 'package:lando/theme/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, _) {
          final mode = ThemeController.instance.mode;
          return ListView(
            children: [
              const ListTile(
                title: Text('主题模式'),
                subtitle: Text('在浅色、深色或跟随系统之间切换'),
              ),
              RadioGroup<ThemeMode>(
                groupValue: mode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    ThemeController.instance.setMode(value);
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('跟随系统'),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('浅色'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('深色'),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
