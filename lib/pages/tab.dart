import 'package:flutter/material.dart';
import 'package:midproj/pages/home.dart';
import 'package:midproj/pages/steptracker.dart';
import 'package:midproj/pages/waterintake.dart';

class TabBottom extends StatefulWidget {
  const TabBottom({super.key});

  @override
  State<TabBottom> createState() => _TabBottomState();
}

class _TabBottomState extends State<TabBottom>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _stepsList = [];
  List<Map<String, dynamic>> _waterData = [];

  List<Widget> tabs = [
    Tab(text: "Home Tab"),
    Tab(text: "Add shit"),
    Tab(text: "udk"),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          ChartScreen(stepsData: _stepsList, waterData: _waterData),
          Steptracker(stepsData: _stepsList),
          Waterintake(waterData: _waterData),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.nordic_walking), text: "Steps"),
            Tab(icon: Icon(Icons.water_drop), text: "Water Intake"),
          ],
        ),
      ),
    );
  }
}
