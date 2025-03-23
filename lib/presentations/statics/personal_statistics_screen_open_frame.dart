import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../blocs/notes_cubit_open_frame.dart';

class PersonalStatisticsScreenOpenFrame extends StatefulWidget {
  const PersonalStatisticsScreenOpenFrame({super.key});

  @override
  State<PersonalStatisticsScreenOpenFrame> createState() =>
      _PersonalStatisticsScreenState();
}

class _PersonalStatisticsScreenState
    extends State<PersonalStatisticsScreenOpenFrame> {
  int totalNotes = 0;
  Map<String, int> notesByCategory = {};
  Map<String, double> categoryPercentage = {};
  String selectedCategory = ""; // 🔥 Тандалган категория

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final cubit = context.read<NotesCubitOpenFrame>();
    int total = await cubit.getTotalNotesCount();
    Map<String, int> categories = await cubit.getNotesByCategory();
    Map<String, double> percentages = await cubit.getCategoryPercentage();

    setState(() {
      totalNotes = total;
      notesByCategory = categories;
      categoryPercentage = percentages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Personal Statistics"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Projects",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildProjectsProgress(),
            const SizedBox(height: 20),
            _buildProjectSummary(),
            const SizedBox(height: 30),
            const Text(
              "Notes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNotesChart(),
            const SizedBox(height: 20),
            _buildCategorySummary(),
          ],
        ),
      ),
    );
  }

  /// 🔥 **Проекттердин прогресс бары**
  Widget _buildProjectsProgress() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Expanded(flex: 12, child: Container(color: Colors.green)), // Better
          Expanded(flex: 4, child: Container(color: Colors.red)), // Worse
          Expanded(flex: 8, child: Container(color: Colors.grey)), // No Change
        ],
      ),
    );
  }

  /// 🔥 **Проекттердин статистикасы**
  Widget _buildProjectSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCategoryBox("Better", Colors.green, "12"),
        _buildCategoryBox("Worse", Colors.red, "4"),
        _buildCategoryBox("No Change", Colors.grey, "8"),
      ],
    );
  }

  /// 🔥 **Категориялар боюнча статистика (PieChart)**
  Widget _buildNotesChart() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  _buildPieChartSection("Important", Colors.orange, 20),
                  _buildPieChartSection("Urgent", Colors.red, 20),
                  _buildPieChartSection("Think about it", Colors.green, 20),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 50,
              ),
            ),
          ),
          Text(
            "$totalNotes",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 🔥 **Категориялар боюнча пайыздык статистика**
  Widget _buildCategorySummary() {
    return Column(
      children: [
        _buildStatBox("Important", Colors.orange, "Important"),
        const SizedBox(height: 8),
        _buildStatBox("Urgent", Colors.red, "Urgent"),
        const SizedBox(height: 8),
        _buildStatBox("Think about it", Colors.green, "Think about it"),
      ],
    );
  }

  /// 🔥 **Статистика кутучасы (категорияларды тандоо үчүн)**
  Widget _buildStatBox(String title, Color color, String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category; // 🔥 Тандалган категорияны жаңыртабыз
        });
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border:
                selectedCategory == category
                    ? Border.all(
                      color: Colors.black,
                      width: 2,
                    ) // 🔥 Чоңойтуу эффекти
                    : null,
          ),
          child: Text(
            "$title  ${categoryPercentage[category]?.toStringAsFixed(0) ?? 0}%",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBox(String title, Color color, String category) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border:
              selectedCategory == category
                  ? Border.all(
                    color: Colors.black,
                    width: 2,
                  ) // 🔥 Чоңойтуу эффекти
                  : null,
        ),
        child: Text(
          "$title  ${categoryPercentage[category]?.toStringAsFixed(0) ?? 0}%",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  /// 🔥 **PieChart'тагы сегментти чоңойтуу**
  PieChartSectionData _buildPieChartSection(
    String category,
    Color color,
    double baseRadius,
  ) {
    return PieChartSectionData(
      value: categoryPercentage[category] ?? 0,
      color: color,
      radius:
          selectedCategory == category
              ? baseRadius + 5
              : baseRadius, // 🔥 Чоңойтуу
    );
  }
}
