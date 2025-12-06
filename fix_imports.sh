#!/bin/bash

echo "Fixing all import statements for feature-first architecture..."

BASE_DIR="D:/WORK/PROYECTOS/FLUTTER/Promo/code/promoruta_mobile"
cd "$BASE_DIR"

# ============================================================================
# CAMPAIGN MANAGEMENT FEATURE
# ============================================================================
echo "Fixing campaign management imports..."

# Fix campaign_local_data_source.dart
sed -i 's|../../repositories/campaign_repository.dart|../../domain/repositories/campaign_repository.dart|g' \
  lib/features/advertiser/campaign_management/data/datasources/local/campaign_local_data_source.dart

# Fix campaign_remote_data_source.dart
sed -i 's|../../../core/models/campaign.dart|../../../../../core/models/campaign.dart|g' \
  lib/features/advertiser/campaign_management/data/datasources/remote/campaign_remote_data_source.dart
sed -i 's|../../repositories/campaign_repository.dart|../../domain/repositories/campaign_repository.dart|g' \
  lib/features/advertiser/campaign_management/data/datasources/remote/campaign_remote_data_source.dart

# Fix campaign_repository_impl.dart
sed -i '1i import '\''package:promoruta/core/models/campaign.dart'\'';' \
  lib/features/advertiser/campaign_management/data/repositories/campaign_repository_impl.dart
sed -i 's|package:promoruta/shared/shared.dart|package:promoruta/shared/shared.dart|g' \
  lib/features/advertiser/campaign_management/data/repositories/campaign_repository_impl.dart

# Fix campaign_use_cases.dart
sed -i '1i import '\''package:promoruta/core/models/campaign.dart'\'';' \
  lib/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart
sed -i '2i import '\''../repositories/campaign_repository.dart'\'';' \
  lib/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart

# Fix campaign_mappers.dart
sed -i '1i import '\''package:promoruta/core/models/campaign.dart'\'';' \
  lib/features/advertiser/campaign_management/data/models/campaign_mappers.dart
sed -i 's|campaign_ui.dart|../../presentation/models/campaign_ui.dart|g' \
  lib/features/advertiser/campaign_management/data/models/campaign_mappers.dart

# ============================================================================
# GPS TRACKING FEATURE
# ============================================================================
echo "Fixing GPS tracking imports..."

# Fix gps_local_data_source.dart
sed -i 's|../../../core/models/gps_point.dart|../../../../../core/models/gps_point.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart
sed -i 's|../../../core/models/route.dart|../../../../../core/models/route.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart
sed -i 's|../../repositories/gps_repository.dart|../../domain/repositories/gps_repository.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart
sed -i 's|db/database.dart|../../../../../shared/datasources/local/db/database.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart

# Fix gps_remote_data_source.dart
sed -i 's|../../../core/models/gps_point.dart|../../../../../core/models/gps_point.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart
sed -i 's|../../repositories/gps_repository.dart|../../domain/repositories/gps_repository.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart

# Fix gps_repository_impl.dart
sed -i '1i import '\''package:promoruta/core/models/gps_point.dart'\'';' \
  lib/features/promotor/gps_tracking/data/repositories/gps_repository_impl.dart
sed -i '2i import '\''package:promoruta/core/models/route.dart'\'' as route_model;' \
  lib/features/promotor/gps_tracking/data/repositories/gps_repository_impl.dart

# ============================================================================
# MEDIA / CAMPAIGN CREATION
# ============================================================================
echo "Fixing media/campaign creation imports..."

# Fix media_repository.dart
sed -i 's|package:promoruta/shared/datasources/remote/media_remote_data_source.dart|../data/datasources/remote/media_remote_data_source.dart|g' \
  lib/features/advertiser/campaign_creation/domain/repositories/media_repository.dart

# Fix create_campaign_page.dart
sed -i 's|package:promoruta/shared/datasources/remote/media_remote_data_source.dart|../../data/datasources/remote/media_remote_data_source.dart|g' \
  lib/features/advertiser/campaign_creation/presentation/pages/create_campaign_page.dart

# ============================================================================
# ADVERTISER PRESENTATION
# ============================================================================
echo "Fixing advertiser presentation imports..."

# Fix advertiser_home_screen.dart
sed -i 's|package:promoruta/shared/widgets/advertiser_app_bar.dart|../widgets/advertiser_app_bar.dart|g' \
  lib/features/advertiser/presentation/pages/advertiser_home_screen.dart

# Fix pages that import campaign management
find lib/features/advertiser/campaign_management/presentation/pages -name "*.dart" -exec \
  sed -i 's|package:promoruta/shared/models/campaign_mappers.dart|../../data/models/campaign_mappers.dart|g' {} \;

# ============================================================================
# PROFILE FEATURE
# ============================================================================
echo "Fixing profile imports..."

# Fix profile.dart barrel file - remove duplicate export
cat > lib/features/profile/profile.dart << 'EOFPROFILE'
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
export 'presentation/pages/two_factor_auth_page.dart';
export 'presentation/widgets/profile_widgets.dart';
EOFPROFILE

echo "Import fixes complete!"
echo "Run 'flutter analyze' to check for remaining issues"
