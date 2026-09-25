import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

abstract final class AppPalette {
  static const red = Color(0xFFE57373);
  static const orange = Color(0xFFFFB74D);
  static const green = Color(0xFFAED581);
  static const yellow = Color(0xFFFFF176);
  static const blue = Color(0xFF64B5F6);
  static const mint = Color(0xFF8FDCBE);
  static const purple = Color(0xFF9575CD);

  static const accentColors = <Color>[
    red,
    orange,
    green,
    yellow,
    blue,
    mint,
    purple,
  ];
  static const accentNames = <String>[
    'Rot',
    'Orange',
    'Grün',
    'Gelb',
    'Blau',
    'Mint',
    'Lila',
  ];
}

class AppUiSettings {
  const AppUiSettings({
    required this.fontFamily,
    required this.textScaleFactor,
    required this.useLightTheme,
    required this.accentColorValue,
    required this.highlightColorValue,
  });

  static const availableFonts = <String>[
    'OpenDyslexic',
    'NotoSans',
    'CourierPrime',
    'Ubuntu',
    'Ubuntu Mono',
  ];

  static const defaults = AppUiSettings(
    fontFamily: 'Ubuntu',
    textScaleFactor: 1,
    useLightTheme: false,
    accentColorValue: 0xFFE57373,
    highlightColorValue: 0xFFFFB74D,
  );

  final String fontFamily;
  final double textScaleFactor;
  final bool useLightTheme;
  final int accentColorValue;
  final int highlightColorValue;

  AppUiSettings copyWith({
    String? fontFamily,
    double? textScaleFactor,
    bool? useLightTheme,
    int? accentColorValue,
    int? highlightColorValue,
  }) {
    return AppUiSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      useLightTheme: useLightTheme ?? this.useLightTheme,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      highlightColorValue: highlightColorValue ?? this.highlightColorValue,
    );
  }
}

class UiSettingsController extends ChangeNotifier {
  UiSettingsController(this._database);
  UiSettingsController.memory() : _database = null;

  static final StoreRef<String, Map<String, dynamic>> _store =
      StoreRef<String, Map<String, dynamic>>('ui_settings');
  static const _recordKey = 'app';

  final Database? _database;
  AppUiSettings settings = AppUiSettings.defaults;

  Future<void> load() async {
    final database = _database;
    if (database == null) {
      settings = AppUiSettings.defaults;
      notifyListeners();
      return;
    }

    final data = await _store.record(_recordKey).get(database);
    settings = _fromJson(data ?? const {});
    notifyListeners();
  }

  Future<void> update(AppUiSettings value) async {
    settings = value;
    notifyListeners();
    final database = _database;
    if (database == null) return;
    await _store.record(_recordKey).put(database, _toJson(value));
  }

  AppUiSettings _fromJson(Map<String, dynamic> data) {
    return AppUiSettings(
      fontFamily: AppUiSettings.availableFonts.contains(data['fontFamily'])
          ? data['fontFamily'] as String
          : AppUiSettings.defaults.fontFamily,
      textScaleFactor: ((data['textScaleFactor'] as num?)?.toDouble() ?? 1)
          .clamp(0.5, 1.6),
      useLightTheme: data['useLightTheme'] as bool? ?? false,
      accentColorValue: _validColor(
        (data['accentColorValue'] as num?)?.toInt(),
        AppUiSettings.defaults.accentColorValue,
      ),
      highlightColorValue: _validColor(
        (data['highlightColorValue'] as num?)?.toInt(),
        AppUiSettings.defaults.highlightColorValue,
      ),
    );
  }

  Map<String, dynamic> _toJson(AppUiSettings value) => {
    'fontFamily': value.fontFamily,
    'textScaleFactor': value.textScaleFactor,
    'useLightTheme': value.useLightTheme,
    'accentColorValue': value.accentColorValue,
    'highlightColorValue': value.highlightColorValue,
  };

  int _validColor(int? value, int fallback) {
    if (value == null) return fallback;
    return AppPalette.accentColors.any((color) => color.toARGB32() == value)
        ? value
        : fallback;
  }
}

ThemeData buildUnifiedTheme(AppUiSettings settings, Brightness brightness) {
  final accent = Color(settings.accentColorValue);
  final highlight = Color(settings.highlightColorValue);
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: brightness,
  ).copyWith(primary: accent, secondary: highlight);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: settings.fontFamily,
    iconTheme: IconThemeData(color: highlight),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: highlight),
      actionsIconTheme: IconThemeData(color: highlight),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: highlight),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: highlight),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: highlight,
        side: BorderSide(color: highlight),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: highlight,
        foregroundColor: Colors.black,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: highlight,
      foregroundColor: Colors.black,
    ),
    sliderTheme: SliderThemeData(
      thumbColor: highlight,
      activeTrackColor: highlight,
      inactiveTrackColor: highlight.withAlpha(90),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? highlight : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? highlight.withAlpha(120)
            : null,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highlight, width: 2),
      ),
      floatingLabelStyle: TextStyle(color: highlight),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: highlight,
      selectionColor: highlight.withAlpha(75),
      selectionHandleColor: highlight,
    ),
  );
}

class UiSettingsPage extends StatefulWidget {
  const UiSettingsPage({super.key, required this.initial});

  final AppUiSettings initial;

  @override
  State<UiSettingsPage> createState() => _UiSettingsPageState();
}

class _UiSettingsPageState extends State<UiSettingsPage> {
  late String _fontFamily = widget.initial.fontFamily;
  late double _textScaleFactor = widget.initial.textScaleFactor;
  late bool _useLightTheme = widget.initial.useLightTheme;
  late int _accentColorValue = widget.initial.accentColorValue;
  late int _highlightColorValue = widget.initial.highlightColorValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                AppUiSettings(
                  fontFamily: _fontFamily,
                  textScaleFactor: _textScaleFactor,
                  useLightTheme: _useLightTheme,
                  accentColorValue: _accentColorValue,
                  highlightColorValue: _highlightColorValue,
                ),
              );
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _fontFamily,
            decoration: const InputDecoration(labelText: 'Schriftart'),
            items: AppUiSettings.availableFonts
                .map((font) => DropdownMenuItem(value: font, child: Text(font)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _fontFamily = value);
            },
          ),
          const SizedBox(height: 16),
          Text('Schriftgröße: ${(_textScaleFactor * 100).round()} %'),
          Slider(
            value: _textScaleFactor,
            min: 0.5,
            max: 1.6,
            divisions: 22,
            label: '${(_textScaleFactor * 100).round()} %',
            onChanged: (value) => setState(() => _textScaleFactor = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_useLightTheme ? 'Helles Design' : 'Dunkles Design'),
            value: _useLightTheme,
            onChanged: (value) => setState(() => _useLightTheme = value),
          ),
          const SizedBox(height: 12),
          _ColorDropdown(
            title: 'Akzentfarbe',
            value: _accentColorValue,
            onChanged: (value) => setState(() => _accentColorValue = value),
          ),
          const SizedBox(height: 12),
          _ColorDropdown(
            title: 'Highlight-Farbe',
            value: _highlightColorValue,
            onChanged: (value) => setState(() => _highlightColorValue = value),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Vorschau: Diese Einstellungen gelten fuer Schrift, Designfarben und Bedienelemente.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDropdown extends StatelessWidget {
  const _ColorDropdown({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: title),
      items: [
        for (var index = 0; index < AppPalette.accentColors.length; index++)
          DropdownMenuItem(
            value: AppPalette.accentColors[index].toARGB32(),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppPalette.accentColors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(AppPalette.accentNames[index]),
              ],
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
