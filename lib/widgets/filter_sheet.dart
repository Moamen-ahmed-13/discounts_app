import 'package:flutter/material.dart';
import '../theme.dart';

class FilterOptions {
  String duration;
  String company;
  String country;

  FilterOptions({
    this.duration = 'جميع المدد',
    this.company = 'جميع الشركات',
    this.country = 'جميع الدول',
  });

  FilterOptions copyWith({String? duration, String? company, String? country}) =>
      FilterOptions(duration: duration ?? this.duration, company: company ?? this.company, country: country ?? this.country);

  bool get isDefault => duration == 'جميع المدد' && company == 'جميع الشركات' && country == 'جميع الدول';
}

class FilterSheet extends StatefulWidget {
  final FilterOptions current;
  final List<String> companies;
  final List<String>? countries; // من /api/labels
  final List<String>? durations; // من /api/labels

  const FilterSheet({
    super.key,
    required this.current,
    this.companies = const ['جميع الشركات'],
    this.countries,
    this.durations,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterOptions _options;

  // Fallback static إذا الـ API ما رجعتش labels
  static const List<String> _defaultDurations = ['جميع المدد', 'ينتهي اليوم', 'ينتهي غدًا', 'خلال 3 أيام', 'خلال أسبوع'];
  static const List<String> _defaultCountries = ['جميع الدول', 'مصر', 'السعودية', 'الإمارات', 'الكويت', 'قطر'];

  List<String> get _durations => widget.durations ?? _defaultDurations;
  List<String> get _countries => widget.countries ?? _defaultCountries;

  List<String> get _companies {
    final list = widget.companies.toList();
    if (!list.contains('جميع الشركات')) list.insert(0, 'جميع الشركات');
    return list;
  }

  @override
  void initState() {
    super.initState();
    _options = FilterOptions(duration: widget.current.duration, company: widget.current.company, country: widget.current.country);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Text('🏷️  كوبونات مميزة', style: AppTheme.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.grey)),
        ]),
        const SizedBox(height: 4),
        Text('أحدث العروض والكوبونات الحصرية التي تمت إضافتها حديثًا إلى منصتنا',
            style: AppTheme.tajawal(fontSize: 12, color: AppTheme.primary)),
        const SizedBox(height: 20),

        _buildDropdown('⏰  المدة:', _options.duration, _durations,
            (v) => setState(() => _options = _options.copyWith(duration: v))),
        const SizedBox(height: 16),

        _buildDropdown('🏢  الشركة/البراند:', _options.company, _companies,
            (v) => setState(() => _options = _options.copyWith(company: v))),
        const SizedBox(height: 16),

        _buildDropdown('🌐  الدولة:', _options.country, _countries,
            (v) => setState(() => _options = _options.copyWith(country: v))),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _options = FilterOptions()),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF9E9E9E), borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.refresh, color: Colors.white, size: 18), const SizedBox(width: 6),
                Text('إعادة تعيين', style: AppTheme.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
              ])),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.pop(context, _options),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.filter_alt, color: Colors.white, size: 18), const SizedBox(width: 6),
                Text('تطبيق الفلاتر', style: AppTheme.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
              ])),
          )),
        ]),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 12),
      ]),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    final safeValue = items.contains(value) ? value : items.first;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.tajawal(fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE0E0E0))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeValue, isExpanded: true, dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            style: AppTheme.tajawal(color: Colors.black, fontSize: 14),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ),
      ),
    ]);
  }
}