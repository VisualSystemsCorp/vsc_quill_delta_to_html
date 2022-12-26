/// Equivalent to JS "truthy", i.e. not falsy: https://developer.mozilla.org/en-US/docs/Glossary/Falsy.
/// Not null; or if string, not empty; or if bool, must be true; or if num, non zero and not NaN.
bool isTruthy(dynamic v) =>
    v != null &&
    (v is! String || v.isNotEmpty) &&
    (v is! bool || v) &&
    (v is! num || (v != 0 && v != -0 && !v.isNaN));

num asNumber(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? double.nan;
}
