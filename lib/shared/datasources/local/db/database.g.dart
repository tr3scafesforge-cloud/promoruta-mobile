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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        role,
        accessToken,
        tokenExpiry,
        username,
        photoUrl,
        createdAt
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
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      accessToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_token']),
      tokenExpiry: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}token_expiry']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String role;
  final String? accessToken;
  final DateTime? tokenExpiry;
  final String? username;
  final String? photoUrl;
  final DateTime? createdAt;
  const User(
      {required this.id,
      required this.email,
      required this.role,
      this.accessToken,
      this.tokenExpiry,
      this.username,
      this.photoUrl,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
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
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      role: Value(role),
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
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      accessToken: serializer.fromJson<String?>(json['accessToken']),
      tokenExpiry: serializer.fromJson<DateTime?>(json['tokenExpiry']),
      username: serializer.fromJson<String?>(json['username']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'accessToken': serializer.toJson<String?>(accessToken),
      'tokenExpiry': serializer.toJson<DateTime?>(tokenExpiry),
      'username': serializer.toJson<String?>(username),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  User copyWith(
          {String? id,
          String? email,
          String? role,
          Value<String?> accessToken = const Value.absent(),
          Value<DateTime?> tokenExpiry = const Value.absent(),
          Value<String?> username = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        role: role ?? this.role,
        accessToken: accessToken.present ? accessToken.value : this.accessToken,
        tokenExpiry: tokenExpiry.present ? tokenExpiry.value : this.tokenExpiry,
        username: username.present ? username.value : this.username,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      accessToken:
          data.accessToken.present ? data.accessToken.value : this.accessToken,
      tokenExpiry:
          data.tokenExpiry.present ? data.tokenExpiry.value : this.tokenExpiry,
      username: data.username.present ? data.username.value : this.username,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('accessToken: $accessToken, ')
          ..write('tokenExpiry: $tokenExpiry, ')
          ..write('username: $username, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, email, role, accessToken, tokenExpiry, username, photoUrl, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.role == this.role &&
          other.accessToken == this.accessToken &&
          other.tokenExpiry == this.tokenExpiry &&
          other.username == this.username &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> role;
  final Value<String?> accessToken;
  final Value<DateTime?> tokenExpiry;
  final Value<String?> username;
  final Value<String?> photoUrl;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.tokenExpiry = const Value.absent(),
    this.username = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String role,
    Value<String?> accessToken = const Value.absent(),
    Value<DateTime?> tokenExpiry = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<int> rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        role = Value(role),
        accessToken = accessToken,
        tokenExpiry = tokenExpiry,
        username = username,
        photoUrl = photoUrl,
        createdAt = createdAt,
        rowid = rowid;
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? accessToken,
    Expression<DateTime>? tokenExpiry,
    Expression<String>? username,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (accessToken != null) 'access_token': accessToken,
      if (tokenExpiry != null) 'token_expiry': tokenExpiry,
      if (username != null) 'username': username,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? role,
      Value<String?>? accessToken,
      Value<DateTime?>? tokenExpiry,
      Value<String?>? username,
      Value<String?>? photoUrl,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      accessToken: accessToken ?? this.accessToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('accessToken: $accessToken, ')
          ..write('tokenExpiry: $tokenExpiry, ')
          ..write('username: $username, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _advertiserIdMeta =
      const VerificationMeta('advertiserId');
  @override
  late final GeneratedColumn<String> advertiserId = GeneratedColumn<String>(
      'advertiser_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, description, advertiserId, startDate, endDate, status];
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
    if (data.containsKey('advertiser_id')) {
      context.handle(
          _advertiserIdMeta,
          advertiserId.isAcceptableOrUnknown(
              data['advertiser_id']!, _advertiserIdMeta));
    } else if (isInserting) {
      context.missing(_advertiserIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
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
      advertiserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}advertiser_id'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
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
  final String advertiserId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  const CampaignsEntityData(
      {required this.id,
      required this.title,
      required this.description,
      required this.advertiserId,
      required this.startDate,
      required this.endDate,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['advertiser_id'] = Variable<String>(advertiserId);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    return map;
  }

  CampaignsEntityCompanion toCompanion(bool nullToAbsent) {
    return CampaignsEntityCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      advertiserId: Value(advertiserId),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
    );
  }

  factory CampaignsEntityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignsEntityData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      advertiserId: serializer.fromJson<String>(json['advertiserId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'advertiserId': serializer.toJson<String>(advertiserId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
    };
  }

  CampaignsEntityData copyWith(
          {String? id,
          String? title,
          String? description,
          String? advertiserId,
          DateTime? startDate,
          DateTime? endDate,
          String? status}) =>
      CampaignsEntityData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        advertiserId: advertiserId ?? this.advertiserId,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
      );
  CampaignsEntityData copyWithCompanion(CampaignsEntityCompanion data) {
    return CampaignsEntityData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      advertiserId: data.advertiserId.present
          ? data.advertiserId.value
          : this.advertiserId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsEntityData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('advertiserId: $advertiserId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, description, advertiserId, startDate, endDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignsEntityData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.advertiserId == this.advertiserId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status);
}

class CampaignsEntityCompanion extends UpdateCompanion<CampaignsEntityData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> advertiserId;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  final Value<int> rowid;
  const CampaignsEntityCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.advertiserId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsEntityCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String advertiserId,
    required DateTime startDate,
    required DateTime endDate,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        advertiserId = Value(advertiserId),
        startDate = Value(startDate),
        endDate = Value(endDate);
  static Insertable<CampaignsEntityData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? advertiserId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (advertiserId != null) 'advertiser_id': advertiserId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsEntityCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? advertiserId,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? status,
      Value<int>? rowid}) {
    return CampaignsEntityCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      advertiserId: advertiserId ?? this.advertiserId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
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
    if (advertiserId.present) {
      map['advertiser_id'] = Variable<String>(advertiserId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
          ..write('advertiserId: $advertiserId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
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
      'route_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routes (id)'));
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, routeId, latitude, longitude, timestamp, speed, accuracy];
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
    } else if (isInserting) {
      context.missing(_routeIdMeta);
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
          .read(DriftSqlType.string, data['${effectivePrefix}route_id'])!,
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
    );
  }

  @override
  $GpsPointsTable createAlias(String alias) {
    return $GpsPointsTable(attachedDatabase, alias);
  }
}

class GpsPoint extends DataClass implements Insertable<GpsPoint> {
  final String id;
  final String routeId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? accuracy;
  const GpsPoint(
      {required this.id,
      required this.routeId,
      required this.latitude,
      required this.longitude,
      required this.timestamp,
      this.speed,
      this.accuracy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['route_id'] = Variable<String>(routeId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    return map;
  }

  GpsPointsCompanion toCompanion(bool nullToAbsent) {
    return GpsPointsCompanion(
      id: Value(id),
      routeId: Value(routeId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
      speed:
          speed == null && nullToAbsent ? const Value.absent() : Value(speed),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
    );
  }

  factory GpsPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsPoint(
      id: serializer.fromJson<String>(json['id']),
      routeId: serializer.fromJson<String>(json['routeId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      speed: serializer.fromJson<double?>(json['speed']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routeId': serializer.toJson<String>(routeId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'speed': serializer.toJson<double?>(speed),
      'accuracy': serializer.toJson<double?>(accuracy),
    };
  }

  GpsPoint copyWith(
          {String? id,
          String? routeId,
          double? latitude,
          double? longitude,
          DateTime? timestamp,
          Value<double?> speed = const Value.absent(),
          Value<double?> accuracy = const Value.absent()}) =>
      GpsPoint(
        id: id ?? this.id,
        routeId: routeId ?? this.routeId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        timestamp: timestamp ?? this.timestamp,
        speed: speed.present ? speed.value : this.speed,
        accuracy: accuracy.present ? accuracy.value : this.accuracy,
      );
  GpsPoint copyWithCompanion(GpsPointsCompanion data) {
    return GpsPoint(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsPoint(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, routeId, latitude, longitude, timestamp, speed, accuracy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsPoint &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy);
}

class GpsPointsCompanion extends UpdateCompanion<GpsPoint> {
  final Value<String> id;
  final Value<String> routeId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> timestamp;
  final Value<double?> speed;
  final Value<double?> accuracy;
  final Value<int> rowid;
  const GpsPointsCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GpsPointsCompanion.insert({
    required String id,
    required String routeId,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        routeId = Value(routeId),
        latitude = Value(latitude),
        longitude = Value(longitude),
        timestamp = Value(timestamp);
  static Insertable<GpsPoint> custom({
    Expression<String>? id,
    Expression<String>? routeId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
    Expression<double>? speed,
    Expression<double>? accuracy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GpsPointsCompanion copyWith(
      {Value<String>? id,
      Value<String>? routeId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<DateTime>? timestamp,
      Value<double?>? speed,
      Value<double?>? accuracy,
      Value<int>? rowid}) {
    return GpsPointsCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
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
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
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
  required String email,
  required String role,
  Value<String?> accessToken,
  Value<DateTime?> tokenExpiry,
  Value<String?> username,
  Value<String?> photoUrl,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> role,
  Value<String?> accessToken,
  Value<DateTime?> tokenExpiry,
  Value<String?> username,
  Value<String?> photoUrl,
  Value<DateTime?> createdAt,
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

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tokenExpiry => $composableBuilder(
      column: $table.tokenExpiry, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tokenExpiry => $composableBuilder(
      column: $table.tokenExpiry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => column);

  GeneratedColumn<DateTime> get tokenExpiry => $composableBuilder(
      column: $table.tokenExpiry, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
            Value<String> email = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<DateTime?> tokenExpiry = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            role: role,
            accessToken: accessToken,
            tokenExpiry: tokenExpiry,
            username: username,
            photoUrl: photoUrl,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            required String role,
            Value<String?> accessToken = const Value.absent(),
            Value<DateTime?> tokenExpiry = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            role: role,
            accessToken: accessToken,
            tokenExpiry: tokenExpiry,
            username: username,
            photoUrl: photoUrl,
            createdAt: createdAt,
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
  required String advertiserId,
  required DateTime startDate,
  required DateTime endDate,
  Value<String> status,
  Value<int> rowid,
});
typedef $$CampaignsEntityTableUpdateCompanionBuilder = CampaignsEntityCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> advertiserId,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> status,
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

  ColumnFilters<String> get advertiserId => $composableBuilder(
      column: $table.advertiserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get advertiserId => $composableBuilder(
      column: $table.advertiserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get advertiserId => $composableBuilder(
      column: $table.advertiserId, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
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
            Value<String> advertiserId = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CampaignsEntityCompanion(
            id: id,
            title: title,
            description: description,
            advertiserId: advertiserId,
            startDate: startDate,
            endDate: endDate,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required String advertiserId,
            required DateTime startDate,
            required DateTime endDate,
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CampaignsEntityCompanion.insert(
            id: id,
            title: title,
            description: description,
            advertiserId: advertiserId,
            startDate: startDate,
            endDate: endDate,
            status: status,
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
  required String routeId,
  required double latitude,
  required double longitude,
  required DateTime timestamp,
  Value<double?> speed,
  Value<double?> accuracy,
  Value<int> rowid,
});
typedef $$GpsPointsTableUpdateCompanionBuilder = GpsPointsCompanion Function({
  Value<String> id,
  Value<String> routeId,
  Value<double> latitude,
  Value<double> longitude,
  Value<DateTime> timestamp,
  Value<double?> speed,
  Value<double?> accuracy,
  Value<int> rowid,
});

final class $$GpsPointsTableReferences
    extends BaseReferences<_$AppDatabase, $GpsPointsTable, GpsPoint> {
  $$GpsPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutesTable _routeIdTable(_$AppDatabase db) => db.routes
      .createAlias($_aliasNameGenerator(db.gpsPoints.routeId, db.routes.id));

  $$RoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<String>('route_id')!;

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
            Value<String> routeId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<double?> speed = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GpsPointsCompanion(
            id: id,
            routeId: routeId,
            latitude: latitude,
            longitude: longitude,
            timestamp: timestamp,
            speed: speed,
            accuracy: accuracy,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String routeId,
            required double latitude,
            required double longitude,
            required DateTime timestamp,
            Value<double?> speed = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GpsPointsCompanion.insert(
            id: id,
            routeId: routeId,
            latitude: latitude,
            longitude: longitude,
            timestamp: timestamp,
            speed: speed,
            accuracy: accuracy,
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
