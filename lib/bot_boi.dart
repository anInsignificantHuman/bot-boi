import 'dart:io';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
import 'package:bot_boi/covid_info.dart';

// Getting Token From TXT
String getToken() {
  final token = File('lib/token.txt').readAsStringSync();
  return token;
}

void startBot() {
  // Bot With Token and All Unprivileged Intents
  final bot = Nyxx(getToken(), GatewayIntents.allUnprivileged);

  // Embeds
  final helpEmbed = EmbedBuilder()
    ..addField(builder: (field) {
      field.name = 'BotBoi Commands!';
      field.content = 'Here are some helpful commands and their descriptions!';
    })
    ..addField(builder: (field) {
      field.name = './help';
      field.content =
          'This command! Use it whenever you need a refresher on the available commands';
    });
  final covidTotalEmbed = EmbedBuilder()
    ..addField(builder: (field) {
      field.name = 'Global Coronavirus Statistics';
      field.content =
          'Here are the current coronavirus statistics from the World Health Organization (WHO).';
    })
    ..addField(builder: (field) {
      totals().then((stats) {
        field.name = '${stats[0]} Cases and ${stats[1]} Deaths';
      });
      field.content =
          'Check `./help` to see how else you can use this command!';
    });
  // Commands
  final helpCommand = (CommandContext ctx, String message) async {
    await ctx.sendMessage(embed: helpEmbed);
  };
  final covidCommand = (CommandContext ctx, String message) async {
    final args = ctx.getArguments().toList();
    if (args.isEmpty) {
      await ctx.sendMessage(content: 'Retrieving Data... Please Wait');
      await ctx.sendMessage(embed: covidTotalEmbed);
    }
  };

  Commander(bot, prefix: './')
    ..registerCommand('help', helpCommand)
    ..registerCommand('covid', covidCommand);
}
