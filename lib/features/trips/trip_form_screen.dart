import 'package:flutter/material.dart';

import '../../core/platform/platform_style.dart';
import '../../core/strings/app_strings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
import '../../data/models/trip.dart';

/// S-6. Create / edit a trip (FR-4, FR-5).
///
/// The form keeps its values only while it is open: "Save" checks the one
/// required field (water body), closes the form and shows a notice.
/// Persisting data comes with Firebase in a later lab.
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
}

class _TripFormScreenState extends State<TripFormScreen> {
  late DateTime _dateTime;
  String? _waterBody;
  String? _windDirection;
  late final List<String> _tackle;
  late final List<_CatchDraft> _catches;
  final _tackleController = TextEditingController();
  bool _showErrors = false;

  bool get _isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _dateTime = trip?.dateTime ?? MockData.today;
    _waterBody = trip?.waterBody;
    _windDirection = trip?.weather.windDirection;
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
    super.dispose();
  }

  void _addTackle() {
    final name = _tackleController.text.trim();
    if (name.isEmpty) return;
    setState(() => _tackle.add(name));
    _tackleController.clear();
  }

  void _save() {
    if (_waterBody == null) {
      setState(() => _showErrors = true);
      showNotice(context, AppStrings.fillRequiredField, kind: NoticeKind.error);
      return;
    }
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
                initialValue: widget.trip?.notes,
                maxLines: 4,
              ),
            ]),
          ];
          final catchSection = _catchSection();

          return SingleChildScrollView(
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
    AppSelectField(
      label: AppStrings.waterBodyRequired,
      placeholder: AppStrings.selectWaterBody,
      options: MockData.waterBodies,
      value: _waterBody,
      errorText: _showErrors && _waterBody == null
          ? AppStrings.waterBodyIsRequired
          : null,
      onChanged: (value) => setState(() => _waterBody = value),
    ),
  ];

  List<Widget> _weatherFields() {
    final weather = widget.trip?.weather;
    return [
      _pair(
        AppTextField(
          label: AppStrings.temperatureC,
          prefixIcon: AppIcons.temperature,
          initialValue: '${weather?.temperatureC ?? 14}',
          keyboardType: TextInputType.number,
        ),
        AppTextField(
          label: AppStrings.pressureHpa,
          prefixIcon: AppIcons.pressure,
          initialValue: '${weather?.pressureHpa ?? 1016}',
          keyboardType: TextInputType.number,
        ),
      ),
      const SizedBox(height: AppSpacing.m),
      _pair(
        AppTextField(
          label: AppStrings.windSpeed,
          prefixIcon: AppIcons.wind,
          initialValue: '${weather?.windSpeed ?? 3}',
          keyboardType: TextInputType.number,
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
              icon: AppIcons.tackle,
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
    required this.onChanged,
    required this.onRemove,
  });

  final int number;
  final _CatchDraft draft;
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
                  hint: '0.0',
                  initialValue: draft.weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) => draft.weight = value,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: AppStrings.count,
                  initialValue: draft.count,
                  keyboardType: TextInputType.number,
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
