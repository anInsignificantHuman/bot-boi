import 'dart:math';
import 'package:nyxx/nyxx.dart';

var colors = [
  DiscordColor.aquamarine,
  DiscordColor.azure,
  DiscordColor.black,
  DiscordColor.blue,
  DiscordColor.blurple,
  DiscordColor.brown,
  DiscordColor.chartreuse,
  DiscordColor.cornflowerBlue,
  DiscordColor.cyan,
  DiscordColor.darkBlue,
  DiscordColor.darkButNotBlack,
  DiscordColor.darkGray,
  DiscordColor.darkGreen,
  DiscordColor.darkRed,
  DiscordColor.dartBlue,
  DiscordColor.dartSecondary,
  DiscordColor.flutterBlue,
  DiscordColor.gold,
  DiscordColor.goldenrod,
  DiscordColor.gray,
  DiscordColor.grayple,
  DiscordColor.green,
  DiscordColor.hotPink,
  DiscordColor.indianRed,
  DiscordColor.lightGray,
  DiscordColor.lilac,
  DiscordColor.magenta,
  DiscordColor.midnightBlue,
  DiscordColor.notQuiteBlack,
  DiscordColor.orange,
  DiscordColor.phthaloBlue,
  DiscordColor.phthaloGreen,
  DiscordColor.purple,
  DiscordColor.red,
  DiscordColor.rose,
  DiscordColor.sapGreen,
  DiscordColor.sienna,
  DiscordColor.springGreen,
  DiscordColor.teal,
  DiscordColor.turquoise,
  DiscordColor.veryDarkGray,
  DiscordColor.violet,
  DiscordColor.wheat,
  DiscordColor.white,
  DiscordColor.yellow
];

DiscordColor randColor() {
  return colors[Random().nextInt(colors.length)];
}
