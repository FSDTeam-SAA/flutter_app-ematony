String currencySymbolForCode(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return r'$';
    case 'GBP':
      return '\u00A3';
    case 'EUR':
      return '\u20AC';
    case 'NGN':
    default:
      return '\u20A6';
  }
}

String formatCurrencyAmount(double amount, String currencyCode) {
  final symbol = currencySymbolForCode(currencyCode);
  final formatted = amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$symbol$formatted';
}

String stripSupportedCurrencySymbols(String value) {
  return value
      .replaceAll('\u20A6', '')
      .replaceAll(r'$', '')
      .replaceAll('\u00A3', '')
      .replaceAll('\u20AC', '')
      .replaceAll(',', '')
      .trim();
}
