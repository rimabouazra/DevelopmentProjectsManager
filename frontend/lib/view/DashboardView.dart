import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, int> _stats = {
    'assigned': 0, 'in-progress': 0, 'completed': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-access-token') ?? '';
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/dashboard/projects'),
        headers: {'x-access-token': token},
      ).timeout(AppConfig.requestTimeout);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        final map = <String, int>{
          'assigned': 0, 'in-progress': 0, 'completed': 0};
        for (final s in data) {
          map[s['_id']] = s['count'];
        }
        setState(() { _stats = map; _loading = false; });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rapports & Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () {
              setState(() => _loading = true);
              _fetchStats();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vue d\'ensemble des projets',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Total : $total projet${total > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 20),

                  // KPI row
                  Row(children: [
                    _KpiCard(
                      label: 'Total projets',
                      value: '$total',
                      icon: Icons.folder_rounded,
                      color: AppColors.blue,
                      bg: AppColors.infoBg,
                    ),
                    const SizedBox(width: 12),
                    _KpiCard(
                      label: 'En cours',
                      value: '${_stats['in-progress']}',
                      icon: Icons.play_circle_rounded,
                      color: AppColors.successText,
                      bg: AppColors.successBg,
                    ),
                    const SizedBox(width: 12),
                    _KpiCard(
                      label: 'Assignés',
                      value: '${_stats['assigned']}',
                      icon: Icons.assignment_rounded,
                      color: AppColors.blue,
                      bg: AppColors.infoBg,
                    ),
                    const SizedBox(width: 12),
                    _KpiCard(
                      label: 'Terminés',
                      value: '${_stats['completed']}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.textMuted,
                      bg: AppColors.background,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Tableau récapitulatif
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: const Border.fromBorderSide(
                        BorderSide(color: AppColors.border, width: 0.5)),
                    ),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                        child: const Row(children: [
                          Expanded(child: Text('STATUT',
                              style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                                letterSpacing: 0.05))),
                          Text('NOMBRE',
                              style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                                letterSpacing: 0.05)),
                        ]),
                      ),
                      const Divider(height: 0.5),
                      _StatRow(
                        label: 'Projets assignés',
                        value: _stats['assigned'] ?? 0,
                        color: AppColors.blue,
                        icon: Icons.assignment_rounded,
                      ),
                      const Divider(height: 0.5, indent: 16),
                      _StatRow(
                        label: 'Projets en cours',
                        value: _stats['in-progress'] ?? 0,
                        color: AppColors.successText,
                        icon: Icons.play_circle_rounded,
                      ),
                      const Divider(height: 0.5, indent: 16),
                      _StatRow(
                        label: 'Projets terminés',
                        value: _stats['completed'] ?? 0,
                        color: AppColors.textMuted,
                        icon: Icons.check_circle_rounded,
                      ),
                    ]),
                  ),

                  if (total > 0) ...[
                    const SizedBox(height: 24),
                    const Text('Répartition',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _ProgressSection(
                      label: 'En cours',
                      value: _stats['in-progress'] ?? 0,
                      total: total,
                      color: AppColors.successText,
                    ),
                    const SizedBox(height: 10),
                    _ProgressSection(
                      label: 'Assignés',
                      value: _stats['assigned'] ?? 0,
                      total: total,
                      color: AppColors.blue,
                    ),
                    const SizedBox(height: 10),
                    _ProgressSection(
                      label: 'Terminés',
                      value: _stats['completed'] ?? 0,
                      total: total,
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  const _KpiCard({
    required this.label, required this.value,
    required this.icon, required this.color, required this.bg,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 12),
        Text(value,
            style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 3),
        Text(label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9, color: AppColors.textMuted,
              letterSpacing: 0.04, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatRow({
    required this.label, required this.value,
    required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Text(label,
          style: const TextStyle(
            fontSize: 13, color: AppColors.textPrimary))),
      Container(
        width: 32, height: 24,
        decoration: BoxDecoration(
          color: AppColors.infoBg,
          borderRadius: BorderRadius.circular(4)),
        child: Center(child: Text('$value',
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.infoText))),
      ),
    ]),
  );
}

class _ProgressSection extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  const _ProgressSection({
    required this.label, required this.value,
    required this.total, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Row(children: [
      SizedBox(width: 80,
          child: Text(label,
              style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary))),
      const SizedBox(width: 12),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      )),
      const SizedBox(width: 10),
      Text('${(pct * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 11, color: AppColors.textMuted,
            fontWeight: FontWeight.w500)),
    ]);
  }
}