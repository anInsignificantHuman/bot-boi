import 'package:mongo_dart/mongo_dart.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
import 'package:bot_boi/resources/colors.dart';

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

// ---Commands---
Function(CommandContext, String) checkBal =
    (CommandContext ctx, String message) async {
  await checkAccount(ctx).then((stats) async {
    await ctx.sendMessage(
        embed: balanceEmbed(
      "🥔 ${stats['wallet']}",
      "🥔 ${stats['bank']}",
      "🥔 ${stats['bank'] + stats['wallet']}",
    ));
  });
};

// ---Helpers---
Future<Map> checkAccount(CommandContext ctx) async {
  await ctx.sendMessage(
      content:
          '🤖: Hello, I am Bobby the Bot Bankkeeper! Welcome to Bot Boi Bank! Give me a second while I look for you in the records!');
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
