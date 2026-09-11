class WorldwideCurrency {
  final String code;
  final String name;
  final String flag;
  final String symbol;
  final String country;
  final double defaultRateToUsd;

  const WorldwideCurrency({
    required this.code,
    required this.name,
    required this.flag,
    required this.symbol,
    required this.country,
    required this.defaultRateToUsd,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldwideCurrency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class WorldwideCurrencies {
  static const List<WorldwideCurrency> all = [
    // North America
    WorldwideCurrency(code: 'USD', name: 'US Dollar', flag: '🇺🇸', symbol: '\$', country: 'United States', defaultRateToUsd: 1.0),
    WorldwideCurrency(code: 'CAD', name: 'Canadian Dollar', flag: '🇨🇦', symbol: 'CA\$', country: 'Canada', defaultRateToUsd: 1.38),
    WorldwideCurrency(code: 'MXN', name: 'Mexican Peso', flag: '🇲🇽', symbol: 'Mex\$', country: 'Mexico', defaultRateToUsd: 16.93),

    // Europe
    WorldwideCurrency(code: 'EUR', name: 'Euro', flag: '🇪🇺', symbol: '€', country: 'European Union', defaultRateToUsd: 0.86),
    WorldwideCurrency(code: 'GBP', name: 'British Pound', flag: '🇬🇧', symbol: '£', country: 'United Kingdom', defaultRateToUsd: 0.74),
    WorldwideCurrency(code: 'CHF', name: 'Swiss Franc', flag: '🇨🇭', symbol: 'CHF', country: 'Switzerland', defaultRateToUsd: 0.81),
    WorldwideCurrency(code: 'SEK', name: 'Swedish Krona', flag: '🇸🇪', symbol: 'kr', country: 'Sweden', defaultRateToUsd: 9.59),
    WorldwideCurrency(code: 'NOK', name: 'Norwegian Krone', flag: '🇳🇴', symbol: 'kr', country: 'Norway', defaultRateToUsd: 9.24),
    WorldwideCurrency(code: 'DKK', name: 'Danish Krone', flag: '🇩🇰', symbol: 'kr', country: 'Denmark', defaultRateToUsd: 6.43),
    WorldwideCurrency(code: 'PLN', name: 'Polish Zloty', flag: '🇵🇱', symbol: 'zł', country: 'Poland', defaultRateToUsd: 3.71),
    WorldwideCurrency(code: 'CZK', name: 'Czech Koruna', flag: '🇨🇿', symbol: 'Kč', country: 'Czech Republic', defaultRateToUsd: 20.82),
    WorldwideCurrency(code: 'HUF', name: 'Hungarian Forint', flag: '🇭🇺', symbol: 'Ft', country: 'Hungary', defaultRateToUsd: 312.77),
    WorldwideCurrency(code: 'RON', name: 'Romanian Leu', flag: '🇷🇴', symbol: 'lei', country: 'Romania', defaultRateToUsd: 4.52),
    WorldwideCurrency(code: 'BGN', name: 'Bulgarian Lev', flag: '🇧🇬', symbol: 'лв', country: 'Bulgaria', defaultRateToUsd: 1.68),
    WorldwideCurrency(code: 'HRK', name: 'Croatian Kuna', flag: '🇭🇷', symbol: 'kn', country: 'Croatia', defaultRateToUsd: 6.48),
    WorldwideCurrency(code: 'ISK', name: 'Icelandic Króna', flag: '🇮🇸', symbol: 'kr', country: 'Iceland', defaultRateToUsd: 120.82),
    WorldwideCurrency(code: 'RSD', name: 'Serbian Dinar', flag: '🇷🇸', symbol: 'дин', country: 'Serbia', defaultRateToUsd: 100.98),
    WorldwideCurrency(code: 'UAH', name: 'Ukrainian Hryvnia', flag: '🇺🇦', symbol: '₴', country: 'Ukraine', defaultRateToUsd: 44.45),
    WorldwideCurrency(code: 'RUB', name: 'Russian Ruble', flag: '🇷🇺', symbol: '₽', country: 'Russia', defaultRateToUsd: 86.42),
    WorldwideCurrency(code: 'TRY', name: 'Turkish Lira', flag: '🇹🇷', symbol: '₺', country: 'Turkey', defaultRateToUsd: 48.47),

    // Africa
    WorldwideCurrency(code: 'RWF', name: 'Rwandan Franc', flag: '🇷🇼', symbol: 'FRw', country: 'Rwanda', defaultRateToUsd: 1475.32),
    WorldwideCurrency(code: 'KES', name: 'Kenyan Shilling', flag: '🇰🇪', symbol: 'KSh', country: 'Kenya', defaultRateToUsd: 129.44),
    WorldwideCurrency(code: 'TZS', name: 'Tanzanian Shilling', flag: '🇹🇿', symbol: 'TSh', country: 'Tanzania', defaultRateToUsd: 2645.42),
    WorldwideCurrency(code: 'UGX', name: 'Ugandan Shilling', flag: '🇺🇬', symbol: 'USh', country: 'Uganda', defaultRateToUsd: 3744.25),
    WorldwideCurrency(code: 'BIF', name: 'Burundian Franc', flag: '🇧🇮', symbol: 'FBu', country: 'Burundi', defaultRateToUsd: 3005.97),
    WorldwideCurrency(code: 'CDF', name: 'Congolese Franc', flag: '🇨🇩', symbol: 'FC', country: 'DR Congo', defaultRateToUsd: 2301.64),
    WorldwideCurrency(code: 'ETB', name: 'Ethiopian Birr', flag: '🇪🇹', symbol: 'Br', country: 'Ethiopia', defaultRateToUsd: 161.26),
    WorldwideCurrency(code: 'SOS', name: 'Somali Shilling', flag: '🇸🇴', symbol: 'Sh', country: 'Somalia', defaultRateToUsd: 571.05),
    WorldwideCurrency(code: 'DJF', name: 'Djiboutian Franc', flag: '🇩🇯', symbol: 'Fdj', country: 'Djibouti', defaultRateToUsd: 177.72),
    WorldwideCurrency(code: 'ZAR', name: 'South African Rand', flag: '🇿🇦', symbol: 'R', country: 'South Africa', defaultRateToUsd: 16.00),
    WorldwideCurrency(code: 'NGN', name: 'Nigerian Naira', flag: '🇳🇬', symbol: '₦', country: 'Nigeria', defaultRateToUsd: 1322.01),
    WorldwideCurrency(code: 'GHS', name: 'Ghanaian Cedi', flag: '🇬🇭', symbol: 'GH₵', country: 'Ghana', defaultRateToUsd: 11.41),
    WorldwideCurrency(code: 'EGP', name: 'Egyptian Pound', flag: '🇪🇬', symbol: 'E£', country: 'Egypt', defaultRateToUsd: 51.02),
    WorldwideCurrency(code: 'MAD', name: 'Moroccan Dirham', flag: '🇲🇦', symbol: 'MAD', country: 'Morocco', defaultRateToUsd: 9.39),
    WorldwideCurrency(code: 'TND', name: 'Tunisian Dinar', flag: '🇹🇳', symbol: 'DT', country: 'Tunisia', defaultRateToUsd: 2.90),
    WorldwideCurrency(code: 'DZD', name: 'Algerian Dinar', flag: '🇩🇿', symbol: 'DA', country: 'Algeria', defaultRateToUsd: 133.14),
    WorldwideCurrency(code: 'LYD', name: 'Libyan Dinar', flag: '🇱🇾', symbol: 'LD', country: 'Libya', defaultRateToUsd: 6.35),
    WorldwideCurrency(code: 'MUR', name: 'Mauritian Rupee', flag: '🇲🇺', symbol: '₨', country: 'Mauritius', defaultRateToUsd: 46.96),
    WorldwideCurrency(code: 'SCR', name: 'Seychellois Rupee', flag: '🇸🇨', symbol: 'SR', country: 'Seychelles', defaultRateToUsd: 14.05),
    WorldwideCurrency(code: 'MGA', name: 'Malagasy Ariary', flag: '🇲🇬', symbol: 'Ar', country: 'Madagascar', defaultRateToUsd: 4319.38),
    WorldwideCurrency(code: 'ZMW', name: 'Zambian Kwacha', flag: '🇿🇲', symbol: 'ZK', country: 'Zambia', defaultRateToUsd: 19.24),
    WorldwideCurrency(code: 'MWK', name: 'Malawian Kwacha', flag: '🇲🇼', symbol: 'MK', country: 'Malawi', defaultRateToUsd: 1745.98),
    WorldwideCurrency(code: 'MZN', name: 'Mozambican Metical', flag: '🇲🇿', symbol: 'MT', country: 'Mozambique', defaultRateToUsd: 63.79),
    WorldwideCurrency(code: 'BWP', name: 'Botswana Pula', flag: '🇧🇼', symbol: 'P', country: 'Botswana', defaultRateToUsd: 13.78),
    WorldwideCurrency(code: 'NAD', name: 'Namibian Dollar', flag: '🇳🇦', symbol: 'N\$', country: 'Namibia', defaultRateToUsd: 16.00),
    WorldwideCurrency(code: 'SZL', name: 'Swazi Lilangeni', flag: '🇸🇿', symbol: 'E', country: 'Eswatini', defaultRateToUsd: 16.00),
    WorldwideCurrency(code: 'LSL', name: 'Lesotho Loti', flag: '🇱🇸', symbol: 'L', country: 'Lesotho', defaultRateToUsd: 16.00),
    WorldwideCurrency(code: 'AOA', name: 'Angolan Kwanza', flag: '🇦🇴', symbol: 'Kz', country: 'Angola', defaultRateToUsd: 929.20),
    WorldwideCurrency(code: 'GMD', name: 'Gambian Dalasi', flag: '🇬🇲', symbol: 'D', country: 'Gambia', defaultRateToUsd: 74.55),
    WorldwideCurrency(code: 'GNF', name: 'Guinean Franc', flag: '🇬🇳', symbol: 'FG', country: 'Guinea', defaultRateToUsd: 8783.61),
    WorldwideCurrency(code: 'SLE', name: 'Sierra Leonean Leone', flag: '🇸🇱', symbol: 'Le', country: 'Sierra Leone', defaultRateToUsd: 24.71),
    WorldwideCurrency(code: 'LRD', name: 'Liberian Dollar', flag: '🇱🇷', symbol: 'L\$', country: 'Liberia', defaultRateToUsd: 174.94),
    WorldwideCurrency(code: 'CVE', name: 'Cape Verdean Escudo', flag: '🇨🇻', symbol: 'Esc', country: 'Cape Verde', defaultRateToUsd: 94.86),
    WorldwideCurrency(code: 'STN', name: 'São Tomé Dobra', flag: '🇸🇹', symbol: 'Db', country: 'São Tomé & Príncipe', defaultRateToUsd: 21.08),
    WorldwideCurrency(code: 'XAF', name: 'Central African CFA Franc', flag: '🇨🇲', symbol: 'FCFA', country: 'Central Africa (CEMAC)', defaultRateToUsd: 564.29),
    WorldwideCurrency(code: 'XOF', name: 'West African CFA Franc', flag: '🇸🇳', symbol: 'CFA', country: 'West Africa (UEMOA)', defaultRateToUsd: 564.29),

    // Middle East
    WorldwideCurrency(code: 'AED', name: 'UAE Dirham', flag: '🇦🇪', symbol: 'AED', country: 'United Arab Emirates', defaultRateToUsd: 3.67),
    WorldwideCurrency(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦', symbol: 'SAR', country: 'Saudi Arabia', defaultRateToUsd: 3.75),
    WorldwideCurrency(code: 'QAR', name: 'Qatari Riyal', flag: '🇶🇦', symbol: 'QR', country: 'Qatar', defaultRateToUsd: 3.64),
    WorldwideCurrency(code: 'KWD', name: 'Kuwaiti Dinar', flag: '🇰🇼', symbol: 'KD', country: 'Kuwait', defaultRateToUsd: 0.31),
    WorldwideCurrency(code: 'BHD', name: 'Bahraini Dinar', flag: '🇧🇭', symbol: 'BD', country: 'Bahrain', defaultRateToUsd: 0.38),
    WorldwideCurrency(code: 'OMR', name: 'Omani Rial', flag: '🇴🇲', symbol: 'OMR', country: 'Oman', defaultRateToUsd: 0.38),
    WorldwideCurrency(code: 'JOD', name: 'Jordanian Dinar', flag: '🇯🇴', symbol: 'JD', country: 'Jordan', defaultRateToUsd: 0.71),
    WorldwideCurrency(code: 'ILS', name: 'Israeli Shekel', flag: '🇮🇱', symbol: '₪', country: 'Israel', defaultRateToUsd: 3.02),
    WorldwideCurrency(code: 'LBP', name: 'Lebanese Pound', flag: '🇱🇧', symbol: 'L£', country: 'Lebanon', defaultRateToUsd: 89500.0),
    WorldwideCurrency(code: 'IQD', name: 'Iraqi Dinar', flag: '🇮🇶', symbol: 'IQD', country: 'Iraq', defaultRateToUsd: 1310.46),

    // Asia & Pacific
    WorldwideCurrency(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵', symbol: '¥', country: 'Japan', defaultRateToUsd: 153.82),
    WorldwideCurrency(code: 'CNY', name: 'Chinese Yuan', flag: '🇨🇳', symbol: '¥', country: 'China', defaultRateToUsd: 6.73),
    WorldwideCurrency(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳', symbol: '₹', country: 'India', defaultRateToUsd: 94.84),
    WorldwideCurrency(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺', symbol: 'A\$', country: 'Australia', defaultRateToUsd: 1.39),
    WorldwideCurrency(code: 'NZD', name: 'New Zealand Dollar', flag: '🇳🇿', symbol: 'NZ\$', country: 'New Zealand', defaultRateToUsd: 1.71),
    WorldwideCurrency(code: 'SGD', name: 'Singapore Dollar', flag: '🇸🇬', symbol: 'S\$', country: 'Singapore', defaultRateToUsd: 1.26),
    WorldwideCurrency(code: 'HKD', name: 'Hong Kong Dollar', flag: '🇭🇰', symbol: 'HK\$', country: 'Hong Kong', defaultRateToUsd: 7.84),
    WorldwideCurrency(code: 'KRW', name: 'South Korean Won', flag: '🇰🇷', symbol: '₩', country: 'South Korea', defaultRateToUsd: 1340.86),
    WorldwideCurrency(code: 'TWD', name: 'New Taiwan Dollar', flag: '🇹🇼', symbol: 'NT\$', country: 'Taiwan', defaultRateToUsd: 31.50),
    WorldwideCurrency(code: 'THB', name: 'Thai Baht', flag: '🇹🇭', symbol: '฿', country: 'Thailand', defaultRateToUsd: 32.90),
    WorldwideCurrency(code: 'MYR', name: 'Malaysian Ringgit', flag: '🇲🇾', symbol: 'RM', country: 'Malaysia', defaultRateToUsd: 4.06),
    WorldwideCurrency(code: 'IDR', name: 'Indonesian Rupiah', flag: '🇮🇩', symbol: 'Rp', country: 'Indonesia', defaultRateToUsd: 17628.62),
    WorldwideCurrency(code: 'PHP', name: 'Philippine Peso', flag: '🇵🇭', symbol: '₱', country: 'Philippines', defaultRateToUsd: 62.54),
    WorldwideCurrency(code: 'VND', name: 'Vietnamese Dong', flag: '🇻🇳', symbol: '₫', country: 'Vietnam', defaultRateToUsd: 25932.75),
    WorldwideCurrency(code: 'PKR', name: 'Pakistani Rupee', flag: '🇵🇰', symbol: '₨', country: 'Pakistan', defaultRateToUsd: 277.53),
    WorldwideCurrency(code: 'BDT', name: 'Bangladeshi Taka', flag: '🇧🇩', symbol: '৳', country: 'Bangladesh', defaultRateToUsd: 122.86),
    WorldwideCurrency(code: 'LKR', name: 'Sri Lankan Rupee', flag: '🇱🇰', symbol: 'Rs', country: 'Sri Lanka', defaultRateToUsd: 328.31),
    WorldwideCurrency(code: 'NPR', name: 'Nepalese Rupee', flag: '🇳🇵', symbol: '₨', country: 'Nepal', defaultRateToUsd: 151.73),
    WorldwideCurrency(code: 'KZT', name: 'Kazakhstani Tenge', flag: '🇰🇿', symbol: '₸', country: 'Kazakhstan', defaultRateToUsd: 454.23),
    WorldwideCurrency(code: 'UZS', name: 'Uzbekistani Som', flag: '🇺🇿', symbol: 'UZS', country: 'Uzbekistan', defaultRateToUsd: 11802.37),
    WorldwideCurrency(code: 'MOP', name: 'Macanese Pataca', flag: '🇲🇴', symbol: 'MOP\$', country: 'Macau', defaultRateToUsd: 8.08),
    WorldwideCurrency(code: 'BND', name: 'Brunei Dollar', flag: '🇧🇳', symbol: 'B\$', country: 'Brunei', defaultRateToUsd: 1.26),
    WorldwideCurrency(code: 'FJD', name: 'Fijian Dollar', flag: '🇫🇯', symbol: 'FJ\$', country: 'Fiji', defaultRateToUsd: 2.20),

    // South & Central America
    WorldwideCurrency(code: 'BRL', name: 'Brazilian Real', flag: '🇧🇷', symbol: 'R\$', country: 'Brazil', defaultRateToUsd: 5.10),
    WorldwideCurrency(code: 'ARS', name: 'Argentine Peso', flag: '🇦🇷', symbol: '\$', country: 'Argentina', defaultRateToUsd: 1510.10),
    WorldwideCurrency(code: 'CLP', name: 'Chilean Peso', flag: '🇨🇱', symbol: 'CLP\$', country: 'Chile', defaultRateToUsd: 934.21),
    WorldwideCurrency(code: 'COP', name: 'Colombian Peso', flag: '🇨🇴', symbol: 'COL\$', country: 'Colombia', defaultRateToUsd: 3127.34),
    WorldwideCurrency(code: 'PEN', name: 'Peruvian Sol', flag: '🇵🇪', symbol: 'S/', country: 'Peru', defaultRateToUsd: 3.35),
    WorldwideCurrency(code: 'UYU', name: 'Uruguayan Peso', flag: '🇺🇾', symbol: '\$U', country: 'Uruguay', defaultRateToUsd: 40.24),
    WorldwideCurrency(code: 'BOB', name: 'Bolivian Boliviano', flag: '🇧🇴', symbol: 'Bs.', country: 'Bolivia', defaultRateToUsd: 12.43),
    WorldwideCurrency(code: 'PYG', name: 'Paraguayan Guaraní', flag: '🇵🇾', symbol: '₲', country: 'Paraguay', defaultRateToUsd: 5948.42),
    WorldwideCurrency(code: 'CRC', name: 'Costa Rican Colón', flag: '🇨🇷', symbol: '₡', country: 'Costa Rica', defaultRateToUsd: 453.55),
    WorldwideCurrency(code: 'DOP', name: 'Dominican Peso', flag: '🇩🇴', symbol: 'RD\$', country: 'Dominican Republic', defaultRateToUsd: 59.17),
    WorldwideCurrency(code: 'JMD', name: 'Jamaican Dollar', flag: '🇲🇯', symbol: 'J\$', country: 'Jamaica', defaultRateToUsd: 158.34),
  ];

  static const List<String> popularCodes = [
    'USD',
    'EUR',
    'GBP',
    'RWF',
    'KES',
    'TZS',
    'UGX',
    'ZAR',
    'AED',
    'CAD',
    'AUD',
    'JPY',
    'CNY',
    'INR',
    'CHF',
    'SAR',
  ];

  static WorldwideCurrency findByCode(String code, {WorldwideCurrency? fallback}) {
    final upper = code.trim().toUpperCase();
    for (final c in all) {
      if (c.code == upper) return c;
    }
    return fallback ?? all.first; // Defaults to USD
  }

  static List<WorldwideCurrency> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q) ||
          c.symbol.toLowerCase().contains(q);
    }).toList();
  }

  static List<WorldwideCurrency> get popularCurrencies {
    return popularCodes.map((code) => findByCode(code)).toList();
  }
}
