import 'package:ampify/config/theme_services.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

extension MyContext on BuildContext {
  ThemeServiceState get scheme => ThemeServices.of(this);
  Color get background => ThemeServices.of(this).background;
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;
  Orientation get orientation => MediaQuery.orientationOf(this);
}

extension MyList on List<String> {
  String get asString => _removeBraces(this);

  String _removeBraces(List<String> list) {
    return list.toString().replaceAll(RegExp(r'[\[\]]'), '');
  }
}

extension ArtistNames on List<Artist> {
  String get asString => _toString(this);

  _toString(List<Artist> artists) {
    final list = List<String>.from(artists.map((e) => e.name));
    return list.asString;
  }
}

extension MusicDuration on Duration {
  String format() => _format(this);

  String _format(Duration time) {
    if (time.inMinutes >= 60) {
      final min = time.inMinutes - (time.inHours * 60);
      return '${time.inHours}:${_formatInt(min)}';
    }
    if (time.inSeconds >= 60) {
      final sec = time.inSeconds - (time.inMinutes * 60);
      return '${time.inMinutes}:${_formatInt(sec)}';
    }
    return '0:${_formatInt(time.inSeconds)}';
  }

  String _formatInt(int num) {
    if (num < 10) return '0$num';
    return num.toString();
  }
}

extension MyDateTime on DateTime {
  String toJson() => _dateTime(this);
  String get formatTime => _formatedTime(this);
  String get formatDate => _formatedDate(this);

  String _dateTime(DateTime now) {
    String date = '${now.year}${_format(now.month)}${_format(now.day)}';
    String time = '${_format(now.hour)}${_format(now.minute)}'
        '${_format(now.second)}${_formatMili(now.millisecond)}';
    return date + time;
  }

  String _formatMili(int number) {
    String int = number.toString();
    switch (int.length) {
      case 2:
        return '0$int';
      case 1:
        return '00$int';
      default:
        return int;
    }
  }

  String _formatedTime(DateTime time) {
    String hour = _format(time.hour);
    String min = _format(time.minute);

    return '$hour:$min';
  }

  String _formatedDate(DateTime time) {
    String month = _format(time.month);
    String day = _format(time.day);

    return '$month:$day';
  }

  String _format(int number) {
    String int = number.toString();
    String result = int.length > 1 ? int : '0$int';
    return result;
  }
}

extension MyString on String {
  DateTime get toDateTime => _formJson(this);
  bool get isEmail => _emailRegExp(this);
  bool get isStringPass => _passRegExp(this);
  String get capitalize => _capitilize(this);
  String get unescape => _unescape(this);

  DateTime _formJson(String datetime) {
    int year = int.parse(datetime.substring(0, 4));
    int month = int.parse(datetime.substring(4, 6));
    int day = int.parse(datetime.substring(6, 8));
    int hour = int.parse(datetime.substring(8, 10));
    int min = int.parse(datetime.substring(10, 12));
    int sec = int.parse(datetime.substring(12, 14));
    int milli = int.parse(datetime.substring(14, 17));
    return DateTime(year, month, day, hour, min, sec, milli);
  }

  _emailRegExp(String text) {
    final emailExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailExp.hasMatch(text);
  }

  _passRegExp(String text) {
    final passExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
    return passExp.hasMatch(text);
  }

  String _capitilize(String text) {
    final RegExp regExp = RegExp(r'[a-zA-Z]');
    return text.replaceFirstMapped(regExp, (match) {
      return match.group(0)!.toUpperCase();
    });
  }

  String _unescape(String text) => HtmlUnescape().convert(text);
}

extension MyInt on int {
  String get format => _format(this);

  String _format(int count) {
    if (count > 999999) {
      String newCount = (count / 1000000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}M';
    }
    if (count > 999) {
      String newCount = (count / 1000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}K';
    }
    return count.toString();
  }
}
