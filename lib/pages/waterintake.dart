import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Waterintake extends StatefulWidget {
  final List<Map<String, dynamic>> waterData;
  const Waterintake({super.key, required this.waterData});

  @override
  State<Waterintake> createState() => _WaterintakeState();
}

class _WaterintakeState extends State<Waterintake> {
  List<Map<String, dynamic>> _waterList = [];
  final TextEditingController _waterController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('waterData');

    if (storedData != null) {
      setState(() {
        _waterList = List<Map<String, dynamic>>.from(jsonDecode(storedData));
      });
    }
  }

  Future<void> _saveWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('waterData', jsonEncode(_waterList));
  }

  void _addOrUpdateWater() {
    if (_waterController.text.isEmpty || _selectedDate == null) return;

    double water = double.tryParse(_waterController.text) ?? 0;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    int index =
        _waterList.indexWhere((entry) => entry['date'] == formattedDate);

    setState(() {
      if (index != -1) {
        _waterList[index]['water'] = water;
      } else {
        _waterList.add({'date': formattedDate, 'water': water});
      }
    });

    _saveWaterData();
    _waterController.clear();
    _selectedDate = null;

    Navigator.pop(context);
  }

  void _deleteWater(String date) {
    setState(() {
      _waterList.removeWhere((entry) => entry['date'] == date);
    });
    _saveWaterData();
  }

  String _getWaterStatus(double water) {
    if (water < 1.5) return "Bad";
    if (water <= 2) return "Average";
    return "Good";
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddDialog({String? date, double? water}) {
    if (date != null) {
      _selectedDate = DateTime.parse(date);
      _waterController.text = water.toString();
    } else {
      _selectedDate = null;
      _waterController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(date == null ? "Add Water Intake" : "Edit Water Intake"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? "Select Date"
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Water (Liters)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addOrUpdateWater,
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Water Intake Tracker")),
      body: _waterList.isEmpty
          ? const Center(child: Text("No water intake recorded."))
          : ListView.builder(
              itemCount: _waterList.length,
              itemBuilder: (context, index) {
                var entry = _waterList[index];
                return Card(
                  child: ListTile(
                    title: Text("Date: ${entry['date']}"),
                    subtitle: Text(
                        "Water: ${entry['water']}L - ${_getWaterStatus(entry['water'])}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddDialog(
                            date: entry['date'],
                            water: entry['water'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWater(entry['date']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
