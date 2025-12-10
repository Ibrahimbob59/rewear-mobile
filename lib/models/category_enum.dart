enum Category {
  tops('tops', 'Tops'),
  bottoms('bottoms', 'Bottoms'),
  dresses('dresses', 'Dresses'),
  outerwear('outerwear', 'Outerwear'),
  shoes('shoes', 'Shoes'),
  accessories('accessories', 'Accessories'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const Category(this.value, this.displayName);

  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Category.other,
    );
  }

  static List<Category> get all => Category.values;
}