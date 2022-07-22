import 'package:biux/config/styles.dart';
import 'package:biux/config/themes/theme.dart';
import 'package:biux/config/themes/theme_notifier.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _darkTheme = true;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuracion"),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: Text(
              "  Ajustes Generales",
              style: Styles.fontWeightText,
            ),
            height: 25,
          ),
          Divider(),
          Container(
            margin: EdgeInsets.all(10),
            child: Text(
              "   Temas",
              style: Styles.fontSize,
            ),
            height: 25,
          ),
          ListTile(
            title: Text(
              _darkTheme == true ? '  Tema Dia' : " Tema Noche",
            ),
            contentPadding: const EdgeInsets.only(left: 16.0),
            trailing: Transform.scale(
              scale: 0.4,
              child: DayNightSwitcher(
                isDarkModeEnabled: _darkTheme,
                onStateChanged: (isDarkModeEnabled) {
                  setState(
                    () {
                      this._darkTheme = isDarkModeEnabled;
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }
}
