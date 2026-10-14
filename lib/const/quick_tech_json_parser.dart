int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ??
        double.tryParse(value)?.toInt();
  }
  return null;
}

String? parseString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
double? parseDouble(dynamic value) {
  if (value == null) return null;

  if (value is double) return value;

  if (value is int) return value.toDouble();

  if (value is String) {
    return double.tryParse(value) ?? int.tryParse(value)?.toDouble();
  }

  return null;
}

bool? parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final v = value.toLowerCase().trim();
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
    return null;
  }
  return null;
}