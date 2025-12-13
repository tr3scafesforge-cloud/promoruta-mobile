import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/widgets/custom_button.dart';
import 'package:promoruta/shared/widgets/app_card.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:promoruta/shared/constants/map_constants.dart';
import '../widgets/coverage_zone_map_picker.dart';

class CreateCampaignPage extends ConsumerStatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  ConsumerState<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends ConsumerState<CreateCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  String? _audioFileName;
  File? _audioFile;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isUploading = false;

  // Coverage zone map points
  List<LatLng> _routeWaypoints = [];
  Map<int, String> _routeWaypointNames = {};
  bool _showMap = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createCampaign,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              l10n.createCampaignSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.info_outline,
                    iconColor: AppColors.secondary,
                    title: l10n.basicInformation,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.campaignTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: l10n.campaignNameHint,
                      hintStyle: TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.secondary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterCampaignTitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.briefCampaignDescription,
                      hintStyle: TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.secondary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterDescription;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Anuncio de audio Section
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.volume_up,
                    iconColor: AppColors.secondary,
                    title: l10n.audioAnnouncement,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.uploadAudioFile,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_audioFileName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.audio_file, color: AppColors.secondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _audioFileName!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              setState(() {
                                _audioFileName = null;
                                _audioFile = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  CustomButton(
                    text: _audioFileName == null
                        ? l10n.addAudioFile
                        : l10n.changeAudioFile,
                    backgroundColor: AppColors.secondary,
                    onPressed: _pickAudioFile,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.audioFileSpecs,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Presupuesto y ubicación Section
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.attach_money,
                    iconColor: AppColors.secondary,
                    title: l10n.budgetAndLocation,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.budget,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '50',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.secondary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterBudget;
                      }
                      if (double.tryParse(value) == null) {
                        return l10n.enterValidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.coverageZone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_showMap)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMap = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grayStroke),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 48,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seleccionar zona en el mapa',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _routeWaypoints.length >= 2
                                  ? 'Ruta de ${_routeWaypoints.length} puntos ✓'
                                  : 'Toca para abrir el mapa',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_showMap)
                    CoverageZoneMapPicker(
                      initialCenter: LatLng(
                        MapConstants.montevideoLat,
                        MapConstants.montevideoLng,
                      ),
                      initialWaypoints: _routeWaypoints.isEmpty ? null : _routeWaypoints,
                      onRouteSelected: (waypoints, waypointNames, route) {
                        setState(() {
                          _routeWaypoints = waypoints;
                          _routeWaypointNames = waypointNames;

                          if (waypoints.isEmpty) {
                            _locationController.text = '';
                          } else if (route != null) {
                            // Build description from street names
                            final startName = waypointNames[0] ?? 'Inicio';
                            final endName = waypointNames[waypoints.length - 1] ?? 'Fin';
                            _locationController.text =
                                '$startName → $endName (${route.distanceKm.toStringAsFixed(1)} km)';
                          } else {
                            _locationController.text =
                                '${waypoints.length} puntos seleccionados';
                          }
                        });
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agenda de campaña Section
                  _SectionHeader(
                    icon: Icons.calendar_today,
                    iconColor: AppColors.secondary,
                    title: l10n.campaignSchedule,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.date,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: l10n.dateFormatHint,
                      hintStyle: TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      suffixIcon: Icon(Icons.calendar_today,
                          color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.grayStroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.secondary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseSelectDate;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.startTime,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _startTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: '09:00',
                                hintStyle: TextStyle(color: AppColors.textHint),
                                filled: true,
                                fillColor: AppColors.surface,
                                suffixIcon: Icon(Icons.access_time,
                                    color: AppColors.textSecondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.grayStroke),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.grayStroke),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: AppColors.secondary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onTap: () => _selectTime(isStartTime: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.required;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.endTime,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _endTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: '17:00',
                                hintStyle: TextStyle(color: AppColors.textHint),
                                filled: true,
                                fillColor: AppColors.surface,
                                suffixIcon: Icon(Icons.access_time,
                                    color: AppColors.textSecondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.grayStroke),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.grayStroke),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: AppColors.secondary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onTap: () => _selectTime(isStartTime: false),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.required;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Create Campaign Button
            _isUploading
                ? Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.uploadingAudioFile,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : CustomButton(
                    text: l10n.createCampaign,
                    backgroundColor: AppColors.secondary,
                    onPressed: _createCampaign,
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size (10 MB max)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.fileTooLarge),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // Validate duration (30 seconds max) - This would require additional audio analysis
        // For now, we'll just check file size as a rough estimate

        setState(() {
          _audioFileName = file.name;
          _audioFile = File(file.path!);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.fileSelected(file.name)),
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSelectingFile(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _endTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _createCampaign() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate audio file is selected
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectAudioFile),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate route waypoints are selected
    if (_routeWaypoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona al menos 2 puntos en el mapa para la ruta'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate time range
    // For same-day campaigns, start time must be before end time
    // For cross-midnight campaigns, user should select different dates
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (startMinutes >= endMinutes) {
      // Start time is after or equal to end time on the same day
      // This could be a cross-midnight scenario (e.g., 23:00 to 01:00)
      // For now, we guide users to use different dates for such cases
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.startTimeMustBeBeforeEndTime),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmCampaignCreation),
        content: Text(l10n.campaignCreationWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.confirm,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    // If user cancelled, return
    if (confirmed != true) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Bid deadline: 2 days before start time
      final bidDeadline = startDateTime.subtract(const Duration(days: 2));

      // Convert waypoints to RouteCoordinate format
      final routeCoordinates = _routeWaypoints
          .map((waypoint) => RouteCoordinate(
                lat: waypoint.latitude,
                lng: waypoint.longitude,
              ))
          .toList();

      // Calculate straight-line distance between waypoints as fallback
      // TODO: Use actual route distance from RouteModel when available
      double totalDistance = 0.0;
      for (int i = 0; i < _routeWaypoints.length - 1; i++) {
        final point1 = _routeWaypoints[i];
        final point2 = _routeWaypoints[i + 1];

        // Simple Haversine formula for distance calculation
        const earthRadius = 6371.0; // km
        final dLat = _toRadians(point2.latitude - point1.latitude);
        final dLon = _toRadians(point2.longitude - point1.longitude);

        final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

        final c = 2 * math.asin(math.sqrt(a));
        totalDistance += earthRadius * c;
      }

      // Create campaign object
      final newCampaign = Campaign(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        zone: _locationController.text.trim().isEmpty
            ? 'Default Zone'
            : _locationController.text.trim(),
        suggestedPrice: double.tryParse(_budgetController.text.trim()) ?? 0.0,
        bidDeadline: bidDeadline,
        audioDuration: 30, // Placeholder - should be calculated from audio file
        distance: totalDistance,
        routeCoordinates: routeCoordinates,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      // Create campaign with audio file (audio will be uploaded first)
      final campaignRepository = ref.read(campaignRepositoryProvider);
      final _ = await campaignRepository.createCampaign(
        newCampaign,
        audioFile: _audioFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.campaignCreatedSuccessfully),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 4),
          ),
        );

        // Reload campaigns list
        ref.read(campaignsProvider.notifier).loadCampaigns();

        // Navigate back
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorCreatingCampaign(e.toString())),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Helper function to convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
