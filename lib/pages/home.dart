import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stepsData;
  final List<Map<String, dynamic>> waterData;
  final double barWidth = 8;

  const ChartScreen(
      {super.key, required this.stepsData, required this.waterData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step & Water Chart")),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Center(
          child: stepsData.isEmpty && waterData.isEmpty
              ? const Text("No data yet")
              : BarChart(
                  BarChartData(
                    maxY: 10000, // Adjust maxY if needed
                    barGroups: _generateBarGroups(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() < stepsData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  stepsData[value.toInt()]['date'].substring(5),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text("${value.toInt()}");
                          },
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    Map<String, Map<String, dynamic>> mergedData = {};

    // Merge Steps Data
    for (var entry in stepsData) {
      mergedData[entry['date']] = {'steps': entry['steps'], 'water': 0};
    }

    // Merge Water Data
    for (var entry in waterData) {
      if (mergedData.containsKey(entry['date'])) {
        mergedData[entry['date']]!['water'] = entry['water'];
      } else {
        mergedData[entry['date']] = {'steps': 0, 'water': entry['water']};
      }
    }

    List<String> dates = mergedData.keys.toList();
    dates.sort();

    return dates.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;
      double steps = (mergedData[date]!['steps'] as num).toDouble();
      double water = (mergedData[date]!['water'] as num).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: steps,
            color: Colors.blue,
            width: barWidth,
          ),
          BarChartRodData(
            toY: water * 5000,
            color: Colors.green,
            width: barWidth,
          ),
        ],
      );
    }).toList();
  }
}
