import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/model/Project.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/NotificationModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:provider/provider.dart';
import 'package:frontend/model/Notification.dart' as N;

class ListTasksWidget extends StatefulWidget {
  final String? projectId;
  const ListTasksWidget({super.key, this.projectId});
  @override
  State<ListTasksWidget> createState() => _ListTasksWidgetState();
}

class _ListTasksWidgetState extends State<ListTasksWidget> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pm = Provider.of<ProjectModel>(context, listen: false);
      final tm = Provider.of<TaskModel>(context, listen: false);
      pm.fetchProjects().then((_) {
        tm.fetchTasksForAllProjects(pm.getProjectIds());
      });
    });
  }

  // ── Badge priorité ───────────────────────────────────────────────────────
  Widget _prioIndicator(bool completed, DateTime deadline) {
    if (completed) return _dot(AppColors.textMuted);
    final diff = deadline.difference(DateTime.now()).inDays;
    if (diff < 0)  return _dot(AppColors.errorText);
    if (diff < 3)  return _dot(const Color(0xFFFF8B00));
    return _dot(AppColors.blue);
  }

  Widget _dot(Color c) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  // ── Chip date ────────────────────────────────────────────────────────────
  Widget _dateChip(DateTime d, bool done) {
    if (done) return const SizedBox.shrink();
    final diff = d.difference(DateTime.now()).inDays;
    Color bg; Color fg;
    if (diff < 0)      { bg = AppColors.errorBg;   fg = AppColors.errorText; }
    else if (diff < 3) { bg = AppColors.warningBg;  fg = AppColors.warningText; }
    else               { bg = AppColors.successBg;  fg = AppColors.successText; }
    final label = '${d.day.toString().padLeft(2, '0')}/'
                  '${d.month.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500)),
    );
  }

  // ── Chip statut ──────────────────────────────────────────────────────────
  Widget _statusChip(bool done, bool inProg) {
    if (done)   return _chip('Terminé',   AppColors.successBg, AppColors.successText);
    if (inProg) return _chip('En cours',  AppColors.successBg, AppColors.successText);
    return        _chip('À faire',        AppColors.infoBg,    AppColors.infoText);
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(3)),
    child: Text(label.toUpperCase(),
        style: TextStyle(
          fontSize: 9, color: fg,
          fontWeight: FontWeight.w500, letterSpacing: 0.04)),
  );

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<DeveloperModel>(context, listen: false)
        .user.idUtilisateur;

    return Consumer2<ProjectModel, TaskModel>(
      builder: (context, pm, tm, _) {
        final allByProject = Map<String, dynamic>.from(tm.tasksByProject);

        if (allByProject.isEmpty) {
          return const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.textMuted, size: 48),
              SizedBox(height: 12),
              Text('Aucune tâche disponible',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ]));
        }

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
                              const Text('Toutes les tâches',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                              Text(
                                '${allByProject.values.fold<int>(0, (s, l) => s + (l as List).length)} tâches au total',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                            ]),
                          ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, 'addTasks'),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Ajouter une tâche'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filtres
                      Row(children: [
                        _FilterChip(
                          label: 'Toutes', value: 'all',
                          selected: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all')),
                        _FilterChip(
                          label: 'En cours', value: 'progress',
                          selected: _filter == 'progress',
                          onTap: () => setState(() => _filter = 'progress')),
                        _FilterChip(
                          label: 'Terminées', value: 'done',
                          selected: _filter == 'done',
                          onTap: () => setState(() => _filter = 'done')),
                        _FilterChip(
                          label: 'À faire', value: 'todo',
                          selected: _filter == 'todo',
                          onTap: () => setState(() => _filter = 'todo')),
                      ]),
                      const SizedBox(height: 16),

                      // Tables par projet
                      ...allByProject.entries.map((entry) {
                        final projectId = entry.key;
                        final tasks = (entry.value as List)
                            .where((t) {
                              if (_filter == 'done')     return t.status;
                              if (_filter == 'progress') return t.isInProgress;
                              if (_filter == 'todo')     return t.isToDo;
                              return true;
                            }).toList();
                        if (tasks.isEmpty) return const SizedBox.shrink();

                        final project = pm.projects.cast<Project?>()
                            .firstWhere(
                              (p) => p?.projectId == projectId,
                              orElse: () => null);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête groupe
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(width: 8),
                                Text(project?.title ?? 'Projet inconnu',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    )),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoBg,
                                    borderRadius: BorderRadius.circular(10)),
                                  child: Text('${tasks.length}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.infoText,
                                        fontWeight: FontWeight.w500)),
                                ),
                              ]),
                            ),

                            // Table
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: const Border.fromBorderSide(
                                  BorderSide(color: AppColors.border, width: 0.5)),
                              ),
                              child: Column(children: [
                                // En-tête table
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                  child: const Row(children: [
                                    SizedBox(width: 28),
                                    Expanded(child: Text('TÂCHE',
                                        style: TextStyle(
                                          fontSize: 9, fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.05))),
                                    SizedBox(width: 120, child: Text('ASSIGNÉ À',
                                        style: TextStyle(
                                          fontSize: 9, fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.05))),
                                    SizedBox(width: 60, child: Text('PRIORITÉ',
                                        style: TextStyle(
                                          fontSize: 9, fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.05))),
                                    SizedBox(width: 70, child: Text('ÉCHÉANCE',
                                        style: TextStyle(
                                          fontSize: 9, fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.05))),
                                    SizedBox(width: 80, child: Text('STATUT',
                                        style: TextStyle(
                                          fontSize: 9, fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.05))),
                                    SizedBox(width: 60),
                                  ]),
                                ),
                                const Divider(height: 0.5),

                                // Lignes tâches
                                ...tasks.asMap().entries.map((te) {
                                  final idx  = te.key;
                                  final task = te.value;
                                  final isLast = idx == tasks.length - 1;
                                  return Column(children: [
                                    _TaskRow(
                                      task: task,
                                      initials: task.developerNames.isNotEmpty
                                          ? _initials(task.developerNames.first)
                                          : '??',
                                      prioIndicator: _prioIndicator(
                                          task.status, task.deadline),
                                      dateChip: _dateChip(
                                          task.deadline, task.status),
                                      statusChip: _statusChip(
                                          task.status, task.isInProgress),
                                      onCheck: () {
                                        final tasks2 = tm.tasksByProject[projectId]!;
                                        tm.markAsDone(projectId, tasks2.indexOf(task));
                                        final notif = N.Notification(
                                          id: UniqueKey().toString(),
                                          message: 'Tâche "${task.title}" mise à jour',
                                          userId: userId,
                                          timestamp: DateTime.now(),
                                        );
                                        Provider.of<NotificationModel>(
                                            context, listen: false)
                                            .addNotification(userId, notif.message);
                                      },
                                      onStatusChange: (s) {
                                        setState(() {
                                          if (s == 'todo') {
                                            task.isToDo = true;
                                            task.isInProgress = false;
                                            task.status = false;
                                          } else if (s == 'progress') {
                                            task.isToDo = false;
                                            task.isInProgress = true;
                                            task.status = false;
                                          } else {
                                            task.isToDo = false;
                                            task.isInProgress = false;
                                            task.status = true;
                                          }
                                          tm.updateTask(task);
                                        });
                                      },
                                      onTap: () => Navigator.push(context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SubtasksView(task: task))),
                                    ),
                                    if (!isLast)
                                      const Divider(height: 0.5, indent: 14),
                                  ]);
                                }),
                              ]),
                            ),
                            const SizedBox(height: 20),
                          ],
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
    );
  }
}

// ─── Ligne de tâche ───────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final dynamic task;
  final String initials;
  final Widget prioIndicator;
  final Widget dateChip;
  final Widget statusChip;
  final VoidCallback onCheck;
  final Function(String) onStatusChange;
  final VoidCallback onTap;

  const _TaskRow({
    required this.task, required this.initials,
    required this.prioIndicator, required this.dateChip,
    required this.statusChip, required this.onCheck,
    required this.onStatusChange, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          // Checkbox
          SizedBox(width: 28,
            child: Checkbox(
              value: task.status,
              onChanged: (_) => onCheck(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),

          // Titre + sous-tâches
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: task.status
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  decoration: task.status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                )),
              if (task.subtasks.isNotEmpty)
                Text('${task.subtasks.length} sous-tâche${task.subtasks.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted)),
            ],
          )),

          // Assigné
          SizedBox(width: 120,
            child: Row(children: [
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.blue, shape: BoxShape.circle),
                child: Center(child: Text(initials,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 7,
                      fontWeight: FontWeight.w600))),
              ),
              const SizedBox(width: 6),
              Flexible(child: Text(
                task.developerNames.isNotEmpty
                    ? task.developerNames.first : '—',
                style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              )),
            ])),

          // Priorité
          SizedBox(width: 60, child: prioIndicator),

          // Échéance
          SizedBox(width: 70, child: dateChip),

          // Statut
          SizedBox(width: 80, child: statusChip),

          // Actions rapides
          SizedBox(width: 60,
            child: PopupMenuButton<String>(
              onSelected: onStatusChange,
              icon: const Icon(Icons.more_horiz,
                  size: 16, color: AppColors.textMuted),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'todo',
                    child: Text('À faire', style: TextStyle(fontSize: 12))),
                const PopupMenuItem(value: 'progress',
                    child: Text('En cours', style: TextStyle(fontSize: 12))),
                const PopupMenuItem(value: 'done',
                    child: Text('Terminé', style: TextStyle(fontSize: 12))),
              ],
            )),
        ]),
      ),
    );
  }
}

// ─── Filtre chip ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label, required this.value,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.blue : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected ? AppColors.blue : AppColors.border,
          width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          )),
    ),
  );
}