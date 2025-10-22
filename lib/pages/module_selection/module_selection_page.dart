import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/app_styles.dart';

class ModuleSelectionPage extends StatefulWidget {
  final String studentId;
  final String name;
  final String surname;
  final String specialty;

  const ModuleSelectionPage({
    super.key,
    required this.studentId,
    required this.name,
    required this.surname,
    required this.specialty,
  });

  @override
  State<ModuleSelectionPage> createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWpm = 1; // текущий выбранный WPM
  Map<int, dynamic> wpmData = {}; // данные для каждого WPM, загружаем из базы
  bool loading = true;
  List<String> selectedModules = []; // 🔹 здесь храним ID выбранных модулей
  bool hasChanges = false; // 🔹 для активации кнопки подтверждения

  @override
  void initState() {
    super.initState();
    _loadWpmData();
  }

  Future<void> _loadWpmData() async {
    // Загружаем данные для всех WPM из Firebase
    final ref = FirebaseDatabase.instance.ref('students/${widget.studentId}/wpm');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map<String, dynamic> rawMap =
          Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        // Преобразуем ключи в int
        wpmData = rawMap.map((key, value) => MapEntry(int.parse(key), value));
        loading = false;
      });
    } else {
      setState(() {
        wpmData = {};
        loading = false;
      });
    }
  }

  void _selectWpm(int wpm) {
    setState(() {
      selectedWpm = wpm;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final backgroundColor =
        isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: screenWidth > 600 ? 600 : screenWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Верхний блок: информация студента + WPM
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          bool isMobile = constraints.maxWidth < 400;
                          return isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _studentInfo(textColor),
                                    const SizedBox(height: 16),
                                    _wpmButtons(),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _studentInfo(textColor),
                                    _wpmButtons(),
                                  ],
                                );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Секция с информацией к модулям
                    FutureBuilder<DatabaseEvent>(
                      future: FirebaseDatabase.instance.ref('modules/$selectedWpm/info').once(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError || snapshot.data!.snapshot.value == null) {
                          return Text(
                            'No module info available',
                            style: AppTextStyles.body(isDark: Theme.of(context).brightness == Brightness.dark),
                          );
                        }

                        final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

                        final startDate = data['startDate'] ?? 'N/A';
                        final endDate = data['endDate'] ?? 'N/A';

                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
                        final cardColor = isDark ? AppColors.darkCard : AppColors.card;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Module Selection Info',
                                  style: AppTextStyles.subheading(isDark: isDark)
                                      .copyWith(color: textColor)),
                              const SizedBox(height: 8),
                              Text('Start Date: $startDate',
                                  style: AppTextStyles.body(isDark: isDark)
                                      .copyWith(color: textColor)),
                              Text('End Date: $endDate',
                                  style: AppTextStyles.body(isDark: isDark)
                                      .copyWith(color: textColor)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // 3️⃣ Секция с выбранными модулями
                    FutureBuilder<DatabaseEvent>(
                      future: FirebaseDatabase.instance
                          .ref('students/${widget.studentId}/selectedModules/$selectedWpm')
                          .once(),
                      builder: (context, snapshot) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
                        final cardColor = isDark ? AppColors.darkCard : AppColors.card;

                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<String> selectedModules = [];
                        if (snapshot.data!.snapshot.exists) {
                          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                          selectedModules = data.keys.toList(); // или data.values если нужно
                        }

                        bool hasChanges = false; // будем отслеживать изменения при выборе модулей

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selected Modules',
                                  style: AppTextStyles.subheading(isDark: isDark)
                                      .copyWith(color: textColor)),
                              const SizedBox(height: 12),
                              selectedModules.isEmpty
                                  ? Text('No modules selected',
                                      style: AppTextStyles.body(isDark: isDark)
                                          .copyWith(color: textColor))
                                  : Column(
                                      children: selectedModules
                                          .map(
                                            (module) => Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Text(module,
                                                  style: AppTextStyles.body(isDark: isDark)
                                                      .copyWith(color: textColor)),
                                            ),
                                          )
                                          .toList(),
                                    ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: hasChanges
                                      ? () async {
                                          // сохраняем выбранные модули в базу
                                          await FirebaseDatabase.instance
                                              .ref('students/${widget.studentId}/selectedModules/$selectedWpm')
                                              .set({for (var m in selectedModules) m: true});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Modules updated'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                          setState(() {
                                            hasChanges = false;
                                          });
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Confirm Selection',
                                      style: AppTextStyles.button()),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // 4️⃣ Секция: список всех модулей (аккордеон)
                    FutureBuilder<DatabaseEvent>(
                      future: FirebaseDatabase.instance.ref('modules/$selectedWpm').once(),
                      builder: (context, snapshot) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
                        final cardColor = isDark ? AppColors.darkCard : AppColors.card;

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
                          return Center(
                            child: Text(
                              'No modules available for this WPM',
                              style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor),
                            ),
                          );
                        }

                        final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                        List<Map<String, dynamic>> modules = [];
                        data.forEach((key, value) {
                          modules.add({
                            'id': key,
                            'name': value['name'] ?? 'Unnamed module',
                            'description': value['description'] ?? 'No description available',
                            'lecturer': value['lecturer'] ?? 'Unknown lecturer',
                          });
                        });

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Modules',
                                style: AppTextStyles.subheading(isDark: isDark).copyWith(color: textColor),
                              ),
                              const SizedBox(height: 12),
                              ...modules.map((module) {
                                final moduleId = module['id'];
                                bool isSelected = selectedModules.contains(moduleId);
                                return StatefulBuilder(
                                  builder: (context, setInnerState) {
                                    return ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      title: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedModules.add(moduleId);
                                                } else {
                                                  selectedModules.remove(moduleId);
                                                }
                                                hasChanges = true;
                                              });
                                              setInnerState(() {});
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              module['name'],
                                              style: AppTextStyles.body(isDark: isDark)
                                                  .copyWith(color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          module['description'],
                                          style: AppTextStyles.body(isDark: isDark)
                                              .copyWith(color: textColor.withOpacity(0.8)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Lecturer: ${module['lecturer']}',
                                          style: AppTextStyles.body(isDark: isDark)
                                              .copyWith(fontStyle: FontStyle.italic, color: textColor),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _studentInfo(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.name} ${widget.surname}',
            style: AppTextStyles.heading(isDark: false)
                .copyWith(color: textColor)),
        const SizedBox(height: 4),
        Text(widget.specialty,
            style: AppTextStyles.subheading(isDark: false)
                .copyWith(color: textColor)),
        const SizedBox(height: 8),
        Text('Selected WPM: $selectedWpm',
            style: AppTextStyles.body(isDark: false)
                .copyWith(color: textColor)),
      ],
    );
  }

  Widget _wpmButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final wpm = index + 1;
        final isSelected = selectedWpm == wpm;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: () => _selectWpm(wpm),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSelected ? AppColors.primary : AppColors.backgroundSubtle,
              foregroundColor: isSelected
                  ? Colors.white
                  : AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('WPM $wpm'),
          ),
        );
      }),
    );
  }
}
