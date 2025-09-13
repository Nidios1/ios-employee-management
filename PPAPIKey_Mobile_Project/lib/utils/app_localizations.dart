import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Login screen
  String get app_title => translate('app_title');
  String get welcome_back => translate('welcome_back');
  String get login_to_continue => translate('login_to_continue');
  String get email_username => translate('email_username');
  String get password => translate('password');
  String get remember_login => translate('remember_login');
  String get forgot_password => translate('forgot_password');
  String get login => translate('login');
  String get no_account => translate('no_account');
  String get register_now => translate('register_now');
  String get enter_email_username => translate('enter_email_username');
  String get enter_password => translate('enter_password');
  String get show_password => translate('show_password');
  String get hide_password => translate('hide_password');
  String get theme_toggle => translate('theme_toggle');
  String get login_success => translate('login_success');
  String get login_failed => translate('login_failed');
  String get connection_error => translate('connection_error');
  String get account_not_activated => translate('account_not_activated');

  // Dashboard
  String get dashboard => translate('dashboard');
  String get key_manager => translate('key_manager');
  String get package_manager => translate('package_manager');
  String get admin_tools => translate('admin_tools');
  String get more_options => translate('more_options');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get refresh_data => translate('refresh_data');
  String get logout => translate('logout');
  String get balance => translate('balance');
  String get total_keys => translate('total_keys');
  String get detailed_statistics => translate('detailed_statistics');
  String get keys_created => translate('keys_created');
  String get limit => translate('limit');
  String get package => translate('package');
  String get keys_activated => translate('keys_activated');
  String get keys_pending => translate('keys_pending');
  String get quick_actions => translate('quick_actions');
  String get manage_keys => translate('manage_keys');
  String get packages => translate('packages');
  String get api_shortlink => translate('api_shortlink');
  String get activated => translate('activated');
  String get view_all => translate('view_all');
  String get hello => translate('hello');

  // Profile
  String get normal_member => translate('normal_member');
  String get vip_member => translate('vip_member');
  String get administrator => translate('administrator');
  String get change_name => translate('change_name');
  String get change_password => translate('change_password');
  String get vip_status => translate('vip_status');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get vip_type => translate('vip_type');
  String get vip_expiry => translate('vip_expiry');
  String get extend_vip => translate('extend_vip');
  String get upgrade_account => translate('upgrade_account');

  // Common
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get loading => translate('loading');
  String get updating => translate('updating');
  String get deleting => translate('deleting');
  String get error_occurred => translate('error_occurred');
  String get try_again => translate('try_again');
  String get refresh => translate('refresh');
  String get close => translate('close');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
