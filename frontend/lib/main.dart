import 'package:flutter/material.dart';
import 'package:frontend/model/Task.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/provider/DeveloperModel.dart';
import 'package:frontend/provider/NotificationModel.dart';
import 'package:frontend/provider/ProjectModel.dart';
import 'package:frontend/provider/TaskModel.dart';
import 'package:frontend/view/AddSubtaskView.dart';
import 'package:frontend/view/AddTasksView.dart';
import 'package:frontend/view/ApprovalListView.dart';
import 'package:frontend/view/DashboardView.dart';
import 'package:frontend/view/EditProjectView.dart';
import 'package:frontend/view/ListTasksView.dart';
import 'package:frontend/view/SubtasksView.dart';
import 'package:frontend/view/createProjectView.dart';
import 'package:frontend/view/signUpPage.dart';
import 'package:frontend/widget/ListProjectWidget.dart';
import 'package:provider/provider.dart';

class AppColors {
  // Primaires
  static const Color navyDark = Color(0xFF0A2540);
  static const Color navyMid = Color(0xFF063060);
  static const Color blue = Color(0xFF1868DB);
  static const Color blueDark = Color(0xFF0052CC);
  static const Color blueLight = Color(0xFF6BA3F5);

  // Surfaces
  static const Color background = Color(0xFFF4F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF8F9FF);

  // Bordures
  static const Color border = Color(0xFFDFE1E6);
  static const Color borderLight = Color(0xFFF4F5F7);

  // Texte
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF5E6C84);
  static const Color textMuted = Color(0xFF8993A4);
  static const Color textNavy = Color(0xFFC8D8EE);
  static const Color textNavyMuted = Color(0xFF8BA4C4);

  // Statuts
  static const Color successBg = Color(0xFFE3FCEF);
  static const Color successText = Color(0xFF006644);
  static const Color warningBg = Color(0xFFFFF0B3);
  static const Color warningText = Color(0xFF172B4D);
  static const Color errorBg = Color(0xFFFFEBE6);
  static const Color errorText = Color(0xFFBF2600);
  static const Color infoBg = Color(0xFFE9F2FF);
  static const Color infoText = Color(0xFF0052CC);

  // Accents projets
  static const Color accent1 = Color(0xFF1868DB);
  static const Color accent2 = Color(0xFF0065FF);
  static const Color accent3 = Color(0xFF6554C0);
  static const Color accent4 = Color(0xFF00875A);
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskModel()),
        ChangeNotifierProvider(create: (_) => NotificationModel()),
        ChangeNotifierProvider(create: (_) => ProjectModel()),
        ChangeNotifierProvider(create: (_) => DeveloperModel()),
        ChangeNotifierProvider(
            create: (_) => User(
                  idUtilisateur: '', //a default value
                  nomUtilisateur: '',
                  email: '',
                  role: Role.Developer,
                )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoftwareDevelopmentProjectsManager',
      theme: _buildTheme(),
      routes: {
        "ListTasks": (context) => ListTasksView(),
        "/approvalList": (context) => ApprovalListView(),
        "dashboardView": (context) => DashboardView(),
        "EditProject": (context) => EditProjectView(
            projectId: ModalRoute.of(context)!.settings.arguments as String),
        "addTasks": (context) => AddTasksView(),
        "ListProjects": (context) => ListProjectsWidget(),
        "CreateProject": (context) => CreateProjectView(),
        'viewTaskDetails': (context) => SubtasksView(
              task: ModalRoute.of(context)!.settings.arguments as Task,
            ),
        'addSubtask': (context) {
          final Task task = ModalRoute.of(context)!.settings.arguments as Task;
          return AddSubtaskView(task: task);
        },
      },
      home: Builder(
        builder: (context) {
          final developerModel =
              Provider.of<DeveloperModel>(context, listen: true);
          if (developerModel.user.token == null ||
              developerModel.user.token!.isEmpty) {
            return const SignupPage();
          }

          // Safely access the token
          return developerModel.user.token!.isEmpty
              ? const SignupPage()
              : ListProjectsWidget();
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Segoe UI',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 18),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: const EdgeInsets.only(bottom: 8),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        side: const BorderSide(color: AppColors.blue, width: 1.5),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navyDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        behavior: SnackBarBehavior.floating,
      ),

      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.blue,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.blue,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 13),
      ),
    );
  }
}
