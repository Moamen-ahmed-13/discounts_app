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

  FilterOptions copyWith({String? duration, String? company, String? country}) {
    return FilterOptions(
      duration: duration ?? this.duration,
      company: company ?? this.company,
      country: country ?? this.country,
    );
  }

  bool get isDefault =>
      duration == 'جميع المدد' &&
      company == 'جميع الشركات' &&
      country == 'جميع الدول';
}

class FilterSheet extends StatefulWidget {
  final FilterOptions current;
  const FilterSheet({super.key, required this.current});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterOptions _options;

  final List<String> _durations = [
    'جميع المدد',
    'ينتهي اليوم',
    'ينتهي غدًا',
    'خلال 3 أيام',
    'خلال أسبوع'
  ];
  final List<String> _companies = [
    'جميع الشركات',
    'نون',
    'أمازون',
    'علي إكسبريس',
    'جوميا'
  ];
  final List<String> _countries = [
    'جميع الدول',
    'مصر',
    'السعودية',
    'الإمارات',
    'الكويت',
    'قطر'
  ];

  @override
  void initState() {
    super.initState();
    _options = FilterOptions(
      duration: widget.current.duration,
      company: widget.current.company,
      country: widget.current.country,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Text('🏷️  كوبونات مميزة',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Colors.black)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
              'أحدث العروض والكوبونات الحصرية التي تمت إضافتها حديثًا إلى منصتنا',
              style: TextStyle(
                  fontSize: 12, fontFamily: 'Cairo', color: AppTheme.primary)),
          const SizedBox(height: 20),

          // Duration
          _buildDropdown('⏰  المدة:', _options.duration, _durations,
              (v) => setState(() => _options = _options.copyWith(duration: v))),
          const SizedBox(height: 16),

          // Company
          _buildDropdown('🏢  الشركة/البراند:', _options.company, _companies,
              (v) => setState(() => _options = _options.copyWith(company: v))),
          const SizedBox(height: 16),

          // Country
          _buildDropdown('🌐  الدولة:', _options.country, _countries,
              (v) => setState(() => _options = _options.copyWith(country: v))),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              // Reset
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _options = FilterOptions()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E9E9E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('إعادة تعيين',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Apply
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, _options),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_alt, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('تطبيق الفلاتر',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 12),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: const TextStyle(
                  fontFamily: 'Cairo', color: Colors.black, fontSize: 14),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
