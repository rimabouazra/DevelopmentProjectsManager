import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/widget/ListProjectWidget.dart';
import 'package:frontend/widget/ListTaskWidget.dart';
import 'package:provider/provider.dart';

class ListTasksView extends StatefulWidget {
  final String? projectId;
  const ListTasksView({super.key, this.projectId});
  @override
  State<ListTasksView> createState() => _ListTasksViewState();
}

class _ListTasksViewState extends State<ListTasksView>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    // ── Chargement des données au démarrage ───────────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pm = Provider.of<ProjectModel>(context, listen: false);
      final tm = Provider.of<TaskModel>(context, listen: false);
      await pm.fetchProjects();
      if (pm.projects.isNotEmpty) {
        await tm.fetchTasksForAllProjects(pm.getProjectIds());
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _signOut() => AuthHelper().signOut(context);

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dev = Provider.of<DeveloperModel>(context, listen: false);
    final userName = dev.user.nomUtilisateur;
    final userInitials = _initials(userName);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // ── Barre de navigation ────────────────────────────────────────────
        _TopBar(
          tab: _tab,
          userInitials: userInitials,
          userName: userName,
          onSignOut: _signOut,
        ),

        // ── Contenu ────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ListProjectsWidget(),
              ListTasksWidget(projectId: widget.projectId),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Barre de navigation supérieure ──────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final TabController tab;
  final String userInitials;
  final String userName;
  final VoidCallback onSignOut;

  const _TopBar({
    required this.tab,
    required this.userInitials,
    required this.userName,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.navyDark,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ── Logo ────────────────────────────────────────────────────────
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.layers_rounded,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          const Text(
            'DevManager',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 20),

          // ── Onglets ─────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: tab,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavTab(label: 'Projets', index: 0, tab: tab),
                _NavTab(label: 'Tâches',  index: 1, tab: tab),
              ],
            ),
          ),

          // ── Espace flexible ─────────────────────────────────────────────
          const Spacer(),

          // ── Chip utilisateur ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                  color: Colors.white.withOpacity(0.1), width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.blue, shape: BoxShape.circle),
                  child: Center(
                    child: Text(userInitials,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 8,
                          fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 6),
                // Prénom seulement, tronqué si nécessaire
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 80),
                  child: Text(
                    userName.split(' ').first,
                    style: const TextStyle(
                      color: AppColors.textNavy, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Déconnexion ─────────────────────────────────────────────────
          Tooltip(
            message: 'Se déconnecter',
            child: InkWell(
              onTap: onSignOut,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1), width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.textNavyMuted, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Onglet de navigation ────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final String label;
  final int index;
  final TabController tab;
  const _NavTab({
    required this.label, required this.index, required this.tab});

  @override
  Widget build(BuildContext context) {
    final active = tab.index == index;
    return GestureDetector(
      onTap: () => tab.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: active
              ? AppColors.blue.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
              color: active
                  ? AppColors.blueLight
                  : AppColors.textNavyMuted,
              fontSize: 12,
              fontWeight: active ? FontWeight.w500 : FontWeight.normal,
            )),
      ),
    );
  }
}