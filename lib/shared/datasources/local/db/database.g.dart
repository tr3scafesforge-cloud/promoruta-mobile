// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailVerifiedAtMeta =
      const VerificationMeta('emailVerifiedAt');
  @override
  late final GeneratedColumn<DateTime> emailVerifiedAt =
      GeneratedColumn<DateTime>('email_verified_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<UserRole, String> role =
      GeneratedColumn<String>('role', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<UserRole>($UsersTable.$converterrole);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _accessTokenMeta =
      const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
      'access_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tokenExpiryMeta =
      const VerificationMeta('tokenExpiry');
  @override
  late final GeneratedColumn<DateTime> tokenExpiry = GeneratedColumn<DateTime>(
      'token_expiry', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refreshExpiresInMeta =
      const VerificationMeta('refreshExpiresIn');
  @override
  late final GeneratedColumn<DateTime> refreshExpiresIn =
      GeneratedColumn<DateTime>('refresh_expires_in', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _refreshTokenMeta =
      const VerificationMeta('refreshToken');
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
      'refresh_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _twoFactorEnabledMeta =
      const VerificationMeta('twoFactorEnabled');
  @override
  late final GeneratedColumn<bool> twoFactorEnabled = GeneratedColumn<bool>(
      'two_factor_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("two_factor_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _twoFactorConfirmedAtMeta =
      const VerificationMeta('twoFactorConfirmedAt');
  @override
  late final GeneratedColumn<DateTime> twoFactorConfirmedAt =
      GeneratedColumn<DateTime>('two_factor_confirmed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        email,
        emailVerifiedAt,
        role,
        createdAt,
        updatedAt,
        accessToken,
        tokenExpiry,
        username,
        photoUrl,
        refreshExpiresIn,
        refreshToken,
        twoFactorEnabled,
        twoFactorConfirmedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('email_verified_at')) {
      context.handle(
          _emailVerifiedAtMeta,
          emailVerifiedAt.isAcceptableOrUnknown(
              data['email_verified_at']!, _emailVerifiedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('access_token')) {
      context.handle(
          _accessTokenMeta,
          accessToken.isAcceptableOrUnknown(
              data['access_token']!, _accessTokenMeta));
    }
    if (data.containsKey('token_expiry')) {
      context.handle(
          _tokenExpiryMeta,
          tokenExpiry.isAcceptableOrUnknown(
              data['token_expiry']!, _tokenExpiryMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('refresh_expires_in')) {
      context.handle(
          _refreshExpiresInMeta,
          refreshExpiresIn.isAcceptableOrUnknown(
              data['refresh_expires_in']!, _refreshExpiresInMeta));
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
          _refreshTokenMeta,
          refreshToken.isAcceptableOrUnknown(
              data['refresh_token']!, _refreshTokenMeta));
    }
    if (data.containsKey('two_factor_enabled')) {
      context.handle(
          _twoFactorEnabledMeta,
          twoFactorEnabled.isAcceptableOrUnknown(
              data['two_factor_enabled']!, _twoFactorEnabledMeta));
    }
    if (data.containsKey('two_factor_confirmed_at')) {
      context.handle(
          _twoFactorConfirmedAtMeta,
          twoFactorConfirmedAt.isAcceptableOrUnknown(
              data['two_factor_confirmed_at']!, _twoFactorConfirmedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      emailVerifiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}email_verified_at']),
      role: $UsersTable.$converterrole.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      accessToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_token']),
      tokenExpiry: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}token_expiry']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      refreshExpiresIn: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}refresh_expires_in']),
      refreshToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}refresh_token']),
      twoFactorEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}two_factor_enabled'])!,
      twoFactorConfirmedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}two_factor_confirmed_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static TypeConverter<UserRole, String> $converterrole =
      const UserRoleConverter();
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? accessToken;
  final DateTime? tokenExpiry;
  final String? username;
  final String? photoUrl;
  final DateTime? refreshExpiresIn;
  final String? refreshToken;
  final bool twoFactorEnabled;
  final DateTime? twoFactorConfirmedAt;
  const User(
      {required this.id,
      required this.name,
      required this.email,
      this.emailVerifiedAt,
      required this.role,
      this.createdAt,
      this.updatedAt,
      this.accessToken,
      this.tokenExpiry,
      this.username,
      this.photoUrl,
      this.refreshExpiresIn,
      this.refreshToken,
      required this.twoFactorEnabled,
      this.twoFactorConfirmedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || emailVerifiedAt != null) {
      map['email_verified_at'] = Variable<DateTime>(emailVerifiedAt);
    }
    {
      map['role'] = Variable<String>($UsersTable.$converterrole.toSql(role));
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || accessToken != null) {
      map['access_token'] = Variable<String>(accessToken);
    }
    if (!nullToAbsent || tokenExpiry != null) {
      map['token_expiry'] = Variable<DateTime>(tokenExpiry);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || refreshExpiresIn != null) {
      map['refresh_expires_in'] = Variable<DateTime>(refreshExpiresIn);
    }
    if (!nullToAbsent || refreshToken != null) {
      map['refresh_token'] = Variable<String>(refreshToken);
    }
    map['two_factor_enabled'] = Variable<bool>(twoFactorEnabled);
    if (!nullToAbsent || twoFactorConfirmedAt != null) {
      map['two_factor_confirmed_at'] = Variable<DateTime>(twoFactorConfirmedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      emailVerifiedAt: emailVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(emailVerifiedAt),
      role: Value(role),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      accessToken: accessToken == null && nullToAbsent
          ? const Value.absent()
          : Value(accessToken),
      tokenExpiry: tokenExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenExpiry),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      refreshExpiresIn: refreshExpiresIn == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshExpiresIn),
      refreshToken: refreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshToken),
      twoFactorEnabled: Value(twoFactorEnabled),
      twoFactorConfirmedAt: twoFactorConfirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(twoFactorConfirmedAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      emailVerifiedAt: serializer.fromJson<DateTime?>(json['emailVerifiedAt']),
      role: serializer.fromJson<UserRole>(json['role']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      accessToken: serializer.fromJson<String?>(json['accessToken']),
      tokenExpiry: serializer.fromJson<DateTime?>(json['tokenExpiry']),
      username: serializer.fromJson<String?>(json['username']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      refreshExpiresIn:
          serializer.fromJson<DateTime?>(json['refreshExpiresIn']),
      refreshToken: serializer.fromJson<String?>(json['refreshToken']),
      twoFactorEnabled: serializer.fromJson<bool>(json['twoFactorEnabled']),
      twoFactorConfirmedAt:
          serializer.fromJson<DateTime?>(json['twoFactorConfirmedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'emailVerifiedAt': serializer.toJson<DateTime?>(emailVerifiedAt),
      'role': serializer.toJson<UserRole>(role),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'accessToken': serializer.toJson<String?>(accessToken),
      'tokenExpiry': serializer.toJson<DateTime?>(tokenExpiry),
      'username': serializer.toJson<String?>(username),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'refreshExpiresIn': serializer.toJson<DateTime?>(refreshExpiresIn),
      'refreshToken': serializer.toJson<String?>(refreshToken),
      'twoFactorEnabled': serializer.toJson<bool>(twoFactorEnabled),
      'twoFactorConfirmedAt':
          serializer.toJson<DateTime?>(twoFactorConfirmedAt),
    };
  }

  User copyWith(
          {String? id,
          String? name,
          String? email,
          Value<DateTime?> emailVerifiedAt = const Value.absent(),
          UserRole? role,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<String?> accessToken = const Value.absent(),
          Value<DateTime?> tokenExpiry = const Value.absent(),
          Value<String?> username = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<DateTime?> refreshExpiresIn = const Value.absent(),
          Value<String?> refreshToken = const Value.absent(),
          bool? twoFactorEnabled,
          Value<DateTime?> twoFactorConfirmedAt = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        emailVerifiedAt: emailVerifiedAt.present
            ? emailVerifiedAt.value
            : this.emailVerifiedAt,
        role: role ?? this.role,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        accessToken: accessToken.present ? accessToken.value : this.accessToken,
        tokenExpiry: tokenExpiry.present ? tokenExpiry.value : this.tokenExpiry,
        username: username.present ? username.value : this.username,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        refreshExpiresIn: refreshExpiresIn.present
            ? refreshExpiresIn.value
            : this.refreshExpiresIn,
        refreshToken:
            refreshToken.present ? refreshToken.value : this.refreshToken,
        twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
        twoFactorConfirmedAt: twoFactorConfirmedAt.present
            ? twoFactorConfirmedAt.value
            : this.twoFactorConfirmedAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      emailVerifiedAt: data.emailVerifiedAt.present
          ? data.emailVerifiedAt.value
          : this.emailVerifiedAt,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      accessToken:
          data.accessToken.present ? data.accessToken.value : this.accessToken,
      tokenExpiry:
          data.tokenExpiry.present ? data.tokenExpiry.value : this.tokenExpiry,
      username: data.username.present ? data.username.value : this.username,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      refreshExpiresIn: data.refreshExpiresIn.present
          ? data.refreshExpiresIn.value
          : this.refreshExpiresIn,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      twoFactorEnabled: data.twoFactorEnabled.present
          ? data.twoFactorEnabled.value
          : this.twoFactorEnabled,
      twoFactorConfirmedAt: data.twoFactorConfirmedAt.present
          ? data.twoFactorConfirmedAt.value
          : this.twoFactorConfirmedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('emailVerifiedAt: $emailVerifiedAt, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('accessToken: $accessToken, ')
          ..write('tokenExpiry: $tokenExpiry, ')
          ..write('username: $username, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('refreshExpiresIn: $refreshExpiresIn, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('twoFactorEnabled: $twoFactorEnabled, ')
          ..write('twoFactorConfirmedAt: $twoFactorConfirmedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      email,
      emailVerifiedAt,
      role,
      createdAt,
      updatedAt,
      accessToken,
      tokenExpiry,
      username,
      photoUrl,
      refreshExpiresIn,
      refreshToken,
      twoFactorEnabled,
      twoFactorConfirmedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.emailVerifiedAt == this.emailVerifiedAt &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.accessToken == this.accessToken &&
          other.tokenExpiry == this.tokenExpiry &&
          other.username == this.username &&
          other.photoUrl == this.photoUrl &&
          other.refreshExpiresIn == this.refreshExpiresIn &&
          other.refreshToken == this.refreshToken &&
          other.twoFactorEnabled == this.twoFactorEnabled &&
          other.twoFactorConfirmedAt == this.twoFactorConfirmedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<DateTime?> emailVerifiedAt;
  final Value<UserRole> role;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> accessToken;
  final Value<DateTime?> tokenExpiry;
  final Value<String?> username;
  final Value<String?> photoUrl;
  final Value<DateTime?> refreshExpiresIn;
  final Value<String?> refreshToken;
  final Value<bool> twoFactorEnabled;
  final Value<DateTime?> twoFactorConfirmedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.emailVerifiedAt = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.tokenExpiry = const Value.absent(),
    this.username = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.refreshExpiresIn = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.twoFactorEnabled = const Value.absent(),
    this.twoFactorConfirmedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.emailVerifiedAt = const Value.absent(),
    required UserRole role,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.tokenExpiry = const Value.absent(),
    this.username = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.refreshExpiresIn = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.twoFactorEnabled = const Value.absent(),
    this.twoFactorConfirmedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        email = Value(email),
        role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<DateTime>? emailVerifiedAt,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? accessToken,
    Expression<DateTime>? tokenExpiry,
    Expression<String>? username,
    Expression<String>? photoUrl,
    Expression<DateTime>? refreshExpiresIn,
    Expression<String>? refreshToken,
    Expression<bool>? twoFactorEnabled,
    Expression<DateTime>? twoFactorConfirmedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (emailVerifiedAt != null) 'email_verified_at': emailVerifiedAt,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (accessToken != null) 'access_token': accessToken,
      if (tokenExpiry != null) 'token_expiry': tokenExpiry,
      if (username != null) 'username': username,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (refreshExpiresIn != null) 'refresh_expires_in': refreshExpiresIn,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (twoFactorEnabled != null) 'two_factor_enabled': twoFactorEnabled,
      if (twoFactorConfirmedAt != null)
        'two_factor_confirmed_at': twoFactorConfirmedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? email,
      Value<DateTime?>? emailVerifiedAt,
      Value<UserRole>? role,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String?>? accessToken,
      Value<DateTime?>? tokenExpiry,
      Value<String?>? username,
      Value<String?>? photoUrl,
      Value<DateTime?>? refreshExpiresIn,
      Value<String?>? refreshToken,
      Value<bool>? twoFactorEnabled,
      Value<DateTime?>? twoFactorConfirmedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      refreshExpiresIn: refreshExpiresIn ?? this.refreshExpiresIn,
      refreshToken: refreshToken ?? this.refreshToken,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorConfirmedAt: twoFactorConfirmedAt ?? this.twoFactorConfirmedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (emailVerifiedAt.present) {
      map['email_verified_at'] = Variable<DateTime>(emailVerifiedAt.value);
    }
    if (role.present) {
      map['role'] =
          Variable<String>($UsersTable.$converterrole.toSql(role.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (tokenExpiry.present) {
      map['token_expiry'] = Variable<DateTime>(tokenExpiry.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (refreshExpiresIn.present) {
      map['refresh_expires_in'] = Variable<DateTime>(refreshExpiresIn.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (twoFactorEnabled.present) {
      map['two_factor_enabled'] = Variable<bool>(twoFactorEnabled.value);
    }
    if (twoFactorConfirmedAt.present) {
      map['two_factor_confirmed_at'] =
          Variable<DateTime>(twoFactorConfirmedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('emailVerifiedAt: $emailVerifiedAt, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('accessToken: $accessToken, ')
          ..write('tokenExpiry: $tokenExpiry, ')
          ..write('username: $username, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('refreshExpiresIn: $refreshExpiresIn, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('twoFactorEnabled: $twoFactorEnabled, ')
          ..write('twoFactorConfirmedAt: $twoFactorConfirmedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignsEntityTable extends CampaignsEntity
    with TableInfo<$CampaignsEntityTable, CampaignsEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByIdMeta =
      const VerificationMeta('createdById');
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
      'created_by_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
      'zone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _suggestedPriceMeta =
      const VerificationMeta('suggestedPrice');
  @override
  late final GeneratedColumn<double> suggestedPrice = GeneratedColumn<double>(
      'suggested_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        createdById,
        startTime,
        endTime,
        status,
        zone,
        suggestedPrice
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns_entity';
  @override
  VerificationContext validateIntegrity(
      Insertable<CampaignsEntityData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
          _createdByIdMeta,
          createdById.isAcceptableOrUnknown(
              data['created_by_id']!, _createdByIdMeta));
    } else if (isInserting) {
      context.missing(_createdByIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('zone')) {
      context.handle(
          _zoneMeta, zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta));
    }
    if (data.containsKey('suggested_price')) {
      context.handle(
          _suggestedPriceMeta,
          suggestedPrice.isAcceptableOrUnknown(
              data['suggested_price']!, _suggestedPriceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CampaignsEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignsEntityData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      zone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone'])!,
      suggestedPrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}suggested_price'])!,
    );
  }

  @override
  $CampaignsEntityTable createAlias(String alias) {
    return $CampaignsEntityTable(attachedDatabase, alias);
  }
}

class CampaignsEntityData extends DataClass
    implements Insertable<CampaignsEntityData> {
  final String id;
  final String title;
  final String description;
  final String createdById;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String zone;
  final double suggestedPrice;
  const CampaignsEntityData(
      {required this.id,
      required this.title,
      required this.description,
      required this.createdById,
      required this.startTime,
      required this.endTime,
      required this.status,
      required this.zone,
      required this.suggestedPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_by_id'] = Variable<String>(createdById);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['status'] = Variable<String>(status);
    map['zone'] = Variable<String>(zone);
    map['suggested_price'] = Variable<double>(suggestedPrice);
    return map;
  }

  CampaignsEntityCompanion toCompanion(bool nullToAbsent) {
    return CampaignsEntityCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      createdById: Value(createdById),
      startTime: Value(startTime),
      endTime: Value(endTime),
      status: Value(status),
      zone: Value(zone),
      suggestedPrice: Value(suggestedPrice),
    );
  }

  factory CampaignsEntityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignsEntityData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdById: serializer.fromJson<String>(json['createdById']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
      zone: serializer.fromJson<String>(json['zone']),
      suggestedPrice: serializer.fromJson<double>(json['suggestedPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdById': serializer.toJson<String>(createdById),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'status': serializer.toJson<String>(status),
      'zone': serializer.toJson<String>(zone),
      'suggestedPrice': serializer.toJson<double>(suggestedPrice),
    };
  }

  CampaignsEntityData copyWith(
          {String? id,
          String? title,
          String? description,
          String? createdById,
          DateTime? startTime,
          DateTime? endTime,
          String? status,
          String? zone,
          double? suggestedPrice}) =>
      CampaignsEntityData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdById: createdById ?? this.createdById,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        zone: zone ?? this.zone,
        suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      );
  CampaignsEntityData copyWithCompanion(CampaignsEntityCompanion data) {
    return CampaignsEntityData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      createdById:
          data.createdById.present ? data.createdById.value : this.createdById,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
      zone: data.zone.present ? data.zone.value : this.zone,
      suggestedPrice: data.suggestedPrice.present
          ? data.suggestedPrice.value
          : this.suggestedPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsEntityData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdById: $createdById, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('zone: $zone, ')
          ..write('suggestedPrice: $suggestedPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, createdById,
      startTime, endTime, status, zone, suggestedPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignsEntityData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdById == this.createdById &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status &&
          other.zone == this.zone &&
          other.suggestedPrice == this.suggestedPrice);
}

class CampaignsEntityCompanion extends UpdateCompanion<CampaignsEntityData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> createdById;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<String> status;
  final Value<String> zone;
  final Value<double> suggestedPrice;
  final Value<int> rowid;
  const CampaignsEntityCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdById = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.zone = const Value.absent(),
    this.suggestedPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsEntityCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String createdById,
    required DateTime startTime,
    required DateTime endTime,
    this.status = const Value.absent(),
    this.zone = const Value.absent(),
    this.suggestedPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        createdById = Value(createdById),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<CampaignsEntityData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? createdById,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? status,
    Expression<String>? zone,
    Expression<double>? suggestedPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdById != null) 'created_by_id': createdById,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (zone != null) 'zone': zone,
      if (suggestedPrice != null) 'suggested_price': suggestedPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsEntityCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? createdById,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<String>? status,
      Value<String>? zone,
      Value<double>? suggestedPrice,
      Value<int>? rowid}) {
    return CampaignsEntityCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdById: createdById ?? this.createdById,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      zone: zone ?? this.zone,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (suggestedPrice.present) {
      map['suggested_price'] = Variable<double>(suggestedPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsEntityCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdById: $createdById, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('zone: $zone, ')
          ..write('suggestedPrice: $suggestedPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutesTable extends Routes with TableInfo<$RoutesTable, Route> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promoterIdMeta =
      const VerificationMeta('promoterId');
  @override
  late final GeneratedColumn<String> promoterId = GeneratedColumn<String>(
      'promoter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _campaignIdMeta =
      const VerificationMeta('campaignId');
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
      'campaign_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, promoterId, campaignId, startTime, endTime, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(Insertable<Route> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('promoter_id')) {
      context.handle(
          _promoterIdMeta,
          promoterId.isAcceptableOrUnknown(
              data['promoter_id']!, _promoterIdMeta));
    } else if (isInserting) {
      context.missing(_promoterIdMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
          _campaignIdMeta,
          campaignId.isAcceptableOrUnknown(
              data['campaign_id']!, _campaignIdMeta));
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Route map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Route(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      promoterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}promoter_id'])!,
      campaignId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}campaign_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }
}

class Route extends DataClass implements Insertable<Route> {
  final String id;
  final String promoterId;
  final String campaignId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  const Route(
      {required this.id,
      required this.promoterId,
      required this.campaignId,
      required this.startTime,
      this.endTime,
      required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['promoter_id'] = Variable<String>(promoterId);
    map['campaign_id'] = Variable<String>(campaignId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      promoterId: Value(promoterId),
      campaignId: Value(campaignId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      isCompleted: Value(isCompleted),
    );
  }

  factory Route.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Route(
      id: serializer.fromJson<String>(json['id']),
      promoterId: serializer.fromJson<String>(json['promoterId']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'promoterId': serializer.toJson<String>(promoterId),
      'campaignId': serializer.toJson<String>(campaignId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Route copyWith(
          {String? id,
          String? promoterId,
          String? campaignId,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          bool? isCompleted}) =>
      Route(
        id: id ?? this.id,
        promoterId: promoterId ?? this.promoterId,
        campaignId: campaignId ?? this.campaignId,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  Route copyWithCompanion(RoutesCompanion data) {
    return Route(
      id: data.id.present ? data.id.value : this.id,
      promoterId:
          data.promoterId.present ? data.promoterId.value : this.promoterId,
      campaignId:
          data.campaignId.present ? data.campaignId.value : this.campaignId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Route(')
          ..write('id: $id, ')
          ..write('promoterId: $promoterId, ')
          ..write('campaignId: $campaignId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, promoterId, campaignId, startTime, endTime, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Route &&
          other.id == this.id &&
          other.promoterId == this.promoterId &&
          other.campaignId == this.campaignId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isCompleted == this.isCompleted);
}

class RoutesCompanion extends UpdateCompanion<Route> {
  final Value<String> id;
  final Value<String> promoterId;
  final Value<String> campaignId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<bool> isCompleted;
  final Value<int> rowid;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.promoterId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutesCompanion.insert({
    required String id,
    required String promoterId,
    required String campaignId,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        promoterId = Value(promoterId),
        campaignId = Value(campaignId),
        startTime = Value(startTime);
  static Insertable<Route> custom({
    Expression<String>? id,
    Expression<String>? promoterId,
    Expression<String>? campaignId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<bool>? isCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promoterId != null) 'promoter_id': promoterId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutesCompanion copyWith(
      {Value<String>? id,
      Value<String>? promoterId,
      Value<String>? campaignId,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<bool>? isCompleted,
      Value<int>? rowid}) {
    return RoutesCompanion(
      id: id ?? this.id,
      promoterId: promoterId ?? this.promoterId,
      campaignId: campaignId ?? this.campaignId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (promoterId.present) {
      map['promoter_id'] = Variable<String>(promoterId.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('promoterId: $promoterId, ')
          ..write('campaignId: $campaignId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GpsPointsTable extends GpsPoints
    with TableInfo<$GpsPointsTable, GpsPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GpsPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routeIdMeta =
      const VerificationMeta('routeId');
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
      'route_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routes (id)'));
  static const VerificationMeta _campaignIdMeta =
      const VerificationMeta('campaignId');
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
      'campaign_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        routeId,
        campaignId,
        latitude,
        longitude,
        timestamp,
        speed,
        accuracy,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gps_points';
  @override
  VerificationContext validateIntegrity(Insertable<GpsPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(_routeIdMeta,
          routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta));
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
          _campaignIdMeta,
          campaignId.isAcceptableOrUnknown(
              data['campaign_id']!, _campaignIdMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GpsPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GpsPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_id']),
      campaignId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}campaign_id']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed']),
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $GpsPointsTable createAlias(String alias) {
    return $GpsPointsTable(attachedDatabase, alias);
  }
}

class GpsPoint extends DataClass implements Insertable<GpsPoint> {
  final String id;
  final String? routeId;
  final String? campaignId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? accuracy;
  final DateTime? syncedAt;
  const GpsPoint(
      {required this.id,
      this.routeId,
      this.campaignId,
      required this.latitude,
      required this.longitude,
      required this.timestamp,
      this.speed,
      this.accuracy,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || routeId != null) {
      map['route_id'] = Variable<String>(routeId);
    }
    if (!nullToAbsent || campaignId != null) {
      map['campaign_id'] = Variable<String>(campaignId);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  GpsPointsCompanion toCompanion(bool nullToAbsent) {
    return GpsPointsCompanion(
      id: Value(id),
      routeId: routeId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeId),
      campaignId: campaignId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaignId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
      speed:
          speed == null && nullToAbsent ? const Value.absent() : Value(speed),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory GpsPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsPoint(
      id: serializer.fromJson<String>(json['id']),
      routeId: serializer.fromJson<String?>(json['routeId']),
      campaignId: serializer.fromJson<String?>(json['campaignId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      speed: serializer.fromJson<double?>(json['speed']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routeId': serializer.toJson<String?>(routeId),
      'campaignId': serializer.toJson<String?>(campaignId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'speed': serializer.toJson<double?>(speed),
      'accuracy': serializer.toJson<double?>(accuracy),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  GpsPoint copyWith(
          {String? id,
          Value<String?> routeId = const Value.absent(),
          Value<String?> campaignId = const Value.absent(),
          double? latitude,
          double? longitude,
          DateTime? timestamp,
          Value<double?> speed = const Value.absent(),
          Value<double?> accuracy = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      GpsPoint(
        id: id ?? this.id,
        routeId: routeId.present ? routeId.value : this.routeId,
        campaignId: campaignId.present ? campaignId.value : this.campaignId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        timestamp: timestamp ?? this.timestamp,
        speed: speed.present ? speed.value : this.speed,
        accuracy: accuracy.present ? accuracy.value : this.accuracy,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  GpsPoint copyWithCompanion(GpsPointsCompanion data) {
    return GpsPoint(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      campaignId:
          data.campaignId.present ? data.campaignId.value : this.campaignId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsPoint(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('campaignId: $campaignId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routeId, campaignId, latitude, longitude,
      timestamp, speed, accuracy, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsPoint &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.campaignId == this.campaignId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy &&
          other.syncedAt == this.syncedAt);
}

class GpsPointsCompanion extends UpdateCompanion<GpsPoint> {
  final Value<String> id;
  final Value<String?> routeId;
  final Value<String?> campaignId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> timestamp;
  final Value<double?> speed;
  final Value<double?> accuracy;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const GpsPointsCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GpsPointsCompanion.insert({
    required String id,
    this.routeId = const Value.absent(),
    this.campaignId = const Value.absent(),
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        latitude = Value(latitude),
        longitude = Value(longitude),
        timestamp = Value(timestamp);
  static Insertable<GpsPoint> custom({
    Expression<String>? id,
    Expression<String>? routeId,
    Expression<String>? campaignId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
    Expression<double>? speed,
    Expression<double>? accuracy,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GpsPointsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? routeId,
      Value<String?>? campaignId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<DateTime>? timestamp,
      Value<double?>? speed,
      Value<double?>? accuracy,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return GpsPointsCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      campaignId: campaignId ?? this.campaignId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GpsPointsCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('campaignId: $campaignId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CampaignsEntityTable campaignsEntity =
      $CampaignsEntityTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $GpsPointsTable gpsPoints = $GpsPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, campaignsEntity, routes, gpsPoints];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String name,
  required String email,
  Value<DateTime?> emailVerifiedAt,
  required UserRole role,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> accessToken,
  Value<DateTime?> tokenExpiry,
  Value<String?> username,
  Value<String?> photoUrl,
  Value<DateTime?> refreshExpiresIn,
  Value<String?> refreshToken,
  Value<bool> twoFactorEnabled,
  Value<DateTime?> twoFactorConfirmedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> email,
  Value<DateTime?> emailVerifiedAt,
  Value<UserRole> role,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> accessToken,
  Value<DateTime?> tokenExpiry,
  Value<String?> username,
  Value<String?> photoUrl,
  Value<DateTime?> refreshExpiresIn,
  Value<String?> refreshToken,
  Value<bool> twoFactorEnabled,
  Value<DateTime?> twoFactorConfirmedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get emailVerifiedAt => $composableBuilder(
      column: $table.emailVerifiedAt,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<UserRole, UserRole, String> get role =>
      $composableBuilder(
          column: $table.role,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tokenExpiry => $composableBuilder(
      column: $table.tokenExpiry, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get refreshExpiresIn => $composableBuilder(
      column: $table.refreshExpiresIn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refreshToken => $composableBuilder(
      column: $table.refreshToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get twoFactorEnabled => $composableBuilder(
      column: $table.twoFactorEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get twoFactorConfirmedAt => $composableBuilder(
      column: $table.twoFactorConfirmedAt,
      builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get emailVerifiedAt => $composableBuilder(
      column: $table.emailVerifiedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tokenExpiry => $composableBuilder(
      column: $table.tokenExpiry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get refreshExpiresIn => $composableBuilder(
      column: $table.refreshExpiresIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refreshToken => $composableBuilder(
      column: $table.refreshToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get twoFactorEnabled => $composableBuilder(
      column: $table.twoFactorEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get twoFactorConfirmedAt => $composableBuilder(
      column: $table.twoFactorConfirmedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get emailVerifiedAt => $composableBuilder(
      column: $table.emailVerifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UserRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => column);

  GeneratedColumn<DateTime> get tokenExpiry => $composableBuilder(
      column: $table.tokenExpiry, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get refreshExpiresIn => $composableBuilder(
      column: $table.refreshExpiresIn, builder: (column) => column);

  GeneratedColumn<String> get refreshToken => $composableBuilder(
      column: $table.refreshToken, builder: (column) => column);

  GeneratedColumn<bool> get twoFactorEnabled => $composableBuilder(
      column: $table.twoFactorEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get twoFactorConfirmedAt => $composableBuilder(
      column: $table.twoFactorConfirmedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<DateTime?> emailVerifiedAt = const Value.absent(),
            Value<UserRole> role = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<DateTime?> tokenExpiry = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime?> refreshExpiresIn = const Value.absent(),
            Value<String?> refreshToken = const Value.absent(),
            Value<bool> twoFactorEnabled = const Value.absent(),
            Value<DateTime?> twoFactorConfirmedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            email: email,
            emailVerifiedAt: emailVerifiedAt,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            accessToken: accessToken,
            tokenExpiry: tokenExpiry,
            username: username,
            photoUrl: photoUrl,
            refreshExpiresIn: refreshExpiresIn,
            refreshToken: refreshToken,
            twoFactorEnabled: twoFactorEnabled,
            twoFactorConfirmedAt: twoFactorConfirmedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String email,
            Value<DateTime?> emailVerifiedAt = const Value.absent(),
            required UserRole role,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<DateTime?> tokenExpiry = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime?> refreshExpiresIn = const Value.absent(),
            Value<String?> refreshToken = const Value.absent(),
            Value<bool> twoFactorEnabled = const Value.absent(),
            Value<DateTime?> twoFactorConfirmedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            emailVerifiedAt: emailVerifiedAt,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            accessToken: accessToken,
            tokenExpiry: tokenExpiry,
            username: username,
            photoUrl: photoUrl,
            refreshExpiresIn: refreshExpiresIn,
            refreshToken: refreshToken,
            twoFactorEnabled: twoFactorEnabled,
            twoFactorConfirmedAt: twoFactorConfirmedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$CampaignsEntityTableCreateCompanionBuilder = CampaignsEntityCompanion
    Function({
  required String id,
  required String title,
  required String description,
  required String createdById,
  required DateTime startTime,
  required DateTime endTime,
  Value<String> status,
  Value<String> zone,
  Value<double> suggestedPrice,
  Value<int> rowid,
});
typedef $$CampaignsEntityTableUpdateCompanionBuilder = CampaignsEntityCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> createdById,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<String> status,
  Value<String> zone,
  Value<double> suggestedPrice,
  Value<int> rowid,
});

class $$CampaignsEntityTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignsEntityTable> {
  $$CampaignsEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zone => $composableBuilder(
      column: $table.zone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get suggestedPrice => $composableBuilder(
      column: $table.suggestedPrice,
      builder: (column) => ColumnFilters(column));
}

class $$CampaignsEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignsEntityTable> {
  $$CampaignsEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zone => $composableBuilder(
      column: $table.zone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get suggestedPrice => $composableBuilder(
      column: $table.suggestedPrice,
      builder: (column) => ColumnOrderings(column));
}

class $$CampaignsEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignsEntityTable> {
  $$CampaignsEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get createdById => $composableBuilder(
      column: $table.createdById, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<double> get suggestedPrice => $composableBuilder(
      column: $table.suggestedPrice, builder: (column) => column);
}

class $$CampaignsEntityTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CampaignsEntityTable,
    CampaignsEntityData,
    $$CampaignsEntityTableFilterComposer,
    $$CampaignsEntityTableOrderingComposer,
    $$CampaignsEntityTableAnnotationComposer,
    $$CampaignsEntityTableCreateCompanionBuilder,
    $$CampaignsEntityTableUpdateCompanionBuilder,
    (
      CampaignsEntityData,
      BaseReferences<_$AppDatabase, $CampaignsEntityTable, CampaignsEntityData>
    ),
    CampaignsEntityData,
    PrefetchHooks Function()> {
  $$CampaignsEntityTableTableManager(
      _$AppDatabase db, $CampaignsEntityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> createdById = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> zone = const Value.absent(),
            Value<double> suggestedPrice = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CampaignsEntityCompanion(
            id: id,
            title: title,
            description: description,
            createdById: createdById,
            startTime: startTime,
            endTime: endTime,
            status: status,
            zone: zone,
            suggestedPrice: suggestedPrice,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required String createdById,
            required DateTime startTime,
            required DateTime endTime,
            Value<String> status = const Value.absent(),
            Value<String> zone = const Value.absent(),
            Value<double> suggestedPrice = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CampaignsEntityCompanion.insert(
            id: id,
            title: title,
            description: description,
            createdById: createdById,
            startTime: startTime,
            endTime: endTime,
            status: status,
            zone: zone,
            suggestedPrice: suggestedPrice,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CampaignsEntityTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CampaignsEntityTable,
    CampaignsEntityData,
    $$CampaignsEntityTableFilterComposer,
    $$CampaignsEntityTableOrderingComposer,
    $$CampaignsEntityTableAnnotationComposer,
    $$CampaignsEntityTableCreateCompanionBuilder,
    $$CampaignsEntityTableUpdateCompanionBuilder,
    (
      CampaignsEntityData,
      BaseReferences<_$AppDatabase, $CampaignsEntityTable, CampaignsEntityData>
    ),
    CampaignsEntityData,
    PrefetchHooks Function()>;
typedef $$RoutesTableCreateCompanionBuilder = RoutesCompanion Function({
  required String id,
  required String promoterId,
  required String campaignId,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<bool> isCompleted,
  Value<int> rowid,
});
typedef $$RoutesTableUpdateCompanionBuilder = RoutesCompanion Function({
  Value<String> id,
  Value<String> promoterId,
  Value<String> campaignId,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<bool> isCompleted,
  Value<int> rowid,
});

final class $$RoutesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutesTable, Route> {
  $$RoutesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GpsPointsTable, List<GpsPoint>>
      _gpsPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.gpsPoints,
          aliasName: $_aliasNameGenerator(db.routes.id, db.gpsPoints.routeId));

  $$GpsPointsTableProcessedTableManager get gpsPointsRefs {
    final manager = $$GpsPointsTableTableManager($_db, $_db.gpsPoints)
        .filter((f) => f.routeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gpsPointsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promoterId => $composableBuilder(
      column: $table.promoterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  Expression<bool> gpsPointsRefs(
      Expression<bool> Function($$GpsPointsTableFilterComposer f) f) {
    final $$GpsPointsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gpsPoints,
        getReferencedColumn: (t) => t.routeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GpsPointsTableFilterComposer(
              $db: $db,
              $table: $db.gpsPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promoterId => $composableBuilder(
      column: $table.promoterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promoterId => $composableBuilder(
      column: $table.promoterId, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  Expression<T> gpsPointsRefs<T extends Object>(
      Expression<T> Function($$GpsPointsTableAnnotationComposer a) f) {
    final $$GpsPointsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gpsPoints,
        getReferencedColumn: (t) => t.routeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GpsPointsTableAnnotationComposer(
              $db: $db,
              $table: $db.gpsPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoutesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoutesTable,
    Route,
    $$RoutesTableFilterComposer,
    $$RoutesTableOrderingComposer,
    $$RoutesTableAnnotationComposer,
    $$RoutesTableCreateCompanionBuilder,
    $$RoutesTableUpdateCompanionBuilder,
    (Route, $$RoutesTableReferences),
    Route,
    PrefetchHooks Function({bool gpsPointsRefs})> {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> promoterId = const Value.absent(),
            Value<String> campaignId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutesCompanion(
            id: id,
            promoterId: promoterId,
            campaignId: campaignId,
            startTime: startTime,
            endTime: endTime,
            isCompleted: isCompleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String promoterId,
            required String campaignId,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutesCompanion.insert(
            id: id,
            promoterId: promoterId,
            campaignId: campaignId,
            startTime: startTime,
            endTime: endTime,
            isCompleted: isCompleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoutesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({gpsPointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gpsPointsRefs) db.gpsPoints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gpsPointsRefs)
                    await $_getPrefetchedData<Route, $RoutesTable, GpsPoint>(
                        currentTable: table,
                        referencedTable:
                            $$RoutesTableReferences._gpsPointsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoutesTableReferences(db, table, p0)
                                .gpsPointsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.routeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoutesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoutesTable,
    Route,
    $$RoutesTableFilterComposer,
    $$RoutesTableOrderingComposer,
    $$RoutesTableAnnotationComposer,
    $$RoutesTableCreateCompanionBuilder,
    $$RoutesTableUpdateCompanionBuilder,
    (Route, $$RoutesTableReferences),
    Route,
    PrefetchHooks Function({bool gpsPointsRefs})>;
typedef $$GpsPointsTableCreateCompanionBuilder = GpsPointsCompanion Function({
  required String id,
  Value<String?> routeId,
  Value<String?> campaignId,
  required double latitude,
  required double longitude,
  required DateTime timestamp,
  Value<double?> speed,
  Value<double?> accuracy,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$GpsPointsTableUpdateCompanionBuilder = GpsPointsCompanion Function({
  Value<String> id,
  Value<String?> routeId,
  Value<String?> campaignId,
  Value<double> latitude,
  Value<double> longitude,
  Value<DateTime> timestamp,
  Value<double?> speed,
  Value<double?> accuracy,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

final class $$GpsPointsTableReferences
    extends BaseReferences<_$AppDatabase, $GpsPointsTable, GpsPoint> {
  $$GpsPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutesTable _routeIdTable(_$AppDatabase db) => db.routes
      .createAlias($_aliasNameGenerator(db.gpsPoints.routeId, db.routes.id));

  $$RoutesTableProcessedTableManager? get routeId {
    final $_column = $_itemColumn<String>('route_id');
    if ($_column == null) return null;
    final manager = $$RoutesTableTableManager($_db, $_db.routes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GpsPointsTableFilterComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routeId,
        referencedTable: $db.routes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutesTableFilterComposer(
              $db: $db,
              $table: $db.routes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GpsPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routeId,
        referencedTable: $db.routes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutesTableOrderingComposer(
              $db: $db,
              $table: $db.routes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GpsPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routeId,
        referencedTable: $db.routes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutesTableAnnotationComposer(
              $db: $db,
              $table: $db.routes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GpsPointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GpsPointsTable,
    GpsPoint,
    $$GpsPointsTableFilterComposer,
    $$GpsPointsTableOrderingComposer,
    $$GpsPointsTableAnnotationComposer,
    $$GpsPointsTableCreateCompanionBuilder,
    $$GpsPointsTableUpdateCompanionBuilder,
    (GpsPoint, $$GpsPointsTableReferences),
    GpsPoint,
    PrefetchHooks Function({bool routeId})> {
  $$GpsPointsTableTableManager(_$AppDatabase db, $GpsPointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GpsPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GpsPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GpsPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> routeId = const Value.absent(),
            Value<String?> campaignId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<double?> speed = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GpsPointsCompanion(
            id: id,
            routeId: routeId,
            campaignId: campaignId,
            latitude: latitude,
            longitude: longitude,
            timestamp: timestamp,
            speed: speed,
            accuracy: accuracy,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> routeId = const Value.absent(),
            Value<String?> campaignId = const Value.absent(),
            required double latitude,
            required double longitude,
            required DateTime timestamp,
            Value<double?> speed = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GpsPointsCompanion.insert(
            id: id,
            routeId: routeId,
            campaignId: campaignId,
            latitude: latitude,
            longitude: longitude,
            timestamp: timestamp,
            speed: speed,
            accuracy: accuracy,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GpsPointsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({routeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (routeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.routeId,
                    referencedTable:
                        $$GpsPointsTableReferences._routeIdTable(db),
                    referencedColumn:
                        $$GpsPointsTableReferences._routeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GpsPointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GpsPointsTable,
    GpsPoint,
    $$GpsPointsTableFilterComposer,
    $$GpsPointsTableOrderingComposer,
    $$GpsPointsTableAnnotationComposer,
    $$GpsPointsTableCreateCompanionBuilder,
    $$GpsPointsTableUpdateCompanionBuilder,
    (GpsPoint, $$GpsPointsTableReferences),
    GpsPoint,
    PrefetchHooks Function({bool routeId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CampaignsEntityTableTableManager get campaignsEntity =>
      $$CampaignsEntityTableTableManager(_db, _db.campaignsEntity);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$GpsPointsTableTableManager get gpsPoints =>
      $$GpsPointsTableTableManager(_db, _db.gpsPoints);
}
