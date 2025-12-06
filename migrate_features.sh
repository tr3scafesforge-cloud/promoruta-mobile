#!/bin/bash

# Full Feature Migration Script for PromoRuta Mobile
# This script migrates all remaining features to feature-first architecture

echo "Starting full feature migration..."

# Base directory
BASE_DIR="D:/WORK/PROYECTOS/FLUTTER/Promo/code/promoruta_mobile"
cd "$BASE_DIR"

# =============================================================================
# PROFILE FEATURE (Already started above, complete it)
# =============================================================================
echo "Completing profile feature migration..."

# Create profile barrel file
cat > lib/features/profile/profile.dart <<'EOF'
// Profile Feature Barrel File

// Data Layer
export 'data/datasources/local/user_local_data_source.dart';
export 'data/datasources/remote/user_remote_data_source.dart';
export 'data/repositories/user_repository_impl.dart';

// Domain Layer
export 'domain/repositories/user_repository.dart';

// Presentation Layer
export 'presentation/pages/user_profile_page.dart';
export 'presentation/pages/security_settings_page.dart';
export 'presentation/pages/change_password_page.dart';
export 'presentation/pages/language_settings_page.dart';
export 'presentation/pages/two_factor_auth_page.dart';
export 'presentation/widgets/profile_widgets.dart';
EOF

# =============================================================================
# ADVERTISER CAMPAIGN MANAGEMENT FEATURE
# =============================================================================
echo "Migrating advertiser campaign_management feature..."

# Create folder structure
mkdir -p lib/features/advertiser/campaign_management/data/datasources/local
mkdir -p lib/features/advertiser/campaign_management/data/datasources/remote
mkdir -p lib/features/advertiser/campaign_management/data/repositories
mkdir -p lib/features/advertiser/campaign_management/data/models
mkdir -p lib/features/advertiser/campaign_management/domain/repositories
mkdir -p lib/features/advertiser/campaign_management/domain/use_cases
mkdir -p lib/features/advertiser/campaign_management/presentation/pages
mkdir -p lib/features/advertiser/campaign_management/presentation/providers

# Move campaign data sources and repositories
cp lib/shared/datasources/local/campaign_local_data_source.dart \
   lib/features/advertiser/campaign_management/data/datasources/local/
cp lib/shared/datasources/remote/campaign_remote_data_source.dart \
   lib/features/advertiser/campaign_management/data/datasources/remote/
cp lib/shared/repositories/campaign_repository_impl.dart \
   lib/features/advertiser/campaign_management/data/repositories/
cp lib/shared/repositories/campaign_repository.dart \
   lib/features/advertiser/campaign_management/domain/repositories/
cp lib/shared/use_cases/campaign_use_cases.dart \
   lib/features/advertiser/campaign_management/domain/use_cases/
cp lib/shared/models/campaign_mappers.dart \
   lib/features/advertiser/campaign_management/data/models/

# Move campaign management pages
cp lib/presentation/advertiser/pages/advertiser_campaigns_page.dart \
   lib/features/advertiser/campaign_management/presentation/pages/
cp lib/presentation/advertiser/pages/advertiser_history_page.dart \
   lib/features/advertiser/campaign_management/presentation/pages/
cp lib/presentation/advertiser/pages/advertiser_live_page.dart \
   lib/features/advertiser/campaign_management/presentation/pages/

# =============================================================================
# ADVERTISER CAMPAIGN CREATION FEATURE
# =============================================================================
echo "Migrating advertiser campaign_creation feature..."

mkdir -p lib/features/advertiser/campaign_creation/data/datasources/remote
mkdir -p lib/features/advertiser/campaign_creation/data/repositories
mkdir -p lib/features/advertiser/campaign_creation/domain/repositories

# Move media data source and repository
cp lib/shared/datasources/remote/media_remote_data_source.dart \
   lib/features/advertiser/campaign_creation/data/datasources/remote/
cp lib/shared/repositories/media_repository.dart \
   lib/features/advertiser/campaign_creation/domain/repositories/

# create_campaign_page.dart already exists in the right location

# =============================================================================
# ADVERTISER ROOT
# =============================================================================
echo "Setting up advertiser root presentation..."

mkdir -p lib/features/advertiser/presentation/pages
mkdir -p lib/features/advertiser/presentation/widgets

# Move advertiser home pages
cp lib/presentation/advertiser/advertiser_home_screen.dart \
   lib/features/advertiser/presentation/pages/
cp lib/presentation/advertiser/pages/advertiser_home_page.dart \
   lib/features/advertiser/presentation/pages/

# Move advertiser widgets
cp lib/shared/widgets/advertiser_app_bar.dart \
   lib/features/advertiser/presentation/widgets/
cp lib/shared/widgets/advertiser_search_filter_bar.dart \
   lib/features/advertiser/presentation/widgets/ 2>/dev/null || true

# =============================================================================
# PROMOTOR GPS TRACKING FEATURE
# =============================================================================
echo "Migrating promotor gps_tracking feature..."

mkdir -p lib/features/promotor/gps_tracking/data/datasources/local
mkdir -p lib/features/promotor/gps_tracking/data/datasources/remote
mkdir -p lib/features/promotor/gps_tracking/data/repositories
mkdir -p lib/features/promotor/gps_tracking/domain/repositories
mkdir -p lib/features/promotor/gps_tracking/presentation

# Move GPS data sources and repositories
cp lib/shared/datasources/local/gps_local_data_source.dart \
   lib/features/promotor/gps_tracking/data/datasources/local/
cp lib/shared/datasources/remote/gps_remote_data_source.dart \
   lib/features/promotor/gps_tracking/data/datasources/remote/
cp lib/shared/repositories/gps_repository_impl.dart \
   lib/features/promotor/gps_tracking/data/repositories/
cp lib/shared/repositories/gps_repository.dart \
   lib/features/promotor/gps_tracking/domain/repositories/

# =============================================================================
# PROMOTOR CAMPAIGN BROWSING
# =============================================================================
echo "Setting up promotor campaign_browsing feature..."

mkdir -p lib/features/promotor/campaign_browsing/presentation/pages

cp lib/presentation/promotor/pages/promoter_nearby_page.dart \
   lib/features/promotor/campaign_browsing/presentation/pages/

# =============================================================================
# PROMOTOR ROUTE EXECUTION
# =============================================================================
echo "Setting up promotor route_execution feature..."

mkdir -p lib/features/promotor/route_execution/presentation/pages

cp lib/presentation/promotor/pages/promoter_active_page.dart \
   lib/features/promotor/route_execution/presentation/pages/

# =============================================================================
# PROMOTOR ROOT
# =============================================================================
echo "Setting up promotor root presentation..."

mkdir -p lib/features/promotor/presentation/pages
mkdir -p lib/features/promotor/presentation/widgets

cp lib/presentation/promotor/promoter_home_screen.dart \
   lib/features/promotor/presentation/pages/
cp lib/presentation/promotor/pages/promoter_home_page.dart \
   lib/features/promotor/presentation/pages/
cp lib/presentation/promotor/pages/promoter_earnings_page.dart \
   lib/features/promotor/presentation/pages/

# Move promotor widget
cp lib/shared/widgets/promoter_app_bar.dart \
   lib/features/promotor/presentation/widgets/ 2>/dev/null || true

# =============================================================================
# PAYMENTS FEATURE
# =============================================================================
echo "Setting up payments feature..."

mkdir -p lib/features/payments/presentation/pages

cp lib/presentation/advertiser/pages/payment_methods_page.dart \
   lib/features/payments/presentation/pages/

echo "Feature migration complete!"
echo "Next steps:"
echo "1. Update import statements across codebase"
echo "2. Remove old files from lib/shared/ and lib/presentation/"
echo "3. Update barrel files"
echo "4. Run flutter analyze and fix any issues"
