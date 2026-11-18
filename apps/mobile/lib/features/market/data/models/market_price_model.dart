class MarketPriceModel {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String arrivalDate;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;

  MarketPriceModel({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.arrivalDate,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    return MarketPriceModel(
      state: json['state']?.toString().trim() ?? '',
      district: json['district']?.toString().trim() ?? '',
      market: json['market']?.toString().trim() ?? '',
      commodity: json['commodity']?.toString().trim() ?? '',
      variety: json['variety']?.toString().trim() ?? '',
      arrivalDate: (json['arrival_date'] ?? json['arrivalDate'] ?? 'Today')?.toString().trim() ?? 'Today',
      minPrice: parseNum(json['min_price'] ?? json['minPrice']).toDouble(),
      maxPrice: parseNum(json['max_price'] ?? json['maxPrice']).toDouble(),
      modalPrice: parseNum(json['modal_price'] ?? json['modalPrice']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'district': district,
      'market': market,
      'commodity': commodity,
      'variety': variety,
      'arrivalDate': arrivalDate,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'modalPrice': modalPrice,
    };
  }
}
