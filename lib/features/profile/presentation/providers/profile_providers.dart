// Profile Feature Providers
//
// This file contains providers specific to user profile management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/providers/infrastructure_providers.dart';
import 'package:promoruta/features/profile/data/datasources/local/user_local_data_source.dart';
import 'package:promoruta/features/profile/data/datasources/remote/user_remote_data_source.dart';
import 'package:promoruta/features/profile/data/repositories/user_repository_impl.dart';
import 'package:promoruta/features/profile/domain/repositories/user_repository.dart'
    hide UserLocalDataSource, UserRemoteDataSource;

// ============ Data Sources ============

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return UserLocalDataSourceImpl(database);
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDataSourceImpl(dio: dio);
});

// ============ Repository ============

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final authLocalDataSource = ref.watch(authLocalDataSourceProvider);

  return UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    authLocalDataSource: authLocalDataSource,
  );
});
