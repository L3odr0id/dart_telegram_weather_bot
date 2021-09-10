import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

Future<void> telegramBot() async {
  var telegram = Telegram(_getToken());
  var me = await telegram.getMe();

  final teledart = TeleDart(telegram, Event(me.username!));

  final respond = Responds();

  teledart
    ..start()
    ..onMessage().listen(respond.sendStartMessage);
}

String _getToken() {
  final file = io.File('./assets/token.txt');
  return file.readAsStringSync();
}

class Responds {
  late String _apiKey;

  Responds() {
    _apiKey = _getKey();
  }

  String _getKey() {
    final file = io.File('./assets/apikey.txt');
    return file.readAsStringSync();
  }

  Future<String> _getWeather(String? cityName) async {
    if (cityName == null) {
      return 'Вы отправили пустое сообщение';
    } else {
      try {
        var response = await Dio().get(
            'http://api.openweathermap.org/data/2.5/weather?q=' +
                cityName +
                '&lang=ru&appid=' +
                _apiKey);
        if (response.statusCode == 200) {
          Map<String, dynamic> data = response.data;
          var name = data['name'] + '\n\n';
          var state = 'Состояние: ${data['weather'][0]['description']}\n';
          var temp = 'Температура: ${(data['main']['temp'] - 273).toInt()}°C\n';
          var wind = 'Ветер: ${data['wind']['speed']} м/с';
          return name + state + temp + wind;
        } else {
          return 'Не удалось найти город с названием $cityName';
        }
      } catch (e) {
        return 'Некорректный ввод данных';
      }
    }
  }

  Future<Message> sendStartMessage(TeleDartMessage message) async {
    return message.reply(await _getWeather(message.text));
  }
}
