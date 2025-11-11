import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/article_local_datasource.dart';
import '../data/datasources/article_remote_datasource.dart';
import '../data/repositories/article_repository_impl.dart';
import '../data/services/html_fetch_service.dart';
import '../domain/repositories/article_repository.dart';
import '../domain/usecases/get_articles.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // HTTP client
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Data sources
  getIt.registerLazySingleton<ArticleLocalDataSource>(() => ArticleLocalDataSourceImpl());
  getIt.registerLazySingleton<ArticleRemoteDataSource>(() => ArticleRemoteDataSourceImpl(getIt<Dio>()));

  // Services
  getIt.registerLazySingleton<HtmlFetchService>(() => HtmlFetchService(getIt<http.Client>()));

  // Repositories
  getIt.registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl(
    getIt<ArticleRemoteDataSource>(),
    getIt<ArticleLocalDataSource>(),
  ));

  // Use cases
  getIt.registerLazySingleton<GetArticles>(() => GetArticles(getIt<ArticleRepository>()));
}
