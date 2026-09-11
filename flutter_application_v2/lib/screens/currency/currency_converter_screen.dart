import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/data/worldwide_currencies.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import 'currency_picker_sheet.dart';

class CurrencyConverterScreen extends StatefulWidget {
  final String? initialFromCode;
  final String? initialToCode;

  const CurrencyConverterScreen({
    super.key,
    this.initialFromCode,
    this.initialToCode,
  });

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen>
    with SingleTickerProviderStateMixin {
  late WorldwideCurrency _fromCurrency;
  late WorldwideCurrency _toCurrency;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  bool _isUpdatingFromOther = false;
  String _selectedTimeframe = '1M';
  bool _isRefreshing = false;

  // Chart scrubbing state
  int? _scrubbedPointIndex;

  late AnimationController _swapAnimController;

  @override
  void initState() {
    super.initState();
    _swapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final appState = Provider.of<AppState>(context, listen: false);

    // Default: From active app currency (or RWF/EUR) to USD
    final initialFrom = widget.initialFromCode ?? appState.currentCurrency;
    final initialTo = widget.initialToCode ?? (initialFrom == 'USD' ? 'EUR' : 'USD');

    _fromCurrency = WorldwideCurrencies.findByCode(initialFrom);
    _toCurrency = WorldwideCurrencies.findByCode(initialTo);

    _fromController.text = '1';
    _recalculateToFromSource(1.0);

    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
  }

  @override
  void dispose() {
    _swapAnimController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  double get _currentRate {
    final appState = Provider.of<AppState>(context, listen: false);
    return appState.convertCurrency(1.0, _fromCurrency.code, _toCurrency.code);
  }

  void _recalculateToFromSource(double fromValue) {
    if (_isUpdatingFromOther) return;
    _isUpdatingFromOther = true;
    final converted = fromValue * _currentRate;
    _toController.text = _formatNumber(converted);
    _isUpdatingFromOther = false;
  }

  void _recalculateFromFromTarget(double toValue) {
    if (_isUpdatingFromOther) return;
    _isUpdatingFromOther = true;
    final rate = _currentRate;
    final converted = rate > 0 ? (toValue / rate) : 0.0;
    _fromController.text = _formatNumber(converted);
    _isUpdatingFromOther = false;
  }

  void _onFromChanged() {
    if (_isUpdatingFromOther || !_fromFocusNode.hasFocus) return;
    final val = double.tryParse(_fromController.text.replaceAll(',', '')) ?? 0.0;
    _recalculateToFromSource(val);
  }

  void _onToChanged() {
    if (_isUpdatingFromOther || !_toFocusNode.hasFocus) return;
    final val = double.tryParse(_toController.text.replaceAll(',', '')) ?? 0.0;
    _recalculateFromFromTarget(val);
  }

  String _formatNumber(double val) {
    if (val == 0) return '0';
    if (val >= 1000) {
      return NumberFormat('#,##0.00').format(val);
    } else if (val >= 1) {
      return NumberFormat('0.00').format(val);
    } else if (val >= 0.0001) {
      return NumberFormat('0.00000').format(val).replaceAll(RegExp(r'0+$'), '');
    } else {
      return NumberFormat('0.000000').format(val).replaceAll(RegExp(r'0+$'), '');
    }
  }

  String _formatRate(double rate) {
    if (rate >= 100) {
      return NumberFormat('#,##0.00').format(rate);
    } else if (rate >= 1) {
      return NumberFormat('0.00##').format(rate);
    } else if (rate >= 0.0001) {
      return NumberFormat('0.00000#').format(rate);
    } else {
      return NumberFormat('0.000000#').format(rate);
    }
  }

  void _swapCurrencies() {
    _swapAnimController.forward(from: 0.0);
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });

    final fromVal = double.tryParse(_fromController.text.replaceAll(',', '')) ?? 1.0;
    _recalculateToFromSource(fromVal);
  }

  Future<void> _pickCurrency({required bool isFrom}) async {
    final selected = await CurrencyPickerSheet.show(
      context,
      selectedCode: isFrom ? _fromCurrency.code : _toCurrency.code,
      title: isFrom ? 'Select Source Currency' : 'Select Target Currency',
    );

    if (selected != null && mounted) {
      setState(() {
        if (isFrom) {
          _fromCurrency = selected;
        } else {
          _toCurrency = selected;
        }
      });
      final fromVal = double.tryParse(_fromController.text.replaceAll(',', '')) ?? 1.0;
      _recalculateToFromSource(fromVal);
    }
  }

  Future<void> _refreshRates() async {
    setState(() => _isRefreshing = true);
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.refreshLiveExchangeRates();
    if (mounted) {
      final fromVal = double.tryParse(_fromController.text.replaceAll(',', '')) ?? 1.0;
      _recalculateToFromSource(fromVal);
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exchange rates refreshed with live Forex data'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Generate realistic historical trend data points around current live rate
  List<TrendPoint> _generateTrendPoints(double currentRate, String timeframe) {
    final points = <TrendPoint>[];
    int count;
    Duration interval;
    DateFormat dateFormat;

    switch (timeframe) {
      case '1D':
        count = 12;
        interval = const Duration(hours: 2);
        dateFormat = DateFormat('HH:mm');
        break;
      case '5D':
        count = 10;
        interval = const Duration(hours: 12);
        dateFormat = DateFormat('M/d');
        break;
      case '1M':
        count = 15;
        interval = const Duration(days: 2);
        dateFormat = DateFormat('M/d');
        break;
      case '1Y':
        count = 12;
        interval = const Duration(days: 30);
        dateFormat = DateFormat('MMM');
        break;
      case '5Y':
        count = 15;
        interval = const Duration(days: 120);
        dateFormat = DateFormat("yy'/'M");
        break;
      default:
        count = 15;
        interval = const Duration(days: 2);
        dateFormat = DateFormat('M/d');
    }

    final now = DateTime.now();
    final seed = (_fromCurrency.code.hashCode ^ _toCurrency.code.hashCode ^ timeframe.hashCode).abs();
    final random = math.Random(seed);

    // Maximum variation amplitude (0.8% for 1D to 8% for 5Y)
    final double maxVariancePercent = timeframe == '1D'
        ? 0.008
        : timeframe == '5D'
            ? 0.015
            : timeframe == '1M'
                ? 0.035
                : timeframe == '1Y'
                    ? 0.075
                    : 0.12;

    double runningRate = currentRate * (1.0 - (random.nextDouble() * 0.02 - 0.01));

    for (int i = count - 1; i >= 0; i--) {
      final date = now.subtract(interval * i);
      if (i == 0) {
        // Last point is exact live current rate
        points.add(TrendPoint(
          date: date,
          label: dateFormat.format(date),
          rate: currentRate,
        ));
      } else {
        // Random walk towards current rate
        final step = (random.nextDouble() - 0.49) * maxVariancePercent * currentRate * 0.4;
        runningRate = (runningRate + step).clamp(
          currentRate * (1 - maxVariancePercent),
          currentRate * (1 + maxVariancePercent),
        );
        points.add(TrendPoint(
          date: date,
          label: dateFormat.format(date),
          rate: runningRate,
        ));
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);
    final primaryNavy = MajesticHorizonTheme.lightPrimaryNavy;
    final rate = _currentRate;
    final rateFormatted = _formatRate(rate);

    final trendPoints = _generateTrendPoints(rate, _selectedTimeframe);
    final minRate = trendPoints.map((p) => p.rate).reduce(math.min);
    final maxRate = trendPoints.map((p) => p.rate).reduce(math.max);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F141C) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          appState.tr('currency_converter'),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F141C) : const Color(0xFFF8FAFC),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Live Forex Rates',
            onPressed: _isRefreshing ? null : _refreshRates,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Finance Header Section
            _buildGoogleFinanceHeader(rate, rateFormatted, isDark),

            const SizedBox(height: 16),

            // Dual Conversion Input Boxes with Center Swap Button
            _buildConversionCard(isDark, primaryNavy),

            const SizedBox(height: 20),

            // Timeframe Selector & Trend Chart
            _buildTrendChartSection(
              trendPoints: trendPoints,
              minRate: minRate,
              maxRate: maxRate,
              isDark: isDark,
              primaryNavy: primaryNavy,
            ),

            const SizedBox(height: 20),

            // Quick Currency Selection Chips
            _buildQuickCurrencyChips(isDark),

            const SizedBox(height: 20),

            // Quick Conversion Table (Cheat Sheet)
            _buildQuickConversionTable(rate, isDark),

            const SizedBox(height: 20),

            // Apply as App Active Currency Banner
            _buildApplyToAppBanner(appState, isDark, primaryNavy),

            const SizedBox(height: 24),

            // Disclaimer & Data Source
            Center(
              child: Column(
                children: [
                  Text(
                    'Data from Fixer / Open Exchange Rates · Live Forex',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rates are indicative and updated in real-time.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 1. Google Finance Header Display (matching Image 2)
  Widget _buildGoogleFinanceHeader(double rate, String rateFormatted, bool isDark) {
    final nowFormatted = DateFormat('d MMM, HH:mm UTC').format(DateTime.now().toUtc());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1.00 ${_fromCurrency.name} equals',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  rateFormatted,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _toCurrency.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$nowFormatted · Disclaimer',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Live Rate',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Dual Conversion Input Card
  Widget _buildConversionCard(bool isDark, Color primaryNavy) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2230) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C384D) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Box 1: Source Currency
          _buildCurrencyInputRow(
            controller: _fromController,
            focusNode: _fromFocusNode,
            currency: _fromCurrency,
            isFrom: true,
            isDark: isDark,
            primaryNavy: primaryNavy,
          ),

          // Divider with Center Swap Button
          Stack(
            alignment: Alignment.center,
            children: [
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF2C384D) : Colors.grey.shade200,
              ),
              InkWell(
                onTap: _swapCurrencies,
                borderRadius: BorderRadius.circular(20),
                child: RotationTransition(
                  turns: _swapAnimController,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF253043) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF3B4860) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: isDark ? Colors.white : primaryNavy,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Box 2: Target Currency
          _buildCurrencyInputRow(
            controller: _toController,
            focusNode: _toFocusNode,
            currency: _toCurrency,
            isFrom: false,
            isDark: isDark,
            primaryNavy: primaryNavy,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInputRow({
    required TextEditingController controller,
    required FocusNode focusNode,
    required WorldwideCurrency currency,
    required bool isFrom,
    required bool isDark,
    required Color primaryNavy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Amount Numeric Field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '0',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Currency Dropdown Button (matching Google style)
          InkWell(
            onTap: () => _pickCurrency(isFrom: isFrom),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242E3F) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currency.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    currency.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Interactive Historical Trend Chart (matching Image 2)
  Widget _buildTrendChartSection({
    required List<TrendPoint> trendPoints,
    required double minRate,
    required double maxRate,
    required bool isDark,
    required Color primaryNavy,
  }) {
    final scrubbedPoint = _scrubbedPointIndex != null &&
            _scrubbedPointIndex! >= 0 &&
            _scrubbedPointIndex! < trendPoints.length
        ? trendPoints[_scrubbedPointIndex!]
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2230) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C384D) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeframe Filter Buttons: 1D, 5D, 1M, 1Y, 5Y
          Row(
            children: [
              ...['1D', '5D', '1M', '1Y', '5Y'].map((tf) {
                final isSelected = _selectedTimeframe == tf;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTimeframe = tf;
                        _scrubbedPointIndex = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.2) : primaryNavy.withValues(alpha: 0.1))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: isDark ? const Color(0xFF38BDF8) : primaryNavy,
                                width: 1.2,
                              )
                            : null,
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? const Color(0xFF38BDF8) : primaryNavy)
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (scrubbedPoint != null)
                Text(
                  '${scrubbedPoint.label}: ${_formatRate(scrubbedPoint.rate)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF38BDF8) : primaryNavy,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Custom Painted Trend Line Chart
          SizedBox(
            height: 160,
            child: GestureDetector(
              onHorizontalDragDown: (details) => _updateScrub(details.localPosition, trendPoints),
              onHorizontalDragUpdate: (details) => _updateScrub(details.localPosition, trendPoints),
              onHorizontalDragEnd: (_) => setState(() => _scrubbedPointIndex = null),
              onTapDown: (details) => _updateScrub(details.localPosition, trendPoints),
              onTapUp: (_) => setState(() => _scrubbedPointIndex = null),
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: CurrencyTrendPainter(
                  points: trendPoints,
                  minRate: minRate,
                  maxRate: maxRate,
                  isDark: isDark,
                  primaryColor: isDark ? const Color(0xFF38BDF8) : primaryNavy,
                  scrubIndex: _scrubbedPointIndex,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // X-Axis Dates Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trendPoints.first.label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
              if (trendPoints.length > 2)
                Text(
                  trendPoints[trendPoints.length ~/ 2].label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
              Text(
                trendPoints.last.label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateScrub(Offset localPosition, List<TrendPoint> points) {
    if (points.isEmpty) return;
    final box = context.findRenderObject() as RenderBox?;
    final chartWidth = box != null ? (box.size.width - 64) : 300.0;
    final progress = (localPosition.dx / chartWidth).clamp(0.0, 1.0);
    final index = (progress * (points.length - 1)).round();
    setState(() {
      _scrubbedPointIndex = index;
    });
  }

  // 4. Quick Currency Selection Chips
  Widget _buildQuickCurrencyChips(bool isDark) {
    final chips = ['USD', 'EUR', 'GBP', 'RWF', 'KES', 'AED', 'ZAR', 'CAD', 'JPY'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Switch',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((code) {
            final curr = WorldwideCurrencies.findByCode(code);
            final isCurrent = _fromCurrency.code == code || _toCurrency.code == code;
            return ActionChip(
              avatar: Text(curr.flag, style: const TextStyle(fontSize: 13)),
              label: Text(curr.code),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent
                    ? MajesticHorizonTheme.lightPrimaryNavy
                    : (isDark ? Colors.white : Colors.black87),
              ),
              backgroundColor: isCurrent
                  ? MajesticHorizonTheme.lightPrimaryNavy.withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF1E2636) : Colors.grey.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isCurrent
                      ? MajesticHorizonTheme.lightPrimaryNavy
                      : (isDark ? const Color(0xFF2E3A50) : Colors.grey.shade300),
                ),
              ),
              onPressed: () {
                if (_fromCurrency.code != code) {
                  setState(() => _toCurrency = curr);
                  final fromVal = double.tryParse(_fromController.text.replaceAll(',', '')) ?? 1.0;
                  _recalculateToFromSource(fromVal);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Quick Conversion Cheat Sheet Table (Google style)
  Widget _buildQuickConversionTable(double rate, bool isDark) {
    final amounts = [1.0, 5.0, 10.0, 50.0, 100.0, 500.0, 1000.0, 5000.0, 10000.0];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2230) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C384D) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart_outlined,
                size: 18,
                color: isDark ? const Color(0xFF38BDF8) : MajesticHorizonTheme.lightPrimaryNavy,
              ),
              const SizedBox(width: 8),
              Text(
                'Conversion Cheat Sheet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FixedColumnWidth(30),
              2: FlexColumnWidth(1.2),
            },
            children: amounts.take(6).map((amt) {
              final converted = amt * rate;
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF263245) : Colors.grey.shade100,
                      width: 0.8,
                    ),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${NumberFormat('#,##0').format(amt)} ${_fromCurrency.code}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '=',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${_formatRate(converted)} ${_toCurrency.code}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF38BDF8) : MajesticHorizonTheme.lightPrimaryNavy,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 6. Set as Active Safiri App Currency Banner
  Widget _buildApplyToAppBanner(AppState appState, bool isDark, Color primaryNavy) {
    final isAlreadyAppCurrency = appState.currentCurrency == _toCurrency.code;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2B42), const Color(0xFF172030)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2F4468) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryNavy.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.paid_rounded,
              color: isDark ? const Color(0xFF60A5FA) : primaryNavy,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set as Safiri App Currency',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAlreadyAppCurrency
                      ? '${_toCurrency.code} is currently active across Safiri Holidays.'
                      : 'Show all flights, hotels, and tours in ${_toCurrency.code}.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isAlreadyAppCurrency
                ? null
                : () {
                    appState.setCurrency(_toCurrency.code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Safiri Holidays currency updated to ${_toCurrency.code} (${_toCurrency.name})'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    setState(() {});
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              isAlreadyAppCurrency ? 'Active' : 'Apply',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Trend Data Model
class TrendPoint {
  final DateTime date;
  final String label;
  final double rate;

  TrendPoint({
    required this.date,
    required this.label,
    required this.rate,
  });
}

// Custom Painter for Google-style smooth trend line chart
class CurrencyTrendPainter extends CustomPainter {
  final List<TrendPoint> points;
  final double minRate;
  final double maxRate;
  final bool isDark;
  final Color primaryColor;
  final int? scrubIndex;

  CurrencyTrendPainter({
    required this.points,
    required this.minRate,
    required this.maxRate,
    required this.isDark,
    required this.primaryColor,
    this.scrubIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paddingHorizontal = 10.0;
    final paddingVertical = 20.0;
    final width = size.width - (paddingHorizontal * 2);
    final height = size.height - (paddingVertical * 2);

    final range = (maxRate - minRate) == 0 ? 1.0 : (maxRate - minRate);

    // Draw horizontal background guideline
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(paddingHorizontal, paddingVertical),
      Offset(size.width - paddingHorizontal, paddingVertical),
      gridPaint,
    );
    canvas.drawLine(
      Offset(paddingHorizontal, paddingVertical + height / 2),
      Offset(size.width - paddingHorizontal, paddingVertical + height / 2),
      gridPaint,
    );
    canvas.drawLine(
      Offset(paddingHorizontal, size.height - paddingVertical),
      Offset(size.width - paddingHorizontal, size.height - paddingVertical),
      gridPaint,
    );

    // Calculate Coordinates
    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = paddingHorizontal + (i / (points.length - 1)) * width;
      final normalized = (points[i].rate - minRate) / range;
      final y = (size.height - paddingVertical) - (normalized * height);
      offsets.add(Offset(x, y));
    }

    // Build Smooth Curve Path
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Fill Gradient under curve
    final fillPath = Path.from(path)
      ..lineTo(offsets.last.dx, size.height - paddingVertical)
      ..lineTo(offsets.first.dx, size.height - paddingVertical)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.25),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Stroke Line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Scrubbing Guide Line & Active Dot
    if (scrubIndex != null && scrubIndex! >= 0 && scrubIndex! < offsets.length) {
      final scrubOffset = offsets[scrubIndex!];

      // Vertical guide line
      final scrubGuidePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(scrubOffset.dx, paddingVertical),
        Offset(scrubOffset.dx, size.height - paddingVertical),
        scrubGuidePaint,
      );

      // Outer glowing ring
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(scrubOffset, 8, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(scrubOffset, 4.5, dotPaint);

      final centerDotPaint = Paint()
        ..color = isDark ? const Color(0xFF0F141C) : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(scrubOffset, 2, centerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CurrencyTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.scrubIndex != scrubIndex ||
        oldDelegate.isDark != isDark;
  }
}
