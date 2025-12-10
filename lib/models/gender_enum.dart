enum Gender {
  male('male', 'Male'),
  female('female', 'Female'),
  unisex('unisex', 'Unisex');

  final String value;
  final String displayName;

  const Gender(this.value, this.displayName);

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Gender.unisex,
    );
  }

  static List<Gender> get all => Gender.values;
}