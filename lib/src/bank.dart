import 'dart:math';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
import 'package:bot_boi/src/colors.dart';

// ---Embeds---
EmbedBuilder balanceEmbed(String wallet, String bank, String netWorth) {
  final embed = EmbedBuilder()
    ..color = randColor()
    ..addField(builder: (field) {
      field.name = 'Your Wallet';
      field.content = wallet;
    })
    ..addField(builder: (field) {
      field.name = 'Your Bank Account';
      field.content = bank;
    })
    ..addField(builder: (field) {
      field.name = 'Your Net Worth';
      field.content = netWorth;
    });
  return embed;
}

EmbedBuilder workEmbed(
    DiscordColor color, String fieldName, String fieldContent) {
  final embed = EmbedBuilder()
    ..color = color
    ..addField(builder: (field) {
      field.name = fieldName;
      field.content = fieldContent;
    });
  return embed;
}

// ---Commands---
Function(CommandContext, String) balanceCommand =
    (CommandContext ctx, String message) async {
  await getAccount(ctx).then((stats) async {
    await ctx.sendMessage(
        embed: balanceEmbed(
      "🥔 ${stats['wallet']}",
      "🥔 ${stats['bank']}",
      "🥔 ${stats['bank'] + stats['wallet']}",
    ));
  });
};

Function(CommandContext, String) workCommand =
    (CommandContext ctx, String message) async {
  const positiveMessages = [
    'You sold some fries and got 🥔 {}!',
    'You taught somebody how to cook potatoes and got 🥔 {}!',
    'You successfully peeled some potatoes and got 🥔 {}!',
    'You won a potato eating contest and got 🥔 {}!',
    'You won a bet involving potatoes and got 🥔 {}!',
    'You provided emotional support to a potato and got 🥔 {}!',
  ];
  const negativeMessages = [
    'You burnt some fries and lost 🥔 {}!',
    'You could not teach somebody how to cook potatoes and lost 🥔 {}!',
    'You did not properly peel some potatoes and lost 🥔 {}!',
    'You lost a potato eating contest and lost 🥔 {}!',
  ];
  var allMessages = positiveMessages + negativeMessages;
  var pick = allMessages[Random().nextInt(allMessages.length)];
  final amt = Random().nextInt(150);
  if (positiveMessages.contains(pick)) {
    await getAccount(ctx).then((stats) async {
      await updateAccount(amt, stats);
      await ctx.sendMessage(
          embed: workEmbed(DiscordColor.green, 'Good Job!',
              pick.replaceAll('{}', amt.toString())));
    });
  } else {
    await getAccount(ctx).then((stats) async {
      await updateAccount(-amt, stats);
      await ctx.sendMessage(
          embed: workEmbed(DiscordColor.indianRed, 'Uh Oh!',
              pick.replaceAll('{}', amt.toString())));
    });
  }
};
// ---Helpers---
Future<Map> getAccount(CommandContext ctx) async {
  await ctx.sendMessage(
      content:
          '🤖: Hello, I am Bobby the Bot Bankkeeper! Welcome to Bot Boi Bank! I will handle all your transactions! Give me a second while I look for you in the records!');
  var db = Db('mongodb://localhost:27017/botboidb/');
  await db.open();
  var coll = db.collection('users');
  var matches = await coll
      .find(where
          .eq('userID', int.parse(ctx.author.id.toString()))
          .eq('serverID', int.parse(ctx.guild!.id.toString())))
      .toList();
  if (matches.toString() == '[]') {
    await coll.insert({
      'userID': int.parse(ctx.author.id.toString()),
      'serverID': int.parse(ctx.guild!.id.toString()),
      'wallet': 0,
      'bank': 0
    });
    matches = [
      {
        'userID': int.parse(ctx.author.id.toString()),
        'serverID': int.parse(ctx.guild!.id.toString()),
        'wallet': 0,
        'bank': 0
      }
    ];
    await ctx.sendMessage(
        content:
            "🤖: Hmm... I can't find you on the records. Don't worry! I opened a free bank account for you!");
  } else {
    await ctx.sendMessage(content: '🤖: Found you!');
  }
  await db.close();
  return matches[0];
}

Future<void> updateAccount(int amount, Map account) async {
  var db = Db('mongodb://localhost:27017/botboidb/');
  await db.open();
  var coll = db.collection('users');
  await coll.update(
      where.eq('userID', account['userID']).eq('serverID', account['serverID']),
      {
        r'$set': {'wallet': account['wallet'] + amount}
      });
  print(await coll.find().toList());
  await db.close();
}
