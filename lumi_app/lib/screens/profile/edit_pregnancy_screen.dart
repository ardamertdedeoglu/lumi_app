import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/profile_service.dart';

class EditPregnancyScreen extends StatefulWidget {
  final PregnancyData? pregnancy; // null ise yeni oluşturma
  final VoidCallback onSaved;

  const EditPregnancyScreen({
    super.key,
    this.pregnancy,
    required this.onSaved,
  });

  @override
  State<EditPregnancyScreen> createState() => _EditPregnancyScreenState();
}

class _EditPregnancyScreenState extends State<EditPregnancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  late TextEditingController _doctorNameController;
  late TextEditingController _hospitalNameController;
  late TextEditingController _notesController;
  DateTime? _lastPeriodDate;
  DateTime? _expectedDueDate;
  String? _bloodType;
  bool _isLoading = false;

  bool get isEditing => widget.pregnancy != null;

  final List<String> _bloodTypes = [
    'A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 
    'AB Rh+', 'AB Rh-', '0 Rh+', '0 Rh-'
  ];

  @override
  void initState() {
    super.initState();
    _doctorNameController = TextEditingController(
      text: widget.pregnancy?.doctorName ?? '',
    );
    _hospitalNameController = TextEditingController(
      text: widget.pregnancy?.hospitalName ?? '',
    );
    _notesController = TextEditingController(
      text: widget.pregnancy?.notes ?? '',
    );
    _lastPeriodDate = widget.pregnancy?.lastPeriodDate;
    _expectedDueDate = widget.pregnancy?.expectedDueDate;
    _bloodType = widget.pregnancy?.bloodType;
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _hospitalNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectLastPeriodDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 84)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
        // Otomatik tahmini doğum tarihi hesapla (280 gün)
        _expectedDueDate = picked.add(const Duration(days: 280));
      });
    }
  }

  Future<void> _selectExpectedDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDueDate ?? DateTime.now().add(const Duration(days: 196)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 280)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _expectedDueDate = picked);
    }
  }

  Future<void> _savePregnancy() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lastPeriodDate == null || _expectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tarihleri seçin'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    ProfileResult<PregnancyData> result;

    if (isEditing) {
      result = await _profileService.updatePregnancy(
        lastPeriodDate: _lastPeriodDate,
        expectedDueDate: _expectedDueDate,
        doctorName: _doctorNameController.text.trim().isNotEmpty 
            ? _doctorNameController.text.trim() 
            : null,
        hospitalName: _hospitalNameController.text.trim().isNotEmpty 
            ? _hospitalNameController.text.trim() 
            : null,
        bloodType: _bloodType,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );
    } else {
      result = await _profileService.createPregnancy(
        lastPeriodDate: _lastPeriodDate!,
        expectedDueDate: _expectedDueDate!,
        doctorName: _doctorNameController.text.trim().isNotEmpty 
            ? _doctorNameController.text.trim() 
            : null,
        hospitalName: _hospitalNameController.text.trim().isNotEmpty 
            ? _hospitalNameController.text.trim() 
            : null,
        bloodType: _bloodType,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );
    }

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Hamilelik bilgisi güncellendi' : 'Hamilelik bilgisi oluşturuldu'),
            backgroundColor: AppColors.green,
          ),
        );
        widget.onSaved();
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Hamilelik Bilgisini Düzenle' : 'Hamilelik Bilgisi Ekle',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.baby,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  isEditing 
                      ? 'Hamilelik bilgilerinizi güncelleyin' 
                      : 'Hamilelik yolculuğunuza başlayın',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Required Section
              _buildSectionTitle('Zorunlu Bilgiler', colors),

              const SizedBox(height: 16),

              // Last Period Date
              _buildDateSelector(
                context,
                label: 'Son Adet Tarihi *',
                value: _lastPeriodDate,
                icon: FontAwesomeIcons.calendarDay,
                iconColor: AppColors.primaryPink,
                dateFormat: dateFormat,
                onTap: _selectLastPeriodDate,
              ),

              const SizedBox(height: 16),

              // Expected Due Date
              _buildDateSelector(
                context,
                label: 'Tahmini Doğum Tarihi *',
                value: _expectedDueDate,
                icon: FontAwesomeIcons.baby,
                iconColor: AppColors.primaryPurple,
                dateFormat: dateFormat,
                onTap: _selectExpectedDueDate,
              ),

              const SizedBox(height: 32),

              // Optional Section
              _buildSectionTitle('İsteğe Bağlı Bilgiler', colors),

              const SizedBox(height: 16),

              // Doctor Name
              _buildTextField(
                controller: _doctorNameController,
                label: 'Doktor Adı',
                icon: FontAwesomeIcons.userDoctor,
                iconColor: AppColors.primaryBlue,
                colors: colors,
              ),

              const SizedBox(height: 16),

              // Hospital Name
              _buildTextField(
                controller: _hospitalNameController,
                label: 'Hastane Adı',
                icon: FontAwesomeIcons.hospital,
                iconColor: AppColors.green,
                colors: colors,
              ),

              const SizedBox(height: 16),

              // Blood Type Dropdown
              _buildBloodTypeSelector(colors),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Notlar',
                  labelStyle: TextStyle(color: colors.textTertiary),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePregnancy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Güncelle' : 'Kaydet',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, LumiColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required IconData icon,
    required Color iconColor,
    required DateFormat dateFormat,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(icon, size: 16, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null ? dateFormat.format(value) : 'Seçilmedi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: value != null ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required LumiColors colors,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textTertiary),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, size: 16, color: iconColor),
            ),
          ),
        ),
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
        ),
      ),
    );
  }

  Widget _buildBloodTypeSelector(LumiColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.droplet,
                size: 16,
                color: AppColors.red,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _bloodType,
                hint: Text(
                  'Kan Grubu',
                  style: TextStyle(color: colors.textTertiary),
                ),
                isExpanded: true,
                icon: Icon(Icons.chevron_right, color: colors.textTertiary),
                dropdownColor: colors.card,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _bloodType = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
