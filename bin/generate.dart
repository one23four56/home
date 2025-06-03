import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final markdown = await File(
    path.join(Directory.current.path, "assets", "home.md"),
  ).readAsString();

  String output = await File(
    path.join(Directory.current.path, "assets", "home.html"),
  ).readAsString();

  final outDir = Directory(path.join(Directory.current.path, "out"));
  await outDir.create();
  
  final out = File(path.join(outDir.path, "index.html"));

  final body = md.markdownToHtml(markdown);
  output = output.replaceFirst("<!--body-->", body);

  final parsed = parse(output);
  for (final link in parsed.querySelectorAll("link[rel=stylesheet]")) {
    final source = link.attributes["href"];
    if (source == null) continue;

    try {
      final file = File(
        path.join(Directory.current.path, "assets", path.normalize(source)),
      );

      final contents = await file.readAsString();
      final style = Element.tag("style");
      style.innerHtml = contents;

      link.replaceWith(style);

      print("Imported stylesheet `${link.attributes["href"]}`");
    } catch (e) {
      print("Failed to read stylesheet `${link.attributes["href"]}`");
      continue;
    }
  }

  output = parsed.outerHtml;

  await out.writeAsString(output);

  print("HTML generation complete.");

  return;
}
