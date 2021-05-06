import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

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
