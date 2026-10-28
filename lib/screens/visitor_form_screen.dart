import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/visitor.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../viewmodels/visitor_viewmodel.dart';
import '../widgets/custom_text_field.dart';

/// Modern, attractive, and responsive Visitor Registration & Edit Form.
class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key, this.visitor});

  final Visitor? visitor;

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  String? _type;
  String? _project;
  bool _checkInImmediately = false;

  bool get _isEditing => widget.visitor != null;

  @override
  void initState() {
    super.initState();
    final Visitor? visitor = widget.visitor;
    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');
    _type = visitor?.type ?? VisitorOptions.types.first;
    _project = visitor?.project ?? VisitorOptions.projects.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final VisitorViewModel vm = context.read<VisitorViewModel>();
    final String name = _nameController.text.trim();
    final String mobile = _mobileController.text.trim();
    final String email = _emailController.text.trim();
    final String purpose = _purposeController.text.trim();
    final String type = _type ?? VisitorOptions.types.first;
    final String project = _project ?? VisitorOptions.projects.first;

    final bool success;
    if (_isEditing) {
      success = await vm.updateVisitor(
        id: widget.visitor!.id,
        name: name,
        mobile: mobile,
        email: email,
        type: type,
        project: project,
        purpose: purpose,
      );
    } else {
      final Visitor? created = await vm.registerVisitor(
        name: name,
        mobile: mobile,
        email: email,
        type: type,
        project: project,
        purpose: purpose,
      );
      if (created != null && _checkInImmediately) {
        await vm.checkIn(created.id);
      }
      success = created != null;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Visitor details updated successfully.'
              : 'Visitor pass issued successfully.'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Submission failed.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTabletOrLarger(context);
    final double hPadding = Responsive.horizontalPadding(context);
    final bool isSaving = context.watch<VisitorViewModel>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Visitor Details' : 'New Visitor Registration',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Responsive.constrainedContainer(
          context: context,
          maxWidth: 760,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
              children: <Widget>[
                // Header Banner
                _buildHeaderBanner(context),
                const SizedBox(height: 20),

                // Card Section 1: Guest Personal Information
                _buildSectionCard(
                  context,
                  title: 'Guest Identity',
                  icon: Icons.badge_outlined,
                  child: Column(
                    children: <Widget>[
                      if (isTablet)
                        Row(
                          children: <Widget>[
                            Expanded(child: _buildNameField()),
                            const SizedBox(width: 14),
                            Expanded(child: _buildMobileField()),
                          ],
                        )
                      else ...<Widget>[
                        _buildNameField(),
                        const SizedBox(height: 14),
                        _buildMobileField(),
                      ],
                      const SizedBox(height: 14),
                      _buildEmailField(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Card Section 2: Visit Destination & Details
                _buildSectionCard(
                  context,
                  title: 'Visit Information',
                  icon: Icons.apartment_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Category Chips
                      Text(
                        'Visitor Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryChips(),
                      const SizedBox(height: 16),

                      // Project Location Dropdown
                      _buildProjectDropdown(),
                      const SizedBox(height: 14),

                      // Purpose Field
                      _buildPurposeField(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Card Section 3: Fast-Track Clearance (New Registrations Only)
                if (!_isEditing) ...<Widget>[
                  _buildFastTrackCard(context),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 10),

                // Submit Button
                FilledButton.icon(
                  onPressed: isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Icon(
                          _isEditing
                              ? Icons.save_rounded
                              : Icons.how_to_reg_rounded,
                          size: 20,
                        ),
                  label: Text(
                    isSaving
                        ? 'Processing...'
                        : (_isEditing
                            ? 'Save Changes'
                            : 'Issue Digital Pass & Register'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top Welcome / Context Header
  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.contact_mail_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _isEditing
                      ? 'Update Visitor Record'
                      : 'Digital Pass Issuance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing
                      ? 'Modify credentials, project location, or visit reason.'
                      : 'Register guest details to create an instant QR pass.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Clean section container card
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  /// Category Selection ChoiceChips
  Widget _buildCategoryChips() {
    return Row(
      children: VisitorOptions.types.map((String typeName) {
        final bool isSelected = _type == typeName;
        final Color color = visitorTypeColor(typeName);

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(typeName),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) setState(() => _type = typeName);
            },
            selectedColor: color.withValues(alpha: 0.16),
            backgroundColor: AppColors.surface(context),
            labelStyle: TextStyle(
              color: isSelected ? color : AppColors.textSecondary(context),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12.5,
            ),
            side: BorderSide(
              color: isSelected ? color : AppColors.border(context),
              width: isSelected ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Fast-Track Immediate Clearance Card
  Widget _buildFastTrackCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: _checkInImmediately
          ? AppColors.success.withValues(alpha: 0.08)
          : AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: _checkInImmediately
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border(context),
        ),
      ),
      child: SwitchListTile(
        value: _checkInImmediately,
        onChanged: (bool value) => setState(() => _checkInImmediately = value),
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor: _checkInImmediately
              ? AppColors.success
              : AppColors.border(context),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Instant Gate Clearance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        subtitle: const Text(
          'Check-in visitor immediately upon registration',
          style: TextStyle(fontSize: 12, color: AppColors.slate),
        ),
        activeThumbColor: AppColors.success,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameController,
      label: 'Full Name *',
      hint: 'e.g. John Doe',
      prefixIcon: Icons.person_rounded,
      textCapitalization: TextCapitalization.words,
      validator: (String? value) {
        if (value == null || value.trim().length < 2) {
          return 'Please enter a valid full name.';
        }
        return null;
      },
    );
  }

  Widget _buildMobileField() {
    return CustomTextField(
      controller: _mobileController,
      label: 'Mobile Number *',
      hint: '10-digit number',
      prefixIcon: Icons.phone_android_rounded,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (String? value) {
        if (value == null || !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
          return 'Enter a valid 10-digit mobile number.';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      label: 'Email Address *',
      hint: 'name@company.com',
      prefixIcon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: (String? value) {
        if (value == null ||
            !RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+$')
                .hasMatch(value.trim())) {
          return 'Enter a valid email address.';
        }
        return null;
      },
    );
  }

  Widget _buildProjectDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _project,
      decoration: buildFieldDecoration(
        context,
        label: 'Destination Campus / Project *',
        prefixIcon: Icons.location_on_outlined,
      ),
      items: VisitorOptions.projects
          .map((String p) => DropdownMenuItem<String>(value: p, child: Text(p)))
          .toList(),
      onChanged: (String? value) => setState(() => _project = value),
    );
  }

  Widget _buildPurposeField() {
    return CustomTextField(
      controller: _purposeController,
      label: 'Purpose of Visit *',
      hint: 'e.g. Vendor delivery, Client presentation, Technical interview...',
      prefixIcon: Icons.edit_note_rounded,
      minLines: 2,
      maxLines: 3,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please specify the visit purpose.';
        }
        return null;
      },
    );
  }
}
