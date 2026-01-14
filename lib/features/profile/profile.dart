// Profile Feature Barrel File

// Data Layer
export 'data/datasources/local/user_local_data_source.dart';
export 'data/datasources/remote/user_remote_data_source.dart';
export 'data/repositories/user_repository_impl.dart';

// Domain Layer (only export repository interface, not data source abstracts)
export 'domain/repositories/user_repository.dart' hide UserLocalDataSource, UserRemoteDataSource;

// Presentation Layer
export 'presentation/pages/user_profile_page.dart';
export 'presentation/pages/security_settings_page.dart';
export 'presentation/pages/change_password_page.dart';
export 'presentation/pages/language_settings_page.dart';
export 'presentation/widgets/profile_widgets.dart';
