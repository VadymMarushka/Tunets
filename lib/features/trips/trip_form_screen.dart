// PLATFORM-SPECIFIC CODE: this file contains both Android and Windows variants.
// Blocks are marked with "Android (Material 3)" / "Windows (Fluent)" comments.
// In `isFluent ? a : b` expressions, `a` is the Windows value, `b` the Android one.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_pickers.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/info_chips.dart';
import '../../core/widgets/photo_drop_zone.dart';
import '../../core/widgets/section_header.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/catch_entry.dart';
import '../../data/models/trip.dart';
import 'bloc/trips_bloc.dart';

/// S-6. Create / edit a trip (FR-4, FR-5).
///
/// While the form is open its values are ephemeral state of this screen.
/// "Save" validates them, builds a [Trip] and sends [TripSaved] to
/// [TripsBloc], which stores it on the device. Catch photos are not
/// stored yet (the photo zone is a placeholder).
class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key, this.trip});

  /// Trip to edit; `null` creates a new one.
  final Trip? trip;

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _CatchDraft {
  _CatchDraft({this.species, this.weight = '', this.count = '1'});

  final key = UniqueKey();
  String? species;
  String weight;
  String count;

  /// Untouched row (no species, no weight): ignored on save, so a trip
  /// without fish doesn't need its empty row removed first.
  bool get isBlank => species == null && weight.trim().isEmpty;

  CatchEntry toEntry() => CatchEntry(
    species: species!,
    weightKg: Validators.parseDecimal(weight)!,
    count: int.parse(count.trim()),
  );
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dateTime;
  late final TextEditingController _waterBody;
  String? _windDirection;
  late final List<String> _tackle;
  late final List<_CatchDraft> _catches;
  final _tackleController = TextEditingController();
  late final TextEditingController _temperature;
  late final TextEditingController _pressure;
  late final TextEditingController _windSpeed;
  late final TextEditingController _notes;
  bool _showErrors = false;

  bool get _isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    final weather = trip?.weather;
    final now = DateTime.now();
    _dateTime =
        trip?.dateTime ??
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _waterBody = TextEditingController(text: trip?.waterBody ?? '');
    final wind = weather?.windDirection ?? '';
    _windDirection = wind.isEmpty ? null : wind;
    _temperature = TextEditingController(
      text: '${weather?.temperatureC ?? 14}',
    );
    _pressure = TextEditingController(text: '${weather?.pressureHpa ?? 1016}');
    _windSpeed = TextEditingController(text: '${weather?.windSpeed ?? 3}');
    _notes = TextEditingController(text: trip?.notes ?? '');
    _tackle = [...?trip?.tackle];
    _catches = trip == null
        ? [_CatchDraft()]
        : [
            for (final c in trip.catches)
              _CatchDraft(
                species: c.species,
                weight: c.weightKg.toString(),
                count: c.count.toString(),
              ),
          ];
  }

  @override
  void dispose() {
    _tackleController.dispose();
    _waterBody.dispose();
    _temperature.dispose();
    _pressure.dispose();
    _windSpeed.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _addTackle() {
    final name = _tackleController.text.trim();
    if (name.isEmpty) return;
    setState(() => _tackle.add(name));
    _tackleController.clear();
  }

  void _save() {
    setState(() => _showErrors = true);
    final fieldsValid = _formKey.currentState!.validate();
    final catchesValid = _catches.every((c) => c.isBlank || c.species != null);
    if (!fieldsValid || !catchesValid) {
      showNotice(context, AppStrings.fixFormErrors, kind: NoticeKind.error);
      return;
    }

    final trip = Trip(
      // Editing keeps the id, so the bloc replaces the stored trip.
      id: widget.trip?.id ?? 'trip-${DateTime.now().microsecondsSinceEpoch}',
      dateTime: _dateTime,
      waterBody: _waterBody.text.trim(),
      weather: Weather(
        temperatureC: int.parse(_temperature.text.trim()),
        pressureHpa: int.parse(_pressure.text.trim()),
        windDirection: _windDirection ?? '',
        windSpeed: int.parse(_windSpeed.text.trim()),
      ),
      tackle: List.of(_tackle),
      catches: [
        for (final draft in _catches)
          if (!draft.isBlank) draft.toEntry(),
      ],
      notes: _notes.text.trim(),
    );
    context.read<TripsBloc>().add(TripSaved(trip));
    showNotice(context, AppStrings.tripSaved);
    Navigator.of(context).pop();
  }

  void _cancel() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? AppStrings.editTrip : AppStrings.addTrip;

    return AppPage(
      title: title,
      parentTitle: AppStrings.navTrips,
      actions: [
        PageAction(
          label: AppStrings.save,
          icon: AppIcons.save,
          primary: true,
          showOnMaterial: false,
          onPressed: _save,
        ),
        PageAction(
          label: AppStrings.cancel,
          icon: AppIcons.cancel,
          showOnMaterial: false,
          onPressed: _cancel,
        ),
      ],
      materialBottomBar: _MaterialFormBar(onCancel: _cancel, onSave: _save),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= Breakpoints.twoColumns;
          final main = [
            _section(AppStrings.trip, _tripFields()),
            _section(AppStrings.weather, _weatherFields()),
            _section(AppStrings.tackle, _tackleFields()),
            _section(AppStrings.notes, [
              AppTextField(
                label: AppStrings.notes,
                hint: AppStrings.notesHint,
                controller: _notes,
                maxLines: 4,
              ),
            ]),
          ];
          final catchSection = _catchSection();

          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            child: SingleChildScrollView(
              padding: pagePadding(),
              child: ContentConstraint(
                child: twoColumns
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _column(main)),
                          const SizedBox(width: AppSpacing.l),
                          Expanded(child: catchSection),
                        ],
                      )
                    : _column([...main.take(3), catchSection, main.last]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _column(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final child in children) ...[
        child,
        const SizedBox(height: AppSpacing.m),
      ],
    ],
  );

  /// Material: plain titled group; Windows: group on a card (mockup).
  Widget _section(String title, List<Widget> children, {Widget? trailing}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title, trailing: trailing),
        ...children,
      ],
    );
    return PlatformStyle.isFluent ? AppCard(child: content) : content;
  }

  List<Widget> _tripFields() => [
    _pair(
      AppDateField(
        label: AppStrings.date,
        value: _dateTime,
        onChanged: (value) => setState(() => _dateTime = value),
      ),
      AppTimeField(
        label: AppStrings.time,
        value: _dateTime,
        onChanged: (value) => setState(() => _dateTime = value),
      ),
    ),
    const SizedBox(height: AppSpacing.m),
    AppTextField(
      label: AppStrings.waterBodyRequired,
      hint: AppStrings.waterBodyHint,
      controller: _waterBody,
      prefixIcon: AppIcons.waterBody,
      textInputAction: TextInputAction.next,
      validator: Validators.waterBody,
      suggestions: MockData.waterBodySuggestions,
    ),
  ];

  List<Widget> _weatherFields() {
    return [
      _pair(
        AppTextField(
          label: AppStrings.temperatureC,
          hint: AppStrings.temperatureHint,
          prefixIcon: AppIcons.temperature,
          controller: _temperature,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          validator: Validators.wholeNumber,
        ),
        AppTextField(
          label: AppStrings.pressureHpa,
          hint: AppStrings.pressureHint,
          prefixIcon: AppIcons.pressure,
          controller: _pressure,
          keyboardType: TextInputType.number,
          validator: Validators.positiveWholeNumber,
        ),
      ),
      const SizedBox(height: AppSpacing.m),
      _pair(
        AppTextField(
          label: AppStrings.windSpeed,
          hint: AppStrings.windSpeedHint,
          prefixIcon: AppIcons.wind,
          controller: _windSpeed,
          keyboardType: TextInputType.number,
          validator: Validators.wholeNumber,
        ),
        AppSelectField(
          label: AppStrings.windDirection,
          placeholder: AppStrings.select,
          options: MockData.windDirections,
          value: _windDirection,
          onChanged: (value) => setState(() => _windDirection = value),
        ),
      ),
    ];
  }

  List<Widget> _tackleFields() => [
    if (_tackle.isNotEmpty) ...[
      Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [
          for (final item in _tackle)
            InfoChip(
              icon: const Icon(AppIcons.tackle),
              label: item,
              onDeleted: () => setState(() => _tackle.remove(item)),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.m),
    ],
    Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppTextField(
            label: AppStrings.tackleName,
            hint: AppStrings.tackleHint,
            controller: _tackleController,
            prefixIcon: AppIcons.tackle,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addTackle(),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        AppButton.secondary(
          label: AppStrings.add,
          icon: AppIcons.add,
          onPressed: _addTackle,
        ),
      ],
    ),
  ];

  Widget _catchSection() {
    return _section(
      AppStrings.catchTitle,
      trailing: AppButton.text(
        label: AppStrings.addCatch,
        icon: AppIcons.add,
        onPressed: () => setState(() => _catches.add(_CatchDraft())),
      ),
      [
        if (_catches.isEmpty)
          Text(
            AppStrings.noCatchMessage,
            style: AppTextStyles.secondary(context),
          ),
        for (var i = 0; i < _catches.length; i++) ...[
          _CatchEditor(
            key: _catches[i].key,
            number: i + 1,
            draft: _catches[i],
            showErrors: _showErrors,
            onChanged: () => setState(() {}),
            onRemove: () => setState(() => _catches.removeAt(i)),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  /// Two fields side by side.
  Widget _pair(Widget first, Widget second) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: first),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: second),
    ],
  );
}

/// One catch entry: species, weight, count and photo.
class _CatchEditor extends StatelessWidget {
  const _CatchEditor({
    super.key,
    required this.number,
    required this.draft,
    required this.showErrors,
    required this.onChanged,
    required this.onRemove,
  });

  final int number;
  final _CatchDraft draft;

  /// "Save" was pressed: mark a missing species.
  final bool showErrors;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.catchNumber(number),
                  style: AppTextStyles.bodyStrong(context),
                ),
              ),
              AppIconButton(
                icon: AppIcons.delete,
                tooltip: AppStrings.remove,
                onPressed: onRemove,
              ),
            ],
          ),
          AppSelectField(
            label: AppStrings.species,
            placeholder: AppStrings.selectSpecies,
            options: MockData.species,
            value: draft.species,
            errorText: showErrors && !draft.isBlank && draft.species == null
                ? AppStrings.speciesRequired
                : null,
            onChanged: (value) {
              draft.species = value;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: AppStrings.weightKg,
                  hint: AppStrings.weightHint,
                  initialValue: draft.weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      draft.isBlank ? null : Validators.positiveDecimal(value),
                  // Rebuild: the row may stop being blank (species error).
                  onChanged: (value) {
                    draft.weight = value;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: AppStrings.count,
                  hint: AppStrings.countHint,
                  initialValue: draft.count,
                  keyboardType: TextInputType.number,
                  validator: (value) => draft.isBlank
                      ? null
                      : Validators.positiveWholeNumber(value),
                  onChanged: (value) => draft.count = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const PhotoDropZone(),
        ],
      ),
    );
  }
}

/// Android form actions pinned to the bottom: Cancel / Save.
class _MaterialFormBar extends StatelessWidget {
  const _MaterialFormBar({required this.onCancel, required this.onSave});

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: AppStrings.cancel,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(label: AppStrings.save, onPressed: onSave),
            ),
          ],
        ),
      ),
    );
  }
}
