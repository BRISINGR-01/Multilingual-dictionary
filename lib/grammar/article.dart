import 'package:flutter/material.dart';

class Article extends StatelessWidget {
  final Map<String, dynamic> body;
  const Article({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    // if (body["body"] is! List) return const NoGrammar();

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(body["title"]),
            ),
            body: ListView.separated(
                padding: const EdgeInsets.only(bottom: 64),
                itemCount: body["body"].length,
                separatorBuilder: ((context, index) =>
                    body["body"][index]["type"] == "h"
                        ? const Divider(indent: 24)
                        : Container()),
                itemBuilder: ((context, index) {
                  switch (body["body"][index]["type"]) {
                    case "h":
                      return ListTile(
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 24, 0, 0),
                          child: Text(
                            body["body"][index]["text"],
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 25,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    case "p":
                    case "b":
                      return ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            body["body"][index]["text"],
                          ),
                        ),
                      );
                    case "table":
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        child: Table(
                            border: TableBorder.all(
                                borderRadius: BorderRadius.circular(20)),
                            children: getTableRow(
                                body["body"][index]["table"] as List,
                                body["body"][index]["hasHeader"] ?? false,
                                context)),
                      );
                    default:
                      return Container();
                  }
                }))));
  }
}

List<TableRow> getTableRow(List rows, bool hasHeader, context) {
  List<TableRow> tableRows = [];
  for (var i = 0; i < rows.length; i++) {
    bool isHeader = i == 0 && hasHeader;
    tableRows.add(TableRow(
        decoration: BoxDecoration(
            color: isHeader ? Theme.of(context).colorScheme.tertiary : null,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        children: rows[i]
            .map<Widget>((cell) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    cell,
                    style:
                        isHeader ? const TextStyle(color: Colors.white) : null,
                  ),
                ))
            .toList()));
  }
  return tableRows.toList();
}
