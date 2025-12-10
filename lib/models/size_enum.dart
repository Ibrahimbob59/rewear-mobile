enum Size {
  xs('XS', 'Extra Small'),
  s('S', 'Small'),
  m('M', 'Medium'),
  l('L', 'Large'),
  xl('XL', 'Extra Large'),
  xxl('XXL', '2X Large'),
  xxxl('XXXL', '3X Large'),
  oneSize('One Size', 'One Size');

  final String value;
  final String displayName;

  const Size(this.value, this.displayName);

  static Size fromString(String value) {
    return Size.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Size.m,
    );
  }

  static List<Size> get all => Size.values;
}