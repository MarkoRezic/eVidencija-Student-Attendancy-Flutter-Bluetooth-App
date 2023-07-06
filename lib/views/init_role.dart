import 'package:e_videncija/globals/settings.dart';
import 'package:e_videncija/providers/user_provider.dart';
import 'package:e_videncija/utils/capitalize_first_letter.dart';
import 'package:e_videncija/views/home.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/enums/role_enum.dart';

class InitRole extends StatefulWidget {
  const InitRole({super.key, required this.role});

  final Role role;

  @override
  State<InitRole> createState() => _InitRoleState();
}

class _InitRoleState extends State<InitRole> {
  final GlobalKey _formKey = GlobalKey();
  late Settings settings;
  late Map<String, TextEditingController?> settingControllers;
  late Map<String, FocusNode?> settingFocusNodes;
  late Map<String, dynamic> updatedSettings;
  late Map<String, String?> settingErrors;
  late Map<String, bool> displayErrors;
  bool settingsLoading = true;

  @override
  void initState() {
    super.initState();

    Settings.getInstance().then((instance) {
      settings = instance;

      settings.setSetting(Setting.role, widget.role.name);
      debugPrint(settings.getSetting(Setting.firstname));
      updatedSettings = settings.toJSON();
      updatedSettings[Setting.initialized] = true;
      settingErrors = Map.fromEntries((widget.role == Role.professor
              ? Settings.professorLabels
              : Settings.studentLabels)
          .entries
          .map<MapEntry<String, String?>>((setting) {
        String? error;
        if (Settings.rules[setting.key]!.contains('required') &&
            updatedSettings[setting.key]!.length == 0) {
          error = 'Polje ne može biti prazno';
        }
        return MapEntry(setting.key, error);
      }));
      displayErrors = Map.fromEntries((widget.role == Role.professor
              ? Settings.professorLabels
              : Settings.studentLabels)
          .entries
          .map<MapEntry<String, bool>>((setting) {
        return MapEntry(setting.key, false);
      }));

      settingControllers = Map.fromEntries((widget.role == Role.professor
              ? Settings.professorLabels
              : Settings.studentLabels)
          .entries
          .map<MapEntry<String, TextEditingController?>>((setting) {
        TextEditingController? controller;
        if (Settings.types[setting.key] == SettingTypes.text ||
            Settings.types[setting.key] == SettingTypes.number) {
          controller = TextEditingController();
          controller.text = settings.getSetting(setting.key).toString();
        }
        return MapEntry(setting.key, controller);
      }));
      settingFocusNodes = Map.fromEntries((widget.role == Role.professor
              ? Settings.professorLabels
              : Settings.studentLabels)
          .entries
          .map<MapEntry<String, FocusNode?>>((setting) {
        FocusNode? focusNode;
        if (Settings.types[setting.key] == SettingTypes.text ||
            Settings.types[setting.key] == SettingTypes.number) {
          focusNode = FocusNode();
        }
        return MapEntry(setting.key, focusNode);
      }));
      setState(() {
        if (settings.getSetting(Setting.initialized)) {
          _navigateToHome();
        } else {
          settingsLoading = false;
          debugPrint(updatedSettings.toString());
          debugPrint(settingErrors.toString());
        }
      });
    });
  }

  String? _getSettingError(MapEntry<String, dynamic> setting) {
    String? error;
    if (Settings.rules[setting.key]!.contains('required') &&
        setting.value.length == 0) {
      error = 'Polje ne može biti prazno';
    }
    return error;
  }

  _navigateToHome() {
    context.read<UserProvider>().setUserFromSettings(settings: updatedSettings);
    settings.updateSettings(updatedSettings).then((value) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => Home(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/images/${widget.role.name}_icon_white.png',
                width: 150,
              ),
              SizedBox(height: 20),
              ...(settingsLoading
                  ? [CircularProgressIndicator()]
                  : [
                      Text(
                        'Unesite podatke',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      SizedBox(height: 50),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: (widget.role == Role.professor
                                  ? Settings.professorLabels
                                  : Settings.studentLabels)
                              .entries
                              .map<Widget>((setting) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Settings.types[setting.key] ==
                                            SettingTypes.text
                                        ? EnsureVisibleWhenFocused(
                                            focusNode:
                                                settingFocusNodes[setting.key]!,
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                errorText: displayErrors[
                                                            setting.key] ==
                                                        true
                                                    ? settingErrors[setting.key]
                                                    : null,
                                                labelText: setting.value
                                                    .toCapitalized(),
                                                hintText:
                                                    "Unesite ${setting.value}",
                                              ),
                                              focusNode: settingFocusNodes[
                                                  setting.key]!,
                                              controller: settingControllers[
                                                  setting.key]!,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (displayErrors[
                                                          setting.key] ==
                                                      false) {
                                                    displayErrors[setting.key] =
                                                        true;
                                                  }
                                                  updatedSettings[setting.key] =
                                                      value;
                                                  settingErrors[setting.key] =
                                                      _getSettingError(MapEntry(
                                                          setting.key, value));
                                                });
                                              },
                                              onTapOutside: (event) =>
                                                  settingFocusNodes[
                                                          setting.key]!
                                                      .unfocus(),
                                            ),
                                          )
                                        : Settings.types[setting.key] ==
                                                SettingTypes.select
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border:
                                                        Border.fromBorderSide(
                                                      BorderSide(
                                                        width: 1,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    )),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: ButtonTheme(
                                                    alignedDropdown: true,
                                                    child: DropdownButton(
                                                      isExpanded: true,
                                                      value: updatedSettings[
                                                          setting.key],
                                                      items: Settings
                                                          .selectValues[
                                                              setting.key]!
                                                          .map((val) =>
                                                              DropdownMenuItem(
                                                                value: val,
                                                                child: Text(
                                                                  val,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ))
                                                          .toList(),
                                                      onChanged: (selected) {
                                                        setState(() {
                                                          updatedSettings[
                                                                  setting.key] =
                                                              selected!;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Settings.types[setting.key] ==
                                                    SettingTypes.boolean
                                                ? Switch(
                                                    value: updatedSettings[
                                                        setting.key],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        updatedSettings[setting
                                                            .key] = value;
                                                      });
                                                    })
                                                : Settings.types[setting.key] ==
                                                        SettingTypes.number
                                                    ? EnsureVisibleWhenFocused(
                                                        focusNode:
                                                            settingFocusNodes[
                                                                setting.key]!,
                                                        child: TextFormField(
                                                          decoration:
                                                              InputDecoration(
                                                            errorText:
                                                                settingErrors[
                                                                    setting
                                                                        .key],
                                                            labelText: setting
                                                                .value
                                                                .toCapitalized(),
                                                            hintText:
                                                                "Unesite ${setting.value}",
                                                          ),
                                                          focusNode:
                                                              settingFocusNodes[
                                                                  setting.key]!,
                                                          controller:
                                                              settingControllers[
                                                                  setting.key]!,
                                                          onTapOutside: (event) =>
                                                              settingFocusNodes[
                                                                      setting
                                                                          .key]!
                                                                  .unfocus(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              updatedSettings[
                                                                      setting
                                                                          .key] =
                                                                  int.parse(
                                                                      value);
                                                              settingErrors[
                                                                      setting
                                                                          .key] =
                                                                  _getSettingError(
                                                                      MapEntry(
                                                                          setting
                                                                              .key,
                                                                          value));
                                                            });
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    r'^(0|[1-9][0-9]*)$')),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 40),
                      TextButton(
                        onPressed:
                            settingErrors.values.any((value) => value != null)
                                ? null
                                : _navigateToHome,
                        child: const Text(
                          'Spremi',
                        ),
                      ),
                    ]),
            ],
          ),
        ),
      ),
    );
  }
}
