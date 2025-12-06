#!/bin/bash

echo "Fixing remaining import issues..."

# Fix campaign UI imports in presentation pages
find lib/features/advertiser/campaign_management/presentation/pages -name "*.dart" -exec \
  sed -i 's|package:promoruta/shared/models/campaign_ui.dart|../models/campaign_ui.dart|g' {} \;

# Fix GPS datasource imports - use package imports instead of relative
sed -i 's|../../../../../core/models/gps_point.dart|package:promoruta/core/models/gps_point.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart
sed -i 's|../../../../../core/models/route.dart|package:promoruta/core/models/route.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart
sed -i 's|../../domain/repositories/gps_repository.dart|../../../domain/repositories/gps_repository.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart
sed -i 's|../../../../../shared/datasources/local/db/database.dart|package:promoruta/shared/datasources/local/db/database.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart

# Fix GPS remote datasource
sed -i 's|../../../../../core/models/gps_point.dart|package:promoruta/core/models/gps_point.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart
sed -i 's|../../domain/repositories/gps_repository.dart|../../../domain/repositories/gps_repository.dart|g' \
  lib/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart

echo "Import fixes complete!"
