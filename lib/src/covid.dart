import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
import 'package:bot_boi/src/colors.dart';

// ---Embeds---
EmbedBuilder covidTotalEmbed(String fieldName) {
  final embed = EmbedBuilder()
    ..color = randColor()
    ..addField(builder: (field) {
      field.name = 'Global Coronavirus Statistics';
      field.content =
          'Here are the current coronavirus statistics from the [World Health Organization (WHO)](https://www.who.int/)';
    })
    ..addField(builder: (field) {
      field.name = fieldName;
      field.content =
          'Check `./help` to see how else you can use this command!';
    });
  return embed;
}

EmbedBuilder covidListEmbed = EmbedBuilder()
  ..color = randColor()
  ..addField(builder: (field) {
    field.name =
        'Below is the list of valid countries, ordered by number of cases, that can be inputted into this command.';
    field.content = 'Check `./help` to see how else you can use this command!';
  });

EmbedBuilder covidCountryEmbed(String fieldName) {
  final embed = EmbedBuilder()
    ..color = randColor()
    ..addField(builder: (field) {
      field.name = 'COVID Stats For Requested Country';
      field.content =
          'Here are the current coronavirus statistics for this country according to [Worldometers](https://www.worldometers.info/)';
    })
    ..addField(builder: (field) {
      field.name = fieldName;
      field.content =
          'Check `./help` to see how else you can use this command!';
    });
  return embed;
}

EmbedBuilder covidErrorEmbed = EmbedBuilder()
  ..color = DiscordColor.darkRed
  ..addField(builder: (field) {
    field.name = 'Oops!';
    field.content =
        "Couldn't Find That Country! Check `./help` to see how to use this command or check `./covid list` to see a list of countries that can be inputted.";
  });

// ---Commands---
Function(CommandContext, String) covidCommand =
    (CommandContext ctx, String message) async {
  final args = ctx.getArguments().toList();
  print(args);
  if (args.isEmpty) {
    await ctx.sendMessage(content: 'Retrieving Data... Please Wait');
    await totals().then((stats) async {
      await ctx.sendMessage(
          embed: covidTotalEmbed('${stats[0]} Cases and ${stats[1]} Deaths'));
    });
  } else if (args.length == 1 && args[0] == 'list') {
    await ctx.sendMessage(embed: covidListEmbed);
    await ctx.sendMessage(content: 'Retrieving Data... Please Wait');
    await getCountries().then((table) async {
      var keys = table.keys.toList();
      var topThird = keys.sublist(0, keys.length ~/ 3).join('\n');
      var middleThird =
          keys.sublist(keys.length ~/ 3, 2 * (keys.length ~/ 3)).join('\n');
      var bottomThird = keys.sublist(2 * (keys.length ~/ 3)).join('\n');
      var topEmbed = EmbedBuilder();
      var middleEmbed = EmbedBuilder();
      var bottomEmbed = EmbedBuilder();
      topEmbed.color = DiscordColor.red;
      middleEmbed.color = DiscordColor.yellow;
      bottomEmbed.color = DiscordColor.springGreen;
      await ctx.sendMessage(
          embed: topEmbed..addField(name: 'Top 1/3', content: topThird));
      await ctx.sendMessage(
          embed: middleEmbed
            ..addField(name: 'Middle 1/3', content: middleThird));
      await ctx.sendMessage(
          embed: bottomEmbed
            ..addField(name: 'Bottom 1/3', content: bottomThird));
    });
  } else if (args.length == 1) {
    await ctx.sendMessage(content: 'Retrieving Data... Please Wait');
    await getCountries().then((stats) async {
      if (stats[args[0].toLowerCase()] != null) {
        await ctx.sendMessage(
            embed: covidCountryEmbed(
                '${stats[args[0].toLowerCase()][0]} Cases and ${stats[args[0].toLowerCase()][1]} Deaths'));
      } else {
        await ctx.sendMessage(embed: covidErrorEmbed);
      }
    });
  } else {
    var country = args.join(' ');
    await ctx.sendMessage(content: 'Retrieving Data... Please Wait');
    await getCountries().then((stats) async {
      if (stats[country.toLowerCase()] != null) {
        await ctx.sendMessage(
            embed: covidCountryEmbed(
                '${stats[country.toLowerCase()][0]} Cases and ${stats[country.toLowerCase()][1]} Deaths'));
      } else {
        await ctx.sendMessage(embed: covidErrorEmbed);
      }
    });
  }
};

// ---Helpers---
Future<List> totals() async {
  var client = http.Client();
  var response = await client.get(Uri.parse('https://covid19.who.int/'));
  var document = html.parse(response.body);
  var text = document.querySelector('p')?.text;
  text = text.toString();
  var matches = RegExp(r'[\d,]+').allMatches(text);
  var finalMatches = [];
  for (var element in matches) {
    finalMatches.add(element.group(0));
  }
  finalMatches = finalMatches.sublist(6);
  final totals = [finalMatches[0], finalMatches[2]];
  return totals;
}

Future<Map> getCountries() async {
  String intOf(number) {
    try {
      final formatter = NumberFormat.decimalPattern();
      return formatter.format(int.parse(number));
    } catch (e) {
      return 'N/A';
    }
  }

  var client = http.Client();
  var response =
      await client.get(Uri.parse('https://www.worldometers.info/coronavirus/'));
  var document = html.parse(response.body);
  List links = document.querySelectorAll('a[href^="country/"]');
  var rows = [for (var link in links) link.parent.parent];
  var children = [for (var row in rows) row.children];
  var elements = [
    for (var ls in children)
      [
        for (var el in ls)
          if (el.text != '\n') el.text
      ]
  ];
  elements = [
    for (var element in elements)
      [
        element[1].trim(),
        intOf(element[2].trim().replaceAll(',', '')),
        intOf(element[4].trim().replaceAll(',', ''))
      ]
  ];
  elements.sort((a, b) => int.parse(a[1].replaceAll(',', ''))
      .compareTo(int.parse(b[1].replaceAll(',', ''))));
  elements = List.from(elements.reversed);
  var table = {};
  for (var element in elements) {
    if (!table.containsKey(element[0])) {
      table[element[0]
          .toString()
          .toLowerCase()
          .replaceAll('-', ' ')
          .replaceAll('.', '')] = element.sublist(1);
    } else {
      table[element[0]
              .toString()
              .toLowerCase()
              .replaceAll('-', ' ')
              .replaceAll('.', '')]
          .addAll(element.sublist(1));
    }
  }
  return table;
}
