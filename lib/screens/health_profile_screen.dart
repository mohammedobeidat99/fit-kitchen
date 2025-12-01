import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/health_profile.dart';

class HealthProfileScreen extends StatefulWidget {
  final AppLang lang;
  final HealthProfile profile;

  const HealthProfileScreen({
    super.key,
    required this.lang,
    required this.profile,
  });

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  late bool _hasDiabetes;
  late bool _hasHighBloodPressure;
  late bool _isVegetarian;
  final TextEditingController _allergyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hasDiabetes = widget.profile.hasDiabetes;
    _hasHighBloodPressure = widget.profile.hasHighBloodPressure;
    _isVegetarian = widget.profile.isVegetarian;
  }

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        widget.profile.allergies.add(text);
      });
      _allergyController.clear();
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      widget.profile.allergies.removeAt(index);
    });
  }

  void _saveProfile() {
    final updated = HealthProfile(
      hasDiabetes: _hasDiabetes,
      hasHighBloodPressure: _hasHighBloodPressure,
      isVegetarian: _isVegetarian,
      allergies: widget.profile.allergies,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.healthTitle),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(strings.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSwitchCard(
              strings.diabetes,
              _hasDiabetes,
              (v) => setState(() => _hasDiabetes = v),
            ),
            _buildSwitchCard(
              strings.pressure,
              _hasHighBloodPressure,
              (v) => setState(() => _hasHighBloodPressure = v),
            ),
            _buildSwitchCard(
              strings.vegetarian,
              _isVegetarian,
              (v) => setState(() => _isVegetarian = v),
            ),
            const SizedBox(height: 16),
            Text(strings.allergies,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _allergyController,
                    decoration:
                        InputDecoration(labelText: strings.addAllergyHint),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addAllergy,
                  child: Text(strings.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(widget.profile.allergies.length, (index) {
              final allergy = widget.profile.allergies[index];
              return Card(
                child: ListTile(
                  title: Text(allergy),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeAllergy(index),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
