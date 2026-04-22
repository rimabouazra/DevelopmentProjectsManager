import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/ProjectTasksView.dart';
import 'package:provider/provider.dart';

class ListProjectsWidget extends StatefulWidget {
  const ListProjectsWidget({super.key});
  @override
  State<ListProjectsWidget> createState() => _ListProjectsWidgetState();
}

class _ListProjectsWidgetState extends State<ListProjectsWidget> {
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserRole();
      final pm = Provider.of<ProjectModel>(context, listen: false);
      if (pm.projects.isEmpty) {
        pm.fetchProjects();
      }
    });
  }

  void _fetchUserRole() {
    if (!mounted) return;
    final dev = Provider.of<DeveloperModel>(context, listen: false);
    setState(() => _userRole = dev.user.role.toString());
  }

  // ── couleur accent par index ─────────────────────────────────────────────
  Color _accentColor(int i) {
    const colors = [
      AppColors.accent1,
      AppColors.accent2,
      AppColors.accent3,
      AppColors.accent4,
    ];
    return colors[i % colors.length];
  }

  // ── badge statut ─────────────────────────────────────────────────────────
  Widget _statusBadge(String status) {
    Color bg; Color fg; String label;
    switch (status) {
      case 'in-progress':
        bg = AppColors.successBg; fg = AppColors.successText;
        label = 'En cours'; break;
      case 'completed':
        bg = AppColors.infoBg; fg = AppColors.infoText;
        label = 'Terminé'; break;
      default:
        bg = AppColors.infoBg; fg = AppColors.infoText;
        label = 'Assigné';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(label.toUpperCase(),
          style: TextStyle(
            color: fg, fontSize: 9,
            fontWeight: FontWeight.w500, letterSpacing: 0.04)),
    );
  }

  // ── confirmation suppression ─────────────────────────────────────────────
  Future<void> _confirmDelete(String projectId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border, width: 0.5)),
        title: const Text('Supprimer le projet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        content: const Text(
            'Cette action est irréversible. Toutes les tâches associées seront supprimées.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorText),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        await Provider.of<ProjectModel>(context, listen: false)
            .deleteProject(projectId);
        Provider.of<TaskModel>(context, listen: false)
            .removeTasksForProject(projectId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projet supprimé avec succès')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // ── Sidebar ───────────────────────────────────────────────────────
      _Sidebar(userRole: _userRole),

      // ── Contenu principal ─────────────────────────────────────────────
      Expanded(
        child: Consumer<ProjectModel>(
          builder: (context, model, _) {
            if (model.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.blue));
            }
            if (model.errorMessage.isNotEmpty && model.projects.isEmpty) {
              return _EmptyState(
                onCreateProject: _userRole == 'Role.Manager'
                    ? () => Navigator.pushNamed(context, 'CreateProject')
                    : null,
              );
            }

            // ── KPI ──────────────────────────────────────────────────────
            final total    = model.projects.length;
            final inProg   = model.projects
                .where((p) => p.status == 'in-progress').length;
            final done     = model.projects
                .where((p) => p.status == 'completed').length;

            return Container(
              color: AppColors.background,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Vue d\'ensemble',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      )),
                                  Text('$total projet${total > 1 ? 's' : ''} actif${total > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      )),
                                ],
                              ),
                              if (_userRole == 'Role.Manager')
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                      context, 'CreateProject'),
                                  icon: const Icon(Icons.add, size: 14),
                                  label: const Text('Nouveau projet'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // KPI
                          Row(children: [
                            _KpiCard(num: total,  label: 'Projets',    color: AppColors.blue),
                            const SizedBox(width: 10),
                            _KpiCard(num: inProg, label: 'En cours',   color: AppColors.successText),
                            const SizedBox(width: 10),
                            _KpiCard(num: done,   label: 'Terminés',   color: AppColors.textMuted),
                            const SizedBox(width: 10),
                            _KpiCard(
                              num: model.projects
                                  .fold(0, (s, p) => s + p.developers.length),
                              label: 'Membres',
                              color: AppColors.accent3,
                            ),
                          ]),
                          const SizedBox(height: 24),

                          // Liste projets
                          ...model.projects.asMap().entries.map((entry) {
                            final i = entry.key;
                            final p = entry.value;
                            return _ProjectRow(
                              project: p,
                              accent: _accentColor(i),
                              statusBadge: _statusBadge(p.status ?? 'assigned'),
                              isManager: _userRole == 'Role.Manager',
                              onView: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => Scaffold(
                                  appBar: AppBar(title: Text(p.title)),
                                  body: ProjectTasksView(projectId: p.projectId),
                                ))),
                              onEdit: () => Navigator.pushNamed(context,
                                'EditProject', arguments: p.projectId),
                              onDelete: () => _confirmDelete(p.projectId),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final String userRole;
  const _Sidebar({required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 4),
            child: Text('NAVIGATION',
                style: TextStyle(
                  fontSize: 10, color: AppColors.textMuted,
                  fontWeight: FontWeight.w500, letterSpacing: 0.06)),
          ),
          _SideItem(
            icon: Icons.dashboard_rounded,
            label: 'Tableau de bord',
            active: true,
            onTap: () {},
          ),
          _SideItem(
            icon: Icons.folder_rounded,
            label: 'Mes projets',
            onTap: () {},
          ),
          _SideItem(
            icon: Icons.check_circle_outline_rounded,
            label: 'Mes tâches',
            onTap: () {},
          ),
          _SideItem(
            icon: Icons.people_outline_rounded,
            label: 'Équipe',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 4),
            child: Text('ADMINISTRATION',
                style: TextStyle(
                  fontSize: 10, color: AppColors.textMuted,
                  fontWeight: FontWeight.w500, letterSpacing: 0.06)),
          ),
          if (userRole == 'Role.Administrator')
            _SideItem(
              icon: Icons.how_to_reg_rounded,
              label: 'Approbations',
              onTap: () => Navigator.pushNamed(context, '/approvalList'),
            ),
          _SideItem(
            icon: Icons.bar_chart_rounded,
            label: 'Rapports',
            onTap: () => Navigator.pushNamed(context, 'dashboardView'),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SideItem({
    required this.icon, required this.label,
    this.active = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.infoBg : Colors.transparent,
          border: active
              ? const Border(left: BorderSide(color: AppColors.blue, width: 2))
              : null,
        ),
        child: Row(children: [
          Icon(icon,
            size: 14,
            color: active ? AppColors.blueDark : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: active ? AppColors.blueDark : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w500 : FontWeight.normal,
              )),
        ]),
      ),
    );
  }
}

// ─── Ligne projet ─────────────────────────────────────────────────────────────

class _ProjectRow extends StatefulWidget {
  final Project project;
  final Color accent;
  final Widget statusBadge;
  final bool isManager;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProjectRow({
    required this.project, required this.accent,
    required this.statusBadge, required this.isManager,
    required this.onView, required this.onEdit, required this.onDelete,
  });
  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool _hovered = false;

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  // Calcul progression basique
  double get _progress {
    switch (widget.project.status) {
      case 'completed':  return 1.0;
      case 'in-progress': return 0.45;
      default:           return 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _hovered ? AppColors.blue : AppColors.border,
            width: _hovered ? 1.0 : 0.5,
          ),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: AppColors.blue.withOpacity(0.08),
                  blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: InkWell(
          onTap: widget.onView,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              // Barre couleur
              Container(
                width: 4, height: 48,
                decoration: BoxDecoration(
                  color: widget.accent,
                  borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 14),

              // Infos projet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 3),
                    Text(
                      'Manager : ${p.manager?.nomUtilisateur ?? '—'}'
                      ' · ${p.developers.length} développeur${p.developers.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Avatars développeurs
              SizedBox(
                width: p.developers.length * 18.0 + 6,
                height: 26,
                child: Stack(
                  children: p.developers.take(3).toList().asMap().entries.map((e) {
                    final colors = [
                      AppColors.accent1, AppColors.accent2,
                      AppColors.accent3, AppColors.accent4,
                    ];
                    return Positioned(
                      left: e.key * 16.0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          shape: BoxShape.circle,
                          border: const Border.fromBorderSide(
                            BorderSide(color: AppColors.surface, width: 1.5)),
                        ),
                        child: Center(
                          child: Text(_initials(e.value.nomUtilisateur),
                              style: const TextStyle(
                                color: Colors.white, fontSize: 8,
                                fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),

              // Progression
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 3,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.accent),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Badge statut
              widget.statusBadge,

              // Actions manager
              if (widget.isManager) ...[
                const SizedBox(width: 12),
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  onTap: widget.onEdit,
                  tooltip: 'Modifier',
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  onTap: widget.onDelete,
                  tooltip: 'Supprimer',
                  danger: true,
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool danger;
  const _ActionBtn({
    required this.icon, required this.onTap,
    required this.tooltip, this.danger = false,
  });
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon,
          size: 16,
          color: danger ? AppColors.errorText : AppColors.textMuted),
      ),
    ),
  );
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final int num;
  final String label;
  final Color color;
  const _KpiCard({required this.num, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(children: [
        Text('$num',
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

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback? onCreateProject;
  const _EmptyState({this.onCreateProject});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.infoBg,
          borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.folder_open_rounded,
            color: AppColors.blue, size: 32),
      ),
      const SizedBox(height: 16),
      const Text('Aucun projet',
          style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('Créez votre premier projet pour commencer.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      if (onCreateProject != null) ...[
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onCreateProject,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Créer un projet'),
        ),
      ],
    ]),
  );
}