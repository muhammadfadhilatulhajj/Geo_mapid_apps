import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/geo_feature_entity.dart';

class FeatureDetailSheet extends StatefulWidget {
  final GeoFeatureEntity feature;
  final VoidCallback? onClose;

  const FeatureDetailSheet({
    super.key,
    required this.feature,
    this.onClose,
  });

  @override
  State<FeatureDetailSheet> createState() => _FeatureDetailSheetState();
}

class _FeatureDetailSheetState extends State<FeatureDetailSheet> {
  int _activeTabIndex = 0; // 0: Ringkasan & Atribut, 1: Raw JSON Tree

  @override
  Widget build(BuildContext context) {
    final feature = widget.feature;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(45),
            blurRadius: 36,
            offset: const Offset(0, 10),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header: Category Pill, Live Tag & Action Close
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            feature.district.isNotEmpty
                                ? 'Kec. ${feature.district}'
                                : 'Destinasi Terverifikasi',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        feature.village.isNotEmpty
                            ? feature.village
                            : 'Wisata Budaya',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: const Color(0xFFF1F5F9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onClose ??
                            () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 17,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Object Title & Verified checkmark
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Icon(
                        Icons.place_rounded,
                        color: Color(0xFF059669),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Modern Segmented Tab Bar (Atribut Terstruktur vs Raw JSON)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _activeTabIndex = 0);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _activeTabIndex == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTabIndex == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.view_list_rounded,
                                  size: 15,
                                  color: _activeTabIndex == 0
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Atribut Lengkap',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _activeTabIndex == 0
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: _activeTabIndex == 0
                                        ? const Color(0xFF065F46)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _activeTabIndex = 1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _activeTabIndex == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTabIndex == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.data_object_rounded,
                                  size: 15,
                                  color: _activeTabIndex == 1
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Raw GeoJSON',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _activeTabIndex == 1
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: _activeTabIndex == 1
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Body Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: _activeTabIndex == 0
                  ? _buildStructuredAttributesView(feature)
                  : _buildRawJsonView(feature),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Structured and beautifully styled attribute cards
  Widget _buildStructuredAttributesView(GeoFeatureEntity feature) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Action Bar: Rute Cepat, Salin Koordinat & Bagikan
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigasi ke ${feature.name}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.turn_right_rounded, size: 18),
                label: const Text(
                  'Rute Cepat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                icon: const Icon(Icons.share_outlined, size: 18),
                color: const Color(0xFF475569),
                onPressed: () => HapticFeedback.lightImpact(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Section: Informasi Spasial & Geometri
        _buildSectionHeader('INFORMASI SPASIAL & GEOMETRI', Icons.map_outlined),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildFieldRow(
                icon: Icons.my_location_rounded,
                label: 'Koordinat (Latitude, Longitude)',
                value:
                    '${feature.latitude.toStringAsFixed(7)}, ${feature.longitude.toStringAsFixed(7)}',
                color: const Color(0xFF059669),
                isMonospace: true,
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildFieldRow(
                icon: Icons.public_rounded,
                label: 'Sistem Referensi Koordinat',
                value: 'WGS 84 (EPSG:4326)',
                color: const Color(0xFF475569),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Section: Properti Wilayah Administratif
        _buildSectionHeader(
            'WILAYAH ADMINISTRATIF & ALAMAT', Icons.apartment_rounded),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildFieldRow(
                icon: Icons.signpost_rounded,
                label: 'Alamat Lengkap',
                value: feature.address,
                color: const Color(0xFF0D9488),
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFieldRow(
                      icon: Icons.holiday_village_rounded,
                      label: 'Kelurahan / Desa',
                      value: feature.village,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Expanded(
                    child: _buildFieldRow(
                      icon: Icons.location_city_rounded,
                      label: 'Kecamatan',
                      value: feature.district,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFieldRow(
                      icon: Icons.account_balance_rounded,
                      label: 'Kota / Kabupaten',
                      value: feature.regencyCity,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Expanded(
                    child: _buildFieldRow(
                      icon: Icons.domain_rounded,
                      label: 'Provinsi',
                      value: feature.province,
                      color: const Color(0xFFDB2777),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Section: Metadata Kontributor & Update
        _buildSectionHeader(
            'METADATA & KONTRIBUTOR DATA', Icons.verified_user_rounded),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildFieldRow(
                icon: Icons.person_rounded,
                label: 'Dibuat Oleh Kontributor',
                value:
                    '${feature.contributorFullName} (${feature.contributorName})',
                color: const Color(0xFF059669),
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildFieldRow(
                icon: Icons.calendar_today_rounded,
                label: 'Periode / Waktu Data',
                value: feature.period,
                color: const Color(0xFFEA580C),
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 16),
              _buildFieldRow(
                icon: Icons.fingerprint_rounded,
                label: 'User ID Kontributor',
                value: feature.contributorId,
                color: const Color(0xFF64748B),
                isMonospace: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 2: Formatted and Colorized Raw GeoJSON Viewer with copy button
  Widget _buildRawJsonView(GeoFeatureEntity feature) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(feature.fullJson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payload Objek Feature GeoJSON:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                HapticFeedback.selectionClick();
                Clipboard.setData(ClipboardData(text: prettyJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh JSON fitur berhasil disalin!'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded,
                        size: 13, color: Color(0xFF2563EB)),
                    SizedBox(width: 4),
                    Text(
                      'Salin Semua JSON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: SelectableText(
            prettyJson,
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 11.5,
              fontFamily: 'monospace',
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                  fontFamily: isMonospace ? 'monospace' : null,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
