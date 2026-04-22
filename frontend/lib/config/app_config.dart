/// Configuration centrale de l'application.
/// 
/// Pour changer l'URL de l'API, modifiez uniquement ce fichier.
/// En production cloud, remplacez la valeur par l'URL de serveur.
class AppConfig {
  // ─── URL de l'API ──────────────────────────────────────────────────────────
  //
  // Développement local :
  static const String baseUrl = 'http://localhost:3000';
  //
  // Quand vous déployez sur un serveur cloud (ex: Railway, Render, AWS),
  // remplacez par : 'https://votre-app.railway.app'
  //

  // Timeouts 
  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Nom de l'application
  static const String appName = 'SoftwareDevelopmentProjectsManager';
}