import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    // Les labels pour les mois
                    const titles = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin'];
                    // *** CORRECTION ICI : Utilisez meta.axisSide ***
                    return SideTitleWidget(
                      space: 8.0,
                      axisSide: meta.axisSide, // Correct : fournit la valeur AxisSide non-null
                      child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
                    );
                  },
                  interval: 1, // Afficher tous les labels
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    // *** CORRECTION ICI : Utilisez meta.axisSide ***
                    return SideTitleWidget(
                      space: 8.0, // Espace entre le titre et l'axe
                      axisSide: meta.axisSide, // Correct : fournit la valeur AxisSide non-null
                      child: Text('${value.toInt()}K', style: const TextStyle(fontSize: 10)),
                    );
                  },
                  interval: 500, // Intervalle de 500 pour les valeurs Y
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 1),
            ),
            minX: 0,
            maxX: 5,
            minY: 0,
            maxY: 3000, // Ajustez en fonction de vos données de vente
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 1000), // Janvier
                  FlSpot(1, 1500), // Février
                  FlSpot(2, 1200), // Mars
                  FlSpot(3, 2000), // Avril
                  FlSpot(4, 2500), // Mai
                  FlSpot(5, 1800), // Juin
                ],
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}