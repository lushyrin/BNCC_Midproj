import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Steptracker extends StatefulWidget {
  final List<Map<String, dynamic>> stepsData;
  const Steptracker({super.key, required this.stepsData});

  @override
  State<Steptracker> createState() => _SteptrackerState();
}

class _SteptrackerState extends State<Steptracker> {
  List<Map<String, dynamic>> _stepsList = [];
  final TextEditingController _stepsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _stepsList = List.from(widget.stepsData);
    _loadStepsData();
  }

  Future<void> _loadStepsData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('stepsData');

    if (storedData != null) {
      setState(() {
        _stepsList = List<Map<String, dynamic>>.from(json.decode(storedData));
      });
    }
  }

  Future<void> _saveStepsData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stepsData', jsonEncode(_stepsList));
    setState(() {
      widget.stepsData.clear();
      widget.stepsData.addAll(_stepsList); // Sync with parent widget
    });
  }

  void _addOrUpdateSteps() {
    if (_stepsController.text.isEmpty || _selectedDate == null) return;

    int steps = int.tryParse(_stepsController.text) ?? 0;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    int index =
        _stepsList.indexWhere((entry) => entry['date'] == formattedDate);

    setState(() {
      if (index != -1) {
        _stepsList[index]['steps'] = steps; // Update jika sudah ada
      } else {
        _stepsList.add({'date': formattedDate, 'steps': steps}); // Tambah baru
      }
    });

    _saveStepsData();

    _stepsController.clear();
    _selectedDate = null;
    Navigator.pop(context);
  }

  void _deleteSteps(String date) {
    setState(() {
      _stepsList.removeWhere((entry) => entry['date'] == date);
    });
    _saveStepsData();
  }

  String _getStepStatus(int steps) {
    if (steps < 4000) return "Bad";
    if (steps <= 8000) return "Average";
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

  void _showAddDialog({String? date, int? steps}) {
    if (date != null) {
      _selectedDate = DateTime.parse(date);
      _stepsController.text = steps.toString();
    } else {
      _selectedDate = null;
      _stepsController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(date == null ? "Add Steps" : "Edit Steps"),
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
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter Steps"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addOrUpdateSteps,
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
      appBar: AppBar(title: const Text("Steps Tracker")),
      body: _stepsList.isEmpty
          ? const Center(child: Text("No steps recorded."))
          : ListView.builder(
              itemCount: _stepsList.length,
              itemBuilder: (context, index) {
                var entry = _stepsList[index];
                return Card(
                  child: ListTile(
                    title: Text("Date: ${entry['date']}"),
                    subtitle: Text(
                        "Steps: ${entry['steps']} - ${_getStepStatus(entry['steps'])}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddDialog(
                            date: entry['date'],
                            steps: entry['steps'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSteps(entry['date']),
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
