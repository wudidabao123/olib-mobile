import 'package:flutter/material.dart';

import 'translations/en.dart' as t_en;
import 'translations/zh.dart' as t_zh;
import 'translations/zh_tw.dart' as t_zh_tw;
import 'translations/fr.dart' as t_fr;
import 'translations/es.dart' as t_es;
import 'translations/de.dart' as t_de;
import 'translations/pt.dart' as t_pt;
import 'translations/ru.dart' as t_ru;
import 'translations/ja.dart' as t_ja;
import 'translations/ko.dart' as t_ko;
import 'translations/it.dart' as t_it;
import 'translations/tr.dart' as t_tr;
import 'translations/vi.dart' as t_vi;
import 'translations/th.dart' as t_th;
import 'translations/id.dart' as t_id;
import 'translations/ar.dart' as t_ar;

/// App translations for all supported languages
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': t_en.en,
    'zh': t_zh.zh,
    'zh_TW': t_zh_tw.zhTW,
    'fr': t_fr.fr,
    'es': t_es.es,
    'de': t_de.de,
    'pt': t_pt.pt,
    'ru': t_ru.ru,
    'ja': t_ja.ja,
    'ko': t_ko.ko,
    'it': t_it.it,
    'tr': t_tr.tr,
    'vi': t_vi.vi,
    'th': t_th.th,
    'id': t_id.id,
    'ar': t_ar.ar,
  };

  String get(String key) {
    String langCode = locale.languageCode;
    if (locale.scriptCode == 'Hant' || locale.countryCode == 'TW' || locale.countryCode == 'HK') {
      langCode = 'zh_TW';
    }
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  // Convenience getters
  String get appName => get('app_name');
  String get cancel => get('cancel');
  String get save => get('save');
  String get close => get('close');
  String get login => get('login');
  String get logout => get('logout');
  String get settings => get('settings');
  String get downloads => get('downloads');
  String get favorites => get('favorites');
  String get search => get('search');
  String get home => get('home');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'fr', 'es', 'de', 'pt', 'ru', 'ja', 'ko', 'ar', 'it', 'tr', 'vi', 'th', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Supported locales
const supportedLocales = [
  Locale('en'),
  Locale('zh'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('pt'),
  Locale('ru'),
  Locale('ja'),
  Locale('ko'),
  Locale('ar'),
  Locale('it'),
  Locale('tr'),
  Locale('vi'),
  Locale('th'),
  Locale('id'),
];

/// Language display names (legacy, use allLanguages in settings_screen.dart)
const localeDisplayNames = {
  'en': 'English',
  'zh': '简体中文',
  'zh_TW': '繁體中文',
  'fr': 'Français',
  'es': 'Español',
  'de': 'Deutsch',
  'pt': 'Português',
  'ru': 'Русский',
  'ja': '日本語',
  'ko': '한국어',
  'ar': 'العربية',
  'it': 'Italiano',
  'tr': 'Türkçe',
  'vi': 'Tiếng Việt',
  'th': 'ไทย',
  'id': 'Bahasa Indonesia',
};

/// Get locale key for storage
String getLocaleKey(Locale locale) {
  if (locale.languageCode == 'zh') {
    if (locale.scriptCode == 'Hant' || locale.countryCode == 'TW' || locale.countryCode == 'HK') {
      return 'zh_TW';
    }
    return 'zh';
  }
  return locale.languageCode;
}

/// Parse locale from key
Locale parseLocaleKey(String key) {
  if (key == 'zh_TW') {
    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
  }
  return Locale(key);
}
