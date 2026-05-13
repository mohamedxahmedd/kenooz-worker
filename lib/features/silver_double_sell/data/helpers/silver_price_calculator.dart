class SilverDoubleSellPriceCalculator {
  /// Inside product price (no USD conversion for silver).
  static double insidePrice({
    required double mc,
    required double gramPrice,
    required double profit,
    required double grams,
  }) {
    return (mc + gramPrice + profit) * grams;
  }

  /// Box product price.
  static double boxPrice({
    required double grams,
    required double loss,
    required double gramPrice,
    required double mc,
    required double profit,
  }) {
    return ((grams - loss) * gramPrice) + (grams * mc) + profit;
  }

  /// Outside product price.
  static double outsidePrice({
    required double grams,
    required double gramPrice,
    required double mc,
    required double profit,
  }) {
    return (mc + gramPrice + profit) * grams;
  }

  /// Buy (trade-in) price.
  static double buyPrice({
    required double grams,
    required double loss,
    required double gramPrice,
  }) {
    return (grams - loss) * gramPrice;
  }

  /// Final totals.
  static ({
    double sellTotal,
    double buyTotal,
    double net,
    double taxAmount,
    double finalTotal,
  }) calculateTotals({
    required List<double> sellPrices,
    required List<double> buyPrices,
    required double taxPercent,
  }) {
    final sellTotal = sellPrices.fold(0.0, (a, b) => a + b);
    final buyTotal = buyPrices.fold(0.0, (a, b) => a + b);
    final net = sellTotal - buyTotal;
    final taxAmount = net * (taxPercent / 100);
    final finalTotal = net + taxAmount;

    return (
      sellTotal: sellTotal,
      buyTotal: buyTotal,
      net: net,
      taxAmount: taxAmount,
      finalTotal: finalTotal,
    );
  }
}
