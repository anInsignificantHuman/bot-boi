import 'dart:io';
import 'package:bot_boi/bank.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
import 'package:bot_boi/help.dart';
import 'package:bot_boi/covid.dart';

// Getting Token From TXT
String getToken() {
  final token = File('lib/token.txt').readAsStringSync();
  return token;
}

void startBot() {
  // Bot With Token and All Unprivileged Intents
  final bot = Nyxx(getToken(), GatewayIntents.allUnprivileged);

  // Implements Commands
  Commander(bot, prefix: './')
    ..registerCommand('help', helpCommand)
    ..registerCommand('h', helpCommand)
    ..registerCommand('commands', helpCommand)
    ..registerCommand('cmd', helpCommand)
    ..registerCommand('covid', covidCommand)
    ..registerCommand('coronavirus', covidCommand)
    ..registerCommand('covid19', covidCommand)
    ..registerCommand('balance', checkBal)
    ..registerCommand('bal', checkBal)
    ..registerCommand('bank', checkBal);
}
