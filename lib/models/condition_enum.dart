enum Condition {
  brandNew('new', 'Brand New', 'Never worn, with original tags'),
  likeNew('like_new', 'Like New', 'Worn once or twice, excellent condition'),
  good('good', 'Good', 'Gently used, minor wear'),
  fair('fair', 'Fair', 'Visible wear, but functional');

  final String value;
  final String displayName;
  final String description;

  const Condition(this.value, this.displayName, this.description);

  static Condition fromString(String value) {
    return Condition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Condition.good,
    );
  }

  static List<Condition> get all => Condition.values;
}