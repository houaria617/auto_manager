// manages app locale/language selection

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  // defaults to english on startup
  LocaleCubit() : super(const Locale('en'));

  // switches app language
  void changeLanguage(String languageCode) {
    emit(Locale(languageCode));
  }
}
