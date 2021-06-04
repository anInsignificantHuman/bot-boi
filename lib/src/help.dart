import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';

// ---Embeds---
EmbedBuilder helpEmbed = EmbedBuilder()
  ..color = DiscordColor.aquamarine
  ..addField(builder: (field) {
    field.name = 'BotBoi Commands!';
    field.content = 'Here are some helpful commands and their descriptions!';
  })
  ..addField(builder: (field) {
    field.name = './help';
    field.content =
        'This command! Use it whenever you need a refresher on the available commands\nAliases: `./h`, `./commands`, `./cmd`';
  });

// ---Commands---
Function(CommandContext, String) helpCommand =
    (CommandContext ctx, String message) async {
  await ctx.sendMessage(embed: helpEmbed);
};
