import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../services/app_state.dart';
import '../../services/plan_service.dart';
import '../../widgets/home/ai_insight_card.dart';
import '../../widgets/home/status_card.dart';
import '../../widgets/home/quick_action_button.dart';
import '../../widgets/shared/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState _appState = AppState();
  final PlanService _planService = PlanService();

  List<PlanData> _plans = [];
  bool _isLoadingPlans = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Profil verilerini yükle
    await _appState.loadProfile();

    // Planları yükle
    await _loadPlans();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoadingPlans = true);

    final result = await _planService.getTodayPlans();

    if (mounted) {
      setState(() {
        _isLoadingPlans = false;
        if (result.isSuccess && result.data != null) {
          _plans = result.data!;
        }
      });
    }
  }

  void _togglePlan(PlanData plan) async {
    final newStatus = !plan.isCompleted;

    // Optimistic update
    setState(() {
      final index = _plans.indexWhere((p) => p.id == plan.id);
      if (index != -1) {
        _plans[index] = plan.copyWith(isCompleted: newStatus);
      }
    });

    // Backend'e güncelleme gönder
    await _planService.togglePlanCompletion(plan.id, newStatus);
  }

  void _showAddPlanDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));
    PlanCategory selectedCategory = PlanCategory.other;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Yeni Plan Ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plan Title Input
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Plan Başlığı',
                      hintText: 'Örn: Vitamin almak',
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: TextStyle(color: colors.textTertiary),
                      hintStyle: TextStyle(color: colors.textMuted),
                    ),
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (İsteğe bağlı)',
                      hintText: 'Detay ekleyin...',
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: TextStyle(color: colors.textTertiary),
                      hintStyle: TextStyle(color: colors.textMuted),
                    ),
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PlanCategory.values.map((category) {
                      final isSelected = selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color.withValues(alpha: 0.2)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? category.color
                                  : colors.border,
                            ),
                          ),
                          child: Text(
                            category.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? category.color
                                  : colors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Time Selection
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedTime),
                      );
                      if (time != null) {
                        setModalState(() {
                          selectedTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.clock,
                            size: 18,
                            color: AppColors.primaryPink,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Saat: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          FaIcon(
                            FontAwesomeIcons.chevronRight,
                            size: 14,
                            color: colors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'İptal',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Plan başlığı gerekli'),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(context);

                              // Plan oluştur
                              final result = await _planService.createPlan(
                                title: titleController.text.trim(),
                                description:
                                    descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                                scheduledTime: selectedTime,
                                category: selectedCategory,
                              );

                              if (result.isSuccess && result.data != null) {
                                setState(() {
                                  _plans.add(result.data!);
                                  _plans.sort(
                                    (a, b) => a.scheduledTime.compareTo(
                                      b.scheduledTime,
                                    ),
                                  );
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Ekle',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = context.colors;

    // AppState'den verileri al
    final pregnancy = _appState.pregnancy;
    final userName = _appState.userFullName;

    // Gebelik bilgisi yoksa varsayılan mesaj
    final weekLabel = pregnancy?.weekLabel ?? '-';
    final daysLabel = pregnancy?.daysLabel ?? '-';
    final aiMessage = pregnancy != null
        ? 'Bebeğiniz şu anda ${pregnancy.babySize} büyüklüğünde. ${pregnancy.babySizeDescription}'
        : 'Hamilelik bilgilerinizi profilinizden ekleyerek bebeğinizin gelişimini takip edebilirsiniz.';

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header with Theme Toggle
            _buildHeader(context, userName, themeProvider),

            const SizedBox(height: 24),

            // AI Insight Card
            AIInsightCard(
              badgeText: AppStrings.babyDevelopment,
              message: aiMessage,
              icon: FontAwesomeIcons.baby,
            ),

            const SizedBox(height: 24),

            // Section: Pregnancy Status
            const SectionHeader(
              title: AppStrings.pregnancyStatus,
              actionText: AppStrings.calendar,
            ),

            const SizedBox(height: 16),

            // Status Cards Grid
            StatusCardsGrid(
              cards: [
                StatusCard(
                  icon: FontAwesomeIcons.calendarCheck,
                  iconBackgroundColor: colors.pinkLight,
                  iconColor: AppColors.primaryPink,
                  value: weekLabel,
                  label: AppStrings.pregnancyWeek,
                ),
                StatusCard(
                  icon: FontAwesomeIcons.hourglassHalf,
                  iconBackgroundColor: colors.purpleLight,
                  iconColor: AppColors.primaryPurple,
                  value: daysLabel,
                  label: AppStrings.daysUntilBirth,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Quick Actions
            const SectionHeader(title: AppStrings.quickActions),

            const SizedBox(height: 16),

            // Quick Actions Row
            QuickActionsRow(
              actions: [
                QuickActionButton(
                  icon: FontAwesomeIcons.shoePrints,
                  label: AppStrings.kick,
                  iconBackgroundColor: colors.redLight,
                  iconColor: AppColors.red,
                  onTap: () {
                    // Log kick
                  },
                ),
                QuickActionButton(
                  icon: FontAwesomeIcons.weightScale,
                  label: AppStrings.addWeight,
                  iconBackgroundColor: colors.greenLight,
                  iconColor: AppColors.green,
                  onTap: () {
                    // Add weight
                  },
                ),
                QuickActionButton(
                  icon: FontAwesomeIcons.glassWater,
                  label: AppStrings.waterTracking,
                  iconBackgroundColor: colors.blueLight,
                  iconColor: AppColors.primaryBlue,
                  onTap: () {
                    // Track water
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Today's Plan with Add Button
            _buildTodaysPlanHeader(context),

            const SizedBox(height: 16),

            // Plans List or Empty State
            _buildPlansList(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String userName,
    ThemeProvider themeProvider,
  ) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tekrar merhaba,',
                style: TextStyle(fontSize: 14, color: colors.textTertiary),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('🤰', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),

          // Theme Toggle & Profile
          Row(
            children: [
              // Theme Toggle Button
              GestureDetector(
                onTap: () => themeProvider.toggleTheme(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: FaIcon(
                        themeProvider.isDarkMode
                            ? FontAwesomeIcons.sun
                            : FontAwesomeIcons.moon,
                        key: ValueKey(themeProvider.isDarkMode),
                        size: 16,
                        color: themeProvider.isDarkMode
                            ? AppColors.primaryPink
                            : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Profile Picture
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colors.borderLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 20,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysPlanHeader(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.todaysPlan,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
          // Eğer plan varsa + butonu göster
          if (_plans.isNotEmpty)
            GestureDetector(
              onTap: _showAddPlanDialog,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.plus,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlansList(BuildContext context) {
    final colors = context.colors;

    if (_isLoadingPlans) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryPink,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_plans.isEmpty) {
      // Empty State
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryPink.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.calendarPlus,
                    size: 28,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz planınız yok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Günlük planlarınızı ekleyerek hamilelik sürecinizi daha organize geçirebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textTertiary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: _showAddPlanDialog,
                  icon: const FaIcon(
                    FontAwesomeIcons.plus,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Plan Ekle',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Plans List
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _plans
            .map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPlanCard(context, plan),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PlanData plan) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: plan.category.color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 45,
            child: Text(
              plan.timeLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    decoration: plan.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (plan.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    plan.description!,
                    style: TextStyle(fontSize: 13, color: colors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          // Checkbox
          GestureDetector(
            onTap: () => _togglePlan(plan),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: plan.isCompleted
                    ? plan.category.color
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: plan.isCompleted
                      ? plan.category.color
                      : colors.borderMedium,
                  width: 2,
                ),
              ),
              child: plan.isCompleted
                  ? const Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
