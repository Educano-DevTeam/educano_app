import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;

  final int itemsPerPage;

  const AppDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.itemsPerPage = 50,
  });

  @override
  State<AppDataTable> createState() => _AppDataTableState();
}

class _AppDataTableState extends State<AppDataTable> {
  int currentPage = 0;
  String filter = "";

  List<Map<String, dynamic>> get filteredData {
    if (filter.isEmpty) {
      return widget.data;
    }

    return widget.data.where((item) {
      return widget.columns.any(
        (column) => item[column]
            .toString()
            .toLowerCase()
            .contains(filter.toLowerCase()),
      );
    }).toList();
  }

  List<Map<String, dynamic>> get pageData {
    final start = currentPage * widget.itemsPerPage;

    if (start >= filteredData.length) {
      return [];
    }

    final end = (start + widget.itemsPerPage)
        .clamp(0, filteredData.length);

    return filteredData.sublist(start, end);
  }

  int get pageCount {
    if (filteredData.isEmpty) return 1;

    return (filteredData.length / widget.itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: "Pesquisar...",
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) {
            setState(() {
              filter = value;
              currentPage = 0;
            });
          },
        ),

        const SizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              EducanoColors.searchBackground,
            ),
            columns: widget.columns
                .map(
                  (column) => DataColumn(
                    label: Text(column),
                  ),
                )
                .toList(),

            rows: pageData.map(
              (item) {
                return DataRow(
                  cells: widget.columns
                      .map(
                        (column) => DataCell(
                          Text(
                            item[column]?.toString() ?? "-",
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ).toList(),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),

            Text(
              "${currentPage + 1} / $pageCount",
            ),

            IconButton(
              onPressed: currentPage < pageCount - 1
                  ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}