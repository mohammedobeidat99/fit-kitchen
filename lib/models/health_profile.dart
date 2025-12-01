class HealthProfile {
  bool hasDiabetes;
  bool hasHighBloodPressure;
  bool isVegetarian;
  List<String> allergies;

  HealthProfile({
    this.hasDiabetes = false,
    this.hasHighBloodPressure = false,
    this.isVegetarian = false,
    List<String>? allergies,
  }) : allergies = allergies ?? [];
}
