import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../domain/entities/membership_plan.dart';
import '../providers/membership_plan_provider.dart';

class MembershipPlanForm
    extends ConsumerStatefulWidget {
  const MembershipPlanForm({
    super.key,
    required this.gymId,
    this.plan,
  });

  final String gymId;
  final MembershipPlan? plan;

  @override
  ConsumerState<MembershipPlanForm> createState() =>
      _MembershipPlanFormState();
}

class _MembershipPlanFormState
    extends ConsumerState<MembershipPlanForm> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _priceController;

  late final TextEditingController
  _durationController;

  late final TextEditingController
  _descriptionController;

  bool _isActive = true;

  bool get _isEditing =>
      widget.plan != null;

  @override
  void initState() {
    super.initState();

    final plan = widget.plan;

    _nameController =
        TextEditingController(
          text: plan?.name ?? '',
        );

    _priceController =
        TextEditingController(
          text: plan != null
              ? plan.price.toStringAsFixed(0)
              : '',
        );

    _durationController =
        TextEditingController(
          text: plan != null
              ? plan.durationInDays.toString()
              : '',
        );

    _descriptionController =
        TextEditingController(
          text: plan?.description ?? '',
        );

    _isActive =
        plan?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  bool _hasChanges({
    required String name,
    required double price,
    required int duration,
    required String? description,
  }) {
    final plan = widget.plan;

    if (plan == null) {
      return true;
    }

    final oldDescription =
    plan.description?.trim();

    return name.trim() !=
        plan.name.trim() ||
        price != plan.price ||
        duration !=
            plan.durationInDays ||
        description != oldDescription ||
        _isActive != plan.isActive;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final name =
    _nameController.text.trim();

    final price =
    double.parse(
      _priceController.text.trim(),
    );

    final duration =
    int.parse(
      _durationController.text.trim(),
    );

    final descriptionText =
    _descriptionController
        .text
        .trim();

    final description =
    descriptionText.isEmpty
        ? null
        : descriptionText;

    if (_isEditing &&
        !_hasChanges(
          name: name,
          price: price,
          duration: duration,
          description: description,
        )) {
      Navigator.of(context).pop(
        MembershipPlanActionResult
            .noChanges,
      );
      return;
    }

    final controller = ref.read(
      membershipPlanControllerProvider
          .notifier,
    );

    MembershipPlanActionResult result;

    if (_isEditing) {
      result = await controller.updatePlan(
        plan: widget.plan!,
        gymId: widget.gymId,
        name: name,
        price: price,
        durationInDays: duration,
        description: description,
        isActive: _isActive,
      );
    } else {
      result = await controller.createPlan(
        gymId: widget.gymId,
        name: name,
        price: price,
        durationInDays: duration,
        description: description,
      );
    }

    if (!mounted) {
      return;
    }

    if (result ==
        MembershipPlanActionResult
            .created) {
      Navigator.of(context).pop(result);
      return;
    }

    if (result ==
        MembershipPlanActionResult
            .updated) {
      Navigator.of(context).pop(result);
      return;
    }

    if (result ==
        MembershipPlanActionResult
            .duplicate) {
      _showMessage(
        'A membership plan with the same name, price and duration already exists.',
      );
      return;
    }

    _showMessage(
      'Failed to save membership plan.',
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state = ref.watch(
      membershipPlanControllerProvider,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 24,
        bottom:
        MediaQuery.of(context)
            .viewInsets
            .bottom +
            24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing
                    ? 'Edit Membership Plan'
                    : 'Create Membership Plan',
                style: AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              TextFormField(
                controller:
                _nameController,
                decoration:
                const InputDecoration(
                  labelText:
                  'Plan Name',
                  prefixIcon:
                  Icon(
                    Icons
                        .card_membership_outlined,
                  ),
                ),
                validator:
                _requiredValidator,
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller:
                _priceController,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                const InputDecoration(
                  labelText:
                  'Price',
                  prefixIcon:
                  Icon(
                    Icons.currency_rupee,
                  ),
                ),
                validator:
                _priceValidator,
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller:
                _durationController,
                keyboardType:
                TextInputType.number,
                decoration:
                const InputDecoration(
                  labelText:
                  'Duration in Days',
                  prefixIcon:
                  Icon(
                    Icons
                        .calendar_today_outlined,
                  ),
                ),
                validator:
                _durationValidator,
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller:
                _descriptionController,
                maxLines: 3,
                decoration:
                const InputDecoration(
                  labelText:
                  'Description',
                  prefixIcon:
                  Icon(
                    Icons
                        .description_outlined,
                  ),
                  alignLabelWithHint:
                  true,
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(
                  height: 14,
                ),

                SwitchListTile(
                  contentPadding:
                  EdgeInsets.zero,
                  activeThumbColor: AppColors.owner,
                  activeTrackColor: AppColors.owner.withValues(alpha: 0.5),
                  title:
                  const Text(
                    'Active Plan',
                  ),
                  subtitle:
                  Text(
                    _isActive
                        ? 'Members can subscribe to this plan.'
                        : 'New members cannot subscribe to this plan.',
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                  value: _isActive,
                  onChanged:
                      (value) {
                    setState(() {
                      _isActive =
                          value;
                    });
                  },
                ),
              ],

              const SizedBox(
                height: 18,
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.owner,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed:
                  state.isLoading
                      ? null
                      : _submit,
                  child:
                  state.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                      : Text(
                    _isEditing
                        ? 'Save Changes'
                        : 'Create Plan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _priceValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Price is required';
    }

    final price =
    double.tryParse(
      value.trim(),
    );

    if (price == null ||
        price < 0) {
      return 'Enter a valid price';
    }

    return null;
  }

  String? _durationValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Duration is required';
    }

    final duration =
    int.tryParse(
      value.trim(),
    );

    if (duration == null ||
        duration <= 0) {
      return 'Enter a valid duration';
    }

    return null;
  }
}