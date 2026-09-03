// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SpacesTable extends Spaces with TableInfo<$SpacesTable, Space> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SpaceType, String> spaceType =
      GeneratedColumn<String>(
        'space_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SpaceType>($SpacesTable.$converterspaceType);
  @override
  late final GeneratedColumnWithTypeConverter<BudgetMode, String> budgetMode =
      GeneratedColumn<String>(
        'budget_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BudgetMode>($SpacesTable.$converterbudgetMode);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StorageMode, String> storageMode =
      GeneratedColumn<String>(
        'storage_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StorageMode>($SpacesTable.$converterstorageMode);
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxMembersMeta = const VerificationMeta(
    'maxMembers',
  );
  @override
  late final GeneratedColumn<int> maxMembers = GeneratedColumn<int>(
    'max_members',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> manualBalance =
      GeneratedColumn<String>(
        'manual_balance',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($SpacesTable.$convertermanualBalancen);
  static const VerificationMeta _manualBalanceUpdatedAtMeta =
      const VerificationMeta('manualBalanceUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> manualBalanceUpdatedAt =
      GeneratedColumn<DateTime>(
        'manual_balance_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _minSchemaVersionMeta = const VerificationMeta(
    'minSchemaVersion',
  );
  @override
  late final GeneratedColumn<int> minSchemaVersion = GeneratedColumn<int>(
    'min_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FeedOrderMode, String>
  feedOrderMode = GeneratedColumn<String>(
    'feed_order_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('grouped'),
  ).withConverter<FeedOrderMode>($SpacesTable.$converterfeedOrderMode);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    spaceType,
    budgetMode,
    ownerId,
    storageMode,
    countryCode,
    timezone,
    currencyCode,
    maxMembers,
    isArchived,
    manualBalance,
    manualBalanceUpdatedAt,
    minSchemaVersion,
    feedOrderMode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Space> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('max_members')) {
      context.handle(
        _maxMembersMeta,
        maxMembers.isAcceptableOrUnknown(data['max_members']!, _maxMembersMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('manual_balance_updated_at')) {
      context.handle(
        _manualBalanceUpdatedAtMeta,
        manualBalanceUpdatedAt.isAcceptableOrUnknown(
          data['manual_balance_updated_at']!,
          _manualBalanceUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('min_schema_version')) {
      context.handle(
        _minSchemaVersionMeta,
        minSchemaVersion.isAcceptableOrUnknown(
          data['min_schema_version']!,
          _minSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Space map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Space(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      spaceType: $SpacesTable.$converterspaceType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}space_type'],
        )!,
      ),
      budgetMode: $SpacesTable.$converterbudgetMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}budget_mode'],
        )!,
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      storageMode: $SpacesTable.$converterstorageMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}storage_mode'],
        )!,
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      maxMembers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_members'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      manualBalance: $SpacesTable.$convertermanualBalancen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}manual_balance'],
        ),
      ),
      manualBalanceUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}manual_balance_updated_at'],
      ),
      minSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_schema_version'],
      )!,
      feedOrderMode: $SpacesTable.$converterfeedOrderMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feed_order_mode'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SpaceType, String, String> $converterspaceType =
      const EnumNameConverter<SpaceType>(SpaceType.values);
  static JsonTypeConverter2<BudgetMode, String, String> $converterbudgetMode =
      const EnumNameConverter<BudgetMode>(BudgetMode.values);
  static JsonTypeConverter2<StorageMode, String, String> $converterstorageMode =
      const EnumNameConverter<StorageMode>(StorageMode.values);
  static JsonTypeConverter2<Decimal, String, String> $convertermanualBalance =
      const DecimalConverter();
  static JsonTypeConverter2<Decimal?, String?, String?>
  $convertermanualBalancen = JsonTypeConverter2.asNullable(
    $convertermanualBalance,
  );
  static JsonTypeConverter2<FeedOrderMode, String, String>
  $converterfeedOrderMode = const EnumNameConverter<FeedOrderMode>(
    FeedOrderMode.values,
  );
}

class Space extends DataClass implements Insertable<Space> {
  final String id;
  final String title;
  final SpaceType spaceType;
  final BudgetMode budgetMode;
  final String ownerId;

  /// Named storage_mode, not sync_status, to keep it distinct from the
  /// per-row sync state (spec 3.1).
  final StorageMode storageMode;

  /// Overrides the global default when resolving holidays (spec 5.1.1).
  final String? countryCode;

  /// One 'today' for every member, regardless of where they are
  /// (plan section 2, invariant 7).
  final String timezone;

  /// Frozen after the first record (spec 9.2).
  final String currencyCode;

  /// 0 disables invites. Null is reserved for 'no limit' and is written by a
  /// separate UPDATE rather than stored as 0 (spec 3.4).
  final int? maxMembers;

  /// Read-only local archive. Never uploaded.
  final bool isArchived;

  /// Flow's 'money I have now' (spec 4.6). Budget uses budget_target instead.
  final Decimal? manualBalance;
  final DateTime? manualBalanceUpdatedAt;

  /// Raised only with creator consent (spec 10.6, plan G6).
  final int minSchemaVersion;
  final FeedOrderMode feedOrderMode;
  final DateTime createdAt;
  const Space({
    required this.id,
    required this.title,
    required this.spaceType,
    required this.budgetMode,
    required this.ownerId,
    required this.storageMode,
    this.countryCode,
    required this.timezone,
    required this.currencyCode,
    this.maxMembers,
    required this.isArchived,
    this.manualBalance,
    this.manualBalanceUpdatedAt,
    required this.minSchemaVersion,
    required this.feedOrderMode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    {
      map['space_type'] = Variable<String>(
        $SpacesTable.$converterspaceType.toSql(spaceType),
      );
    }
    {
      map['budget_mode'] = Variable<String>(
        $SpacesTable.$converterbudgetMode.toSql(budgetMode),
      );
    }
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['storage_mode'] = Variable<String>(
        $SpacesTable.$converterstorageMode.toSql(storageMode),
      );
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    map['timezone'] = Variable<String>(timezone);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || maxMembers != null) {
      map['max_members'] = Variable<int>(maxMembers);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || manualBalance != null) {
      map['manual_balance'] = Variable<String>(
        $SpacesTable.$convertermanualBalancen.toSql(manualBalance),
      );
    }
    if (!nullToAbsent || manualBalanceUpdatedAt != null) {
      map['manual_balance_updated_at'] = Variable<DateTime>(
        manualBalanceUpdatedAt,
      );
    }
    map['min_schema_version'] = Variable<int>(minSchemaVersion);
    {
      map['feed_order_mode'] = Variable<String>(
        $SpacesTable.$converterfeedOrderMode.toSql(feedOrderMode),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      title: Value(title),
      spaceType: Value(spaceType),
      budgetMode: Value(budgetMode),
      ownerId: Value(ownerId),
      storageMode: Value(storageMode),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      timezone: Value(timezone),
      currencyCode: Value(currencyCode),
      maxMembers: maxMembers == null && nullToAbsent
          ? const Value.absent()
          : Value(maxMembers),
      isArchived: Value(isArchived),
      manualBalance: manualBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(manualBalance),
      manualBalanceUpdatedAt: manualBalanceUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(manualBalanceUpdatedAt),
      minSchemaVersion: Value(minSchemaVersion),
      feedOrderMode: Value(feedOrderMode),
      createdAt: Value(createdAt),
    );
  }

  factory Space.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Space(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      spaceType: $SpacesTable.$converterspaceType.fromJson(
        serializer.fromJson<String>(json['spaceType']),
      ),
      budgetMode: $SpacesTable.$converterbudgetMode.fromJson(
        serializer.fromJson<String>(json['budgetMode']),
      ),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      storageMode: $SpacesTable.$converterstorageMode.fromJson(
        serializer.fromJson<String>(json['storageMode']),
      ),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      timezone: serializer.fromJson<String>(json['timezone']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      maxMembers: serializer.fromJson<int?>(json['maxMembers']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      manualBalance: $SpacesTable.$convertermanualBalancen.fromJson(
        serializer.fromJson<String?>(json['manualBalance']),
      ),
      manualBalanceUpdatedAt: serializer.fromJson<DateTime?>(
        json['manualBalanceUpdatedAt'],
      ),
      minSchemaVersion: serializer.fromJson<int>(json['minSchemaVersion']),
      feedOrderMode: $SpacesTable.$converterfeedOrderMode.fromJson(
        serializer.fromJson<String>(json['feedOrderMode']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'spaceType': serializer.toJson<String>(
        $SpacesTable.$converterspaceType.toJson(spaceType),
      ),
      'budgetMode': serializer.toJson<String>(
        $SpacesTable.$converterbudgetMode.toJson(budgetMode),
      ),
      'ownerId': serializer.toJson<String>(ownerId),
      'storageMode': serializer.toJson<String>(
        $SpacesTable.$converterstorageMode.toJson(storageMode),
      ),
      'countryCode': serializer.toJson<String?>(countryCode),
      'timezone': serializer.toJson<String>(timezone),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'maxMembers': serializer.toJson<int?>(maxMembers),
      'isArchived': serializer.toJson<bool>(isArchived),
      'manualBalance': serializer.toJson<String?>(
        $SpacesTable.$convertermanualBalancen.toJson(manualBalance),
      ),
      'manualBalanceUpdatedAt': serializer.toJson<DateTime?>(
        manualBalanceUpdatedAt,
      ),
      'minSchemaVersion': serializer.toJson<int>(minSchemaVersion),
      'feedOrderMode': serializer.toJson<String>(
        $SpacesTable.$converterfeedOrderMode.toJson(feedOrderMode),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Space copyWith({
    String? id,
    String? title,
    SpaceType? spaceType,
    BudgetMode? budgetMode,
    String? ownerId,
    StorageMode? storageMode,
    Value<String?> countryCode = const Value.absent(),
    String? timezone,
    String? currencyCode,
    Value<int?> maxMembers = const Value.absent(),
    bool? isArchived,
    Value<Decimal?> manualBalance = const Value.absent(),
    Value<DateTime?> manualBalanceUpdatedAt = const Value.absent(),
    int? minSchemaVersion,
    FeedOrderMode? feedOrderMode,
    DateTime? createdAt,
  }) => Space(
    id: id ?? this.id,
    title: title ?? this.title,
    spaceType: spaceType ?? this.spaceType,
    budgetMode: budgetMode ?? this.budgetMode,
    ownerId: ownerId ?? this.ownerId,
    storageMode: storageMode ?? this.storageMode,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    timezone: timezone ?? this.timezone,
    currencyCode: currencyCode ?? this.currencyCode,
    maxMembers: maxMembers.present ? maxMembers.value : this.maxMembers,
    isArchived: isArchived ?? this.isArchived,
    manualBalance: manualBalance.present
        ? manualBalance.value
        : this.manualBalance,
    manualBalanceUpdatedAt: manualBalanceUpdatedAt.present
        ? manualBalanceUpdatedAt.value
        : this.manualBalanceUpdatedAt,
    minSchemaVersion: minSchemaVersion ?? this.minSchemaVersion,
    feedOrderMode: feedOrderMode ?? this.feedOrderMode,
    createdAt: createdAt ?? this.createdAt,
  );
  Space copyWithCompanion(SpacesCompanion data) {
    return Space(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      spaceType: data.spaceType.present ? data.spaceType.value : this.spaceType,
      budgetMode: data.budgetMode.present
          ? data.budgetMode.value
          : this.budgetMode,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      storageMode: data.storageMode.present
          ? data.storageMode.value
          : this.storageMode,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      maxMembers: data.maxMembers.present
          ? data.maxMembers.value
          : this.maxMembers,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      manualBalance: data.manualBalance.present
          ? data.manualBalance.value
          : this.manualBalance,
      manualBalanceUpdatedAt: data.manualBalanceUpdatedAt.present
          ? data.manualBalanceUpdatedAt.value
          : this.manualBalanceUpdatedAt,
      minSchemaVersion: data.minSchemaVersion.present
          ? data.minSchemaVersion.value
          : this.minSchemaVersion,
      feedOrderMode: data.feedOrderMode.present
          ? data.feedOrderMode.value
          : this.feedOrderMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Space(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('spaceType: $spaceType, ')
          ..write('budgetMode: $budgetMode, ')
          ..write('ownerId: $ownerId, ')
          ..write('storageMode: $storageMode, ')
          ..write('countryCode: $countryCode, ')
          ..write('timezone: $timezone, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('maxMembers: $maxMembers, ')
          ..write('isArchived: $isArchived, ')
          ..write('manualBalance: $manualBalance, ')
          ..write('manualBalanceUpdatedAt: $manualBalanceUpdatedAt, ')
          ..write('minSchemaVersion: $minSchemaVersion, ')
          ..write('feedOrderMode: $feedOrderMode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    spaceType,
    budgetMode,
    ownerId,
    storageMode,
    countryCode,
    timezone,
    currencyCode,
    maxMembers,
    isArchived,
    manualBalance,
    manualBalanceUpdatedAt,
    minSchemaVersion,
    feedOrderMode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Space &&
          other.id == this.id &&
          other.title == this.title &&
          other.spaceType == this.spaceType &&
          other.budgetMode == this.budgetMode &&
          other.ownerId == this.ownerId &&
          other.storageMode == this.storageMode &&
          other.countryCode == this.countryCode &&
          other.timezone == this.timezone &&
          other.currencyCode == this.currencyCode &&
          other.maxMembers == this.maxMembers &&
          other.isArchived == this.isArchived &&
          other.manualBalance == this.manualBalance &&
          other.manualBalanceUpdatedAt == this.manualBalanceUpdatedAt &&
          other.minSchemaVersion == this.minSchemaVersion &&
          other.feedOrderMode == this.feedOrderMode &&
          other.createdAt == this.createdAt);
}

class SpacesCompanion extends UpdateCompanion<Space> {
  final Value<String> id;
  final Value<String> title;
  final Value<SpaceType> spaceType;
  final Value<BudgetMode> budgetMode;
  final Value<String> ownerId;
  final Value<StorageMode> storageMode;
  final Value<String?> countryCode;
  final Value<String> timezone;
  final Value<String> currencyCode;
  final Value<int?> maxMembers;
  final Value<bool> isArchived;
  final Value<Decimal?> manualBalance;
  final Value<DateTime?> manualBalanceUpdatedAt;
  final Value<int> minSchemaVersion;
  final Value<FeedOrderMode> feedOrderMode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.spaceType = const Value.absent(),
    this.budgetMode = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.timezone = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.maxMembers = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.manualBalance = const Value.absent(),
    this.manualBalanceUpdatedAt = const Value.absent(),
    this.minSchemaVersion = const Value.absent(),
    this.feedOrderMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String title,
    required SpaceType spaceType,
    required BudgetMode budgetMode,
    required String ownerId,
    required StorageMode storageMode,
    this.countryCode = const Value.absent(),
    required String timezone,
    required String currencyCode,
    this.maxMembers = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.manualBalance = const Value.absent(),
    this.manualBalanceUpdatedAt = const Value.absent(),
    this.minSchemaVersion = const Value.absent(),
    this.feedOrderMode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       spaceType = Value(spaceType),
       budgetMode = Value(budgetMode),
       ownerId = Value(ownerId),
       storageMode = Value(storageMode),
       timezone = Value(timezone),
       currencyCode = Value(currencyCode),
       createdAt = Value(createdAt);
  static Insertable<Space> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? spaceType,
    Expression<String>? budgetMode,
    Expression<String>? ownerId,
    Expression<String>? storageMode,
    Expression<String>? countryCode,
    Expression<String>? timezone,
    Expression<String>? currencyCode,
    Expression<int>? maxMembers,
    Expression<bool>? isArchived,
    Expression<String>? manualBalance,
    Expression<DateTime>? manualBalanceUpdatedAt,
    Expression<int>? minSchemaVersion,
    Expression<String>? feedOrderMode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (spaceType != null) 'space_type': spaceType,
      if (budgetMode != null) 'budget_mode': budgetMode,
      if (ownerId != null) 'owner_id': ownerId,
      if (storageMode != null) 'storage_mode': storageMode,
      if (countryCode != null) 'country_code': countryCode,
      if (timezone != null) 'timezone': timezone,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (maxMembers != null) 'max_members': maxMembers,
      if (isArchived != null) 'is_archived': isArchived,
      if (manualBalance != null) 'manual_balance': manualBalance,
      if (manualBalanceUpdatedAt != null)
        'manual_balance_updated_at': manualBalanceUpdatedAt,
      if (minSchemaVersion != null) 'min_schema_version': minSchemaVersion,
      if (feedOrderMode != null) 'feed_order_mode': feedOrderMode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<SpaceType>? spaceType,
    Value<BudgetMode>? budgetMode,
    Value<String>? ownerId,
    Value<StorageMode>? storageMode,
    Value<String?>? countryCode,
    Value<String>? timezone,
    Value<String>? currencyCode,
    Value<int?>? maxMembers,
    Value<bool>? isArchived,
    Value<Decimal?>? manualBalance,
    Value<DateTime?>? manualBalanceUpdatedAt,
    Value<int>? minSchemaVersion,
    Value<FeedOrderMode>? feedOrderMode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SpacesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      spaceType: spaceType ?? this.spaceType,
      budgetMode: budgetMode ?? this.budgetMode,
      ownerId: ownerId ?? this.ownerId,
      storageMode: storageMode ?? this.storageMode,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      currencyCode: currencyCode ?? this.currencyCode,
      maxMembers: maxMembers ?? this.maxMembers,
      isArchived: isArchived ?? this.isArchived,
      manualBalance: manualBalance ?? this.manualBalance,
      manualBalanceUpdatedAt:
          manualBalanceUpdatedAt ?? this.manualBalanceUpdatedAt,
      minSchemaVersion: minSchemaVersion ?? this.minSchemaVersion,
      feedOrderMode: feedOrderMode ?? this.feedOrderMode,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (spaceType.present) {
      map['space_type'] = Variable<String>(
        $SpacesTable.$converterspaceType.toSql(spaceType.value),
      );
    }
    if (budgetMode.present) {
      map['budget_mode'] = Variable<String>(
        $SpacesTable.$converterbudgetMode.toSql(budgetMode.value),
      );
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(
        $SpacesTable.$converterstorageMode.toSql(storageMode.value),
      );
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (maxMembers.present) {
      map['max_members'] = Variable<int>(maxMembers.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (manualBalance.present) {
      map['manual_balance'] = Variable<String>(
        $SpacesTable.$convertermanualBalancen.toSql(manualBalance.value),
      );
    }
    if (manualBalanceUpdatedAt.present) {
      map['manual_balance_updated_at'] = Variable<DateTime>(
        manualBalanceUpdatedAt.value,
      );
    }
    if (minSchemaVersion.present) {
      map['min_schema_version'] = Variable<int>(minSchemaVersion.value);
    }
    if (feedOrderMode.present) {
      map['feed_order_mode'] = Variable<String>(
        $SpacesTable.$converterfeedOrderMode.toSql(feedOrderMode.value),
      );
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
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('spaceType: $spaceType, ')
          ..write('budgetMode: $budgetMode, ')
          ..write('ownerId: $ownerId, ')
          ..write('storageMode: $storageMode, ')
          ..write('countryCode: $countryCode, ')
          ..write('timezone: $timezone, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('maxMembers: $maxMembers, ')
          ..write('isArchived: $isArchived, ')
          ..write('manualBalance: $manualBalance, ')
          ..write('manualBalanceUpdatedAt: $manualBalanceUpdatedAt, ')
          ..write('minSchemaVersion: $minSchemaVersion, ')
          ..write('feedOrderMode: $feedOrderMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpaceMembersTable extends SpaceMembers
    with TableInfo<$SpaceMembersTable, SpaceMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [spaceId, userId, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {spaceId, userId};
  @override
  SpaceMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceMember(
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $SpaceMembersTable createAlias(String alias) {
    return $SpaceMembersTable(attachedDatabase, alias);
  }
}

class SpaceMember extends DataClass implements Insertable<SpaceMember> {
  final String spaceId;
  final String userId;
  final DateTime joinedAt;
  const SpaceMember({
    required this.spaceId,
    required this.userId,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['space_id'] = Variable<String>(spaceId);
    map['user_id'] = Variable<String>(userId);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  SpaceMembersCompanion toCompanion(bool nullToAbsent) {
    return SpaceMembersCompanion(
      spaceId: Value(spaceId),
      userId: Value(userId),
      joinedAt: Value(joinedAt),
    );
  }

  factory SpaceMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceMember(
      spaceId: serializer.fromJson<String>(json['spaceId']),
      userId: serializer.fromJson<String>(json['userId']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'spaceId': serializer.toJson<String>(spaceId),
      'userId': serializer.toJson<String>(userId),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  SpaceMember copyWith({String? spaceId, String? userId, DateTime? joinedAt}) =>
      SpaceMember(
        spaceId: spaceId ?? this.spaceId,
        userId: userId ?? this.userId,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  SpaceMember copyWithCompanion(SpaceMembersCompanion data) {
    return SpaceMember(
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpaceMember(')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(spaceId, userId, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceMember &&
          other.spaceId == this.spaceId &&
          other.userId == this.userId &&
          other.joinedAt == this.joinedAt);
}

class SpaceMembersCompanion extends UpdateCompanion<SpaceMember> {
  final Value<String> spaceId;
  final Value<String> userId;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const SpaceMembersCompanion({
    this.spaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpaceMembersCompanion.insert({
    required String spaceId,
    required String userId,
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  }) : spaceId = Value(spaceId),
       userId = Value(userId),
       joinedAt = Value(joinedAt);
  static Insertable<SpaceMember> custom({
    Expression<String>? spaceId,
    Expression<String>? userId,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (spaceId != null) 'space_id': spaceId,
      if (userId != null) 'user_id': userId,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpaceMembersCompanion copyWith({
    Value<String>? spaceId,
    Value<String>? userId,
    Value<DateTime>? joinedAt,
    Value<int>? rowid,
  }) {
    return SpaceMembersCompanion(
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpaceMembersCompanion(')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemberLocalLabelsTable extends MemberLocalLabels
    with TableInfo<$MemberLocalLabelsTable, MemberLocalLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberLocalLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>($MemberLocalLabelsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _viewerUserIdMeta = const VerificationMeta(
    'viewerUserId',
  );
  @override
  late final GeneratedColumn<String> viewerUserId = GeneratedColumn<String>(
    'viewer_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetUserIdMeta = const VerificationMeta(
    'targetUserId',
  );
  @override
  late final GeneratedColumn<String> targetUserId = GeneratedColumn<String>(
    'target_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localNameMeta = const VerificationMeta(
    'localName',
  );
  @override
  late final GeneratedColumn<String> localName = GeneratedColumn<String>(
    'local_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRoleMeta = const VerificationMeta(
    'localRole',
  );
  @override
  late final GeneratedColumn<String> localRole = GeneratedColumn<String>(
    'local_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    spaceId,
    viewerUserId,
    targetUserId,
    localName,
    localRole,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_local_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberLocalLabel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('viewer_user_id')) {
      context.handle(
        _viewerUserIdMeta,
        viewerUserId.isAcceptableOrUnknown(
          data['viewer_user_id']!,
          _viewerUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_viewerUserIdMeta);
    }
    if (data.containsKey('target_user_id')) {
      context.handle(
        _targetUserIdMeta,
        targetUserId.isAcceptableOrUnknown(
          data['target_user_id']!,
          _targetUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetUserIdMeta);
    }
    if (data.containsKey('local_name')) {
      context.handle(
        _localNameMeta,
        localName.isAcceptableOrUnknown(data['local_name']!, _localNameMeta),
      );
    }
    if (data.containsKey('local_role')) {
      context.handle(
        _localRoleMeta,
        localRole.isAcceptableOrUnknown(data['local_role']!, _localRoleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {spaceId, viewerUserId, targetUserId};
  @override
  MemberLocalLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberLocalLabel(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $MemberLocalLabelsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      viewerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewer_user_id'],
      )!,
      targetUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_user_id'],
      )!,
      localName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_name'],
      ),
      localRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_role'],
      ),
    );
  }

  @override
  $MemberLocalLabelsTable createAlias(String alias) {
    return $MemberLocalLabelsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class MemberLocalLabel extends DataClass
    implements Insertable<MemberLocalLabel> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String spaceId;
  final String viewerUserId;
  final String targetUserId;
  final String? localName;
  final String? localRole;
  const MemberLocalLabel({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.spaceId,
    required this.viewerUserId,
    required this.targetUserId,
    this.localName,
    this.localRole,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $MemberLocalLabelsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['space_id'] = Variable<String>(spaceId);
    map['viewer_user_id'] = Variable<String>(viewerUserId);
    map['target_user_id'] = Variable<String>(targetUserId);
    if (!nullToAbsent || localName != null) {
      map['local_name'] = Variable<String>(localName);
    }
    if (!nullToAbsent || localRole != null) {
      map['local_role'] = Variable<String>(localRole);
    }
    return map;
  }

  MemberLocalLabelsCompanion toCompanion(bool nullToAbsent) {
    return MemberLocalLabelsCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      spaceId: Value(spaceId),
      viewerUserId: Value(viewerUserId),
      targetUserId: Value(targetUserId),
      localName: localName == null && nullToAbsent
          ? const Value.absent()
          : Value(localName),
      localRole: localRole == null && nullToAbsent
          ? const Value.absent()
          : Value(localRole),
    );
  }

  factory MemberLocalLabel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberLocalLabel(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $MemberLocalLabelsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      viewerUserId: serializer.fromJson<String>(json['viewerUserId']),
      targetUserId: serializer.fromJson<String>(json['targetUserId']),
      localName: serializer.fromJson<String?>(json['localName']),
      localRole: serializer.fromJson<String?>(json['localRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $MemberLocalLabelsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'spaceId': serializer.toJson<String>(spaceId),
      'viewerUserId': serializer.toJson<String>(viewerUserId),
      'targetUserId': serializer.toJson<String>(targetUserId),
      'localName': serializer.toJson<String?>(localName),
      'localRole': serializer.toJson<String?>(localRole),
    };
  }

  MemberLocalLabel copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? spaceId,
    String? viewerUserId,
    String? targetUserId,
    Value<String?> localName = const Value.absent(),
    Value<String?> localRole = const Value.absent(),
  }) => MemberLocalLabel(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    spaceId: spaceId ?? this.spaceId,
    viewerUserId: viewerUserId ?? this.viewerUserId,
    targetUserId: targetUserId ?? this.targetUserId,
    localName: localName.present ? localName.value : this.localName,
    localRole: localRole.present ? localRole.value : this.localRole,
  );
  MemberLocalLabel copyWithCompanion(MemberLocalLabelsCompanion data) {
    return MemberLocalLabel(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      viewerUserId: data.viewerUserId.present
          ? data.viewerUserId.value
          : this.viewerUserId,
      targetUserId: data.targetUserId.present
          ? data.targetUserId.value
          : this.targetUserId,
      localName: data.localName.present ? data.localName.value : this.localName,
      localRole: data.localRole.present ? data.localRole.value : this.localRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberLocalLabel(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('spaceId: $spaceId, ')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('localName: $localName, ')
          ..write('localRole: $localRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    spaceId,
    viewerUserId,
    targetUserId,
    localName,
    localRole,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberLocalLabel &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.spaceId == this.spaceId &&
          other.viewerUserId == this.viewerUserId &&
          other.targetUserId == this.targetUserId &&
          other.localName == this.localName &&
          other.localRole == this.localRole);
}

class MemberLocalLabelsCompanion extends UpdateCompanion<MemberLocalLabel> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> spaceId;
  final Value<String> viewerUserId;
  final Value<String> targetUserId;
  final Value<String?> localName;
  final Value<String?> localRole;
  final Value<int> rowid;
  const MemberLocalLabelsCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.viewerUserId = const Value.absent(),
    this.targetUserId = const Value.absent(),
    this.localName = const Value.absent(),
    this.localRole = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberLocalLabelsCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String spaceId,
    required String viewerUserId,
    required String targetUserId,
    this.localName = const Value.absent(),
    this.localRole = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       spaceId = Value(spaceId),
       viewerUserId = Value(viewerUserId),
       targetUserId = Value(targetUserId);
  static Insertable<MemberLocalLabel> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? spaceId,
    Expression<String>? viewerUserId,
    Expression<String>? targetUserId,
    Expression<String>? localName,
    Expression<String>? localRole,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (spaceId != null) 'space_id': spaceId,
      if (viewerUserId != null) 'viewer_user_id': viewerUserId,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (localName != null) 'local_name': localName,
      if (localRole != null) 'local_role': localRole,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberLocalLabelsCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? spaceId,
    Value<String>? viewerUserId,
    Value<String>? targetUserId,
    Value<String?>? localName,
    Value<String?>? localRole,
    Value<int>? rowid,
  }) {
    return MemberLocalLabelsCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      spaceId: spaceId ?? this.spaceId,
      viewerUserId: viewerUserId ?? this.viewerUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      localName: localName ?? this.localName,
      localRole: localRole ?? this.localRole,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $MemberLocalLabelsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (viewerUserId.present) {
      map['viewer_user_id'] = Variable<String>(viewerUserId.value);
    }
    if (targetUserId.present) {
      map['target_user_id'] = Variable<String>(targetUserId.value);
    }
    if (localName.present) {
      map['local_name'] = Variable<String>(localName.value);
    }
    if (localRole.present) {
      map['local_role'] = Variable<String>(localRole.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberLocalLabelsCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('spaceId: $spaceId, ')
          ..write('viewerUserId: $viewerUserId, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('localName: $localName, ')
          ..write('localRole: $localRole, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>($UserProfilesTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    userId,
    nickname,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $UserProfilesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String userId;
  final String nickname;
  const UserProfile({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.userId,
    required this.nickname,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $UserProfilesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['user_id'] = Variable<String>(userId);
    map['nickname'] = Variable<String>(nickname);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      userId: Value(userId),
      nickname: Value(nickname),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $UserProfilesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      userId: serializer.fromJson<String>(json['userId']),
      nickname: serializer.fromJson<String>(json['nickname']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $UserProfilesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'userId': serializer.toJson<String>(userId),
      'nickname': serializer.toJson<String>(nickname),
    };
  }

  UserProfile copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? userId,
    String? nickname,
  }) => UserProfile(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    userId: userId ?? this.userId,
    nickname: nickname ?? this.nickname,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    userId,
    nickname,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.userId == this.userId &&
          other.nickname == this.nickname);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> userId;
  final Value<String> nickname;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String userId,
    required String nickname,
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       userId = Value(userId),
       nickname = Value(nickname);
  static Insertable<UserProfile> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? userId,
    Expression<String>? nickname,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (userId != null) 'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? userId,
    Value<String>? nickname,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $UserProfilesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>($CategoriesTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseType, String> expenseType =
      GeneratedColumn<String>(
        'expense_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('variable'),
      ).withConverter<ExpenseType>($CategoriesTable.$converterexpenseType);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    title,
    color,
    icon,
    expenseType,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $CategoriesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      expenseType: $CategoriesTable.$converterexpenseType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expense_type'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<ExpenseType, String, String> $converterexpenseType =
      const EnumNameConverter<ExpenseType>(ExpenseType.values);
}

class Category extends DataClass implements Insertable<Category> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String id;
  final String spaceId;
  final String title;
  final String? color;
  final String? icon;

  /// Default for new payments only. Existing rows keep their own value.
  final ExpenseType expenseType;
  final int sortOrder;
  final DateTime createdAt;
  const Category({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.id,
    required this.spaceId,
    required this.title,
    this.color,
    this.icon,
    required this.expenseType,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $CategoriesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    {
      map['expense_type'] = Variable<String>(
        $CategoriesTable.$converterexpenseType.toSql(expenseType),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      id: Value(id),
      spaceId: Value(spaceId),
      title: Value(title),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      expenseType: Value(expenseType),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $CategoriesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      title: serializer.fromJson<String>(json['title']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      expenseType: $CategoriesTable.$converterexpenseType.fromJson(
        serializer.fromJson<String>(json['expenseType']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $CategoriesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'title': serializer.toJson<String>(title),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'expenseType': serializer.toJson<String>(
        $CategoriesTable.$converterexpenseType.toJson(expenseType),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? id,
    String? spaceId,
    String? title,
    Value<String?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    ExpenseType? expenseType,
    int? sortOrder,
    DateTime? createdAt,
  }) => Category(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    title: title ?? this.title,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
    expenseType: expenseType ?? this.expenseType,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      title: data.title.present ? data.title.value : this.title,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      expenseType: data.expenseType.present
          ? data.expenseType.value
          : this.expenseType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('expenseType: $expenseType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    title,
    color,
    icon,
    expenseType,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.title == this.title &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.expenseType == this.expenseType &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> title;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<ExpenseType> expenseType;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.expenseType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String id,
    required String spaceId,
    required String title,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.expenseType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       id = Value(id),
       spaceId = Value(spaceId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? title,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<String>? expenseType,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (title != null) 'title': title,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (expenseType != null) 'expense_type': expenseType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? title,
    Value<String?>? color,
    Value<String?>? icon,
    Value<ExpenseType>? expenseType,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      expenseType: expenseType ?? this.expenseType,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $CategoriesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (expenseType.present) {
      map['expense_type'] = Variable<String>(
        $CategoriesTable.$converterexpenseType.toSql(expenseType.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('CategoriesCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('expenseType: $expenseType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetPeriodsTable extends BudgetPeriods
    with TableInfo<$BudgetPeriodsTable, BudgetPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>($BudgetPeriodsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PeriodType, String> periodType =
      GeneratedColumn<String>(
        'period_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PeriodType>($BudgetPeriodsTable.$converterperiodType);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($BudgetPeriodsTable.$converterstartDate);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>($BudgetPeriodsTable.$converterendDaten);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  windowStart = GeneratedColumn<String>(
    'window_start',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CalendarDate?>($BudgetPeriodsTable.$converterwindowStartn);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> windowEnd =
      GeneratedColumn<String>(
        'window_end',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>($BudgetPeriodsTable.$converterwindowEndn);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  anchorDate = GeneratedColumn<String>(
    'anchor_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CalendarDate?>($BudgetPeriodsTable.$converteranchorDaten);
  static const VerificationMeta _holidayDataIncompleteMeta =
      const VerificationMeta('holidayDataIncomplete');
  @override
  late final GeneratedColumn<bool> holidayDataIncomplete =
      GeneratedColumn<bool>(
        'holiday_data_incomplete',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("holiday_data_incomplete" IN (0, 1))',
        ),
        defaultValue: const Constant<bool>(false),
      );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  deadlineDate = GeneratedColumn<String>(
    'deadline_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CalendarDate?>($BudgetPeriodsTable.$converterdeadlineDaten);
  static const VerificationMeta _deadlineIsHardMeta = const VerificationMeta(
    'deadlineIsHard',
  );
  @override
  late final GeneratedColumn<bool> deadlineIsHard = GeneratedColumn<bool>(
    'deadline_is_hard',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deadline_is_hard" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> budgetTarget =
      GeneratedColumn<String>(
        'budget_target',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($BudgetPeriodsTable.$converterbudgetTargetn);
  static const VerificationMeta _unfrozenUntilMeta = const VerificationMeta(
    'unfrozenUntil',
  );
  @override
  late final GeneratedColumn<DateTime> unfrozenUntil =
      GeneratedColumn<DateTime>(
        'unfrozen_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unfreezeReasonMeta = const VerificationMeta(
    'unfreezeReason',
  );
  @override
  late final GeneratedColumn<String> unfreezeReason = GeneratedColumn<String>(
    'unfreeze_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    periodType,
    startDate,
    endDate,
    windowStart,
    windowEnd,
    anchorDate,
    holidayDataIncomplete,
    deadlineDate,
    deadlineIsHard,
    budgetTarget,
    unfrozenUntil,
    unfreezeReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('holiday_data_incomplete')) {
      context.handle(
        _holidayDataIncompleteMeta,
        holidayDataIncomplete.isAcceptableOrUnknown(
          data['holiday_data_incomplete']!,
          _holidayDataIncompleteMeta,
        ),
      );
    }
    if (data.containsKey('deadline_is_hard')) {
      context.handle(
        _deadlineIsHardMeta,
        deadlineIsHard.isAcceptableOrUnknown(
          data['deadline_is_hard']!,
          _deadlineIsHardMeta,
        ),
      );
    }
    if (data.containsKey('unfrozen_until')) {
      context.handle(
        _unfrozenUntilMeta,
        unfrozenUntil.isAcceptableOrUnknown(
          data['unfrozen_until']!,
          _unfrozenUntilMeta,
        ),
      );
    }
    if (data.containsKey('unfreeze_reason')) {
      context.handle(
        _unfreezeReasonMeta,
        unfreezeReason.isAcceptableOrUnknown(
          data['unfreeze_reason']!,
          _unfreezeReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetPeriod(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $BudgetPeriodsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      periodType: $BudgetPeriodsTable.$converterperiodType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}period_type'],
        )!,
      ),
      startDate: $BudgetPeriodsTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $BudgetPeriodsTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
      windowStart: $BudgetPeriodsTable.$converterwindowStartn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}window_start'],
        ),
      ),
      windowEnd: $BudgetPeriodsTable.$converterwindowEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}window_end'],
        ),
      ),
      anchorDate: $BudgetPeriodsTable.$converteranchorDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}anchor_date'],
        ),
      ),
      holidayDataIncomplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}holiday_data_incomplete'],
      )!,
      deadlineDate: $BudgetPeriodsTable.$converterdeadlineDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deadline_date'],
        ),
      ),
      deadlineIsHard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deadline_is_hard'],
      )!,
      budgetTarget: $BudgetPeriodsTable.$converterbudgetTargetn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}budget_target'],
        ),
      ),
      unfrozenUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unfrozen_until'],
      ),
      unfreezeReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unfreeze_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BudgetPeriodsTable createAlias(String alias) {
    return $BudgetPeriodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<PeriodType, String, String> $converterperiodType =
      const EnumNameConverter<PeriodType>(PeriodType.values);
  static JsonTypeConverter2<CalendarDate, String, String> $converterstartDate =
      const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate, String, String> $converterendDate =
      const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate?, String?, String?>
  $converterendDaten = JsonTypeConverter2.asNullable($converterendDate);
  static JsonTypeConverter2<CalendarDate, String, String>
  $converterwindowStart = const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate?, String?, String?>
  $converterwindowStartn = JsonTypeConverter2.asNullable($converterwindowStart);
  static JsonTypeConverter2<CalendarDate, String, String> $converterwindowEnd =
      const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate?, String?, String?>
  $converterwindowEndn = JsonTypeConverter2.asNullable($converterwindowEnd);
  static JsonTypeConverter2<CalendarDate, String, String> $converteranchorDate =
      const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate?, String?, String?>
  $converteranchorDaten = JsonTypeConverter2.asNullable($converteranchorDate);
  static JsonTypeConverter2<CalendarDate, String, String>
  $converterdeadlineDate = const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate?, String?, String?>
  $converterdeadlineDaten = JsonTypeConverter2.asNullable(
    $converterdeadlineDate,
  );
  static JsonTypeConverter2<Decimal, String, String> $converterbudgetTarget =
      const DecimalConverter();
  static JsonTypeConverter2<Decimal?, String?, String?>
  $converterbudgetTargetn = JsonTypeConverter2.asNullable(
    $converterbudgetTarget,
  );
}

class BudgetPeriod extends DataClass implements Insertable<BudgetPeriod> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String id;
  final String spaceId;
  final PeriodType periodType;
  final CalendarDate startDate;

  /// Null for `continuous`: the context never closes.
  final CalendarDate? endDate;

  /// Anchor income uncertainty window (spec 5.1.1). Null for `continuous`.
  final CalendarDate? windowStart;
  final CalendarDate? windowEnd;

  /// resolveIncomeWindow's result, stored rather than recomputed per render.
  final CalendarDate? anchorDate;

  /// The window was computed without holiday data and may still narrow.
  final bool holidayDataIncomplete;

  /// Budget mode's event date (spec 4.8). Null elsewhere.
  final CalendarDate? deadlineDate;
  final bool deadlineIsHard;
  final Decimal? budgetTarget;

  /// Temporary unfreeze of a closed period (spec 5.5).
  final DateTime? unfrozenUntil;
  final String? unfreezeReason;
  final DateTime createdAt;
  const BudgetPeriod({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.id,
    required this.spaceId,
    required this.periodType,
    required this.startDate,
    this.endDate,
    this.windowStart,
    this.windowEnd,
    this.anchorDate,
    required this.holidayDataIncomplete,
    this.deadlineDate,
    required this.deadlineIsHard,
    this.budgetTarget,
    this.unfrozenUntil,
    this.unfreezeReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $BudgetPeriodsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    {
      map['period_type'] = Variable<String>(
        $BudgetPeriodsTable.$converterperiodType.toSql(periodType),
      );
    }
    {
      map['start_date'] = Variable<String>(
        $BudgetPeriodsTable.$converterstartDate.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $BudgetPeriodsTable.$converterendDaten.toSql(endDate),
      );
    }
    if (!nullToAbsent || windowStart != null) {
      map['window_start'] = Variable<String>(
        $BudgetPeriodsTable.$converterwindowStartn.toSql(windowStart),
      );
    }
    if (!nullToAbsent || windowEnd != null) {
      map['window_end'] = Variable<String>(
        $BudgetPeriodsTable.$converterwindowEndn.toSql(windowEnd),
      );
    }
    if (!nullToAbsent || anchorDate != null) {
      map['anchor_date'] = Variable<String>(
        $BudgetPeriodsTable.$converteranchorDaten.toSql(anchorDate),
      );
    }
    map['holiday_data_incomplete'] = Variable<bool>(holidayDataIncomplete);
    if (!nullToAbsent || deadlineDate != null) {
      map['deadline_date'] = Variable<String>(
        $BudgetPeriodsTable.$converterdeadlineDaten.toSql(deadlineDate),
      );
    }
    map['deadline_is_hard'] = Variable<bool>(deadlineIsHard);
    if (!nullToAbsent || budgetTarget != null) {
      map['budget_target'] = Variable<String>(
        $BudgetPeriodsTable.$converterbudgetTargetn.toSql(budgetTarget),
      );
    }
    if (!nullToAbsent || unfrozenUntil != null) {
      map['unfrozen_until'] = Variable<DateTime>(unfrozenUntil);
    }
    if (!nullToAbsent || unfreezeReason != null) {
      map['unfreeze_reason'] = Variable<String>(unfreezeReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetPeriodsCompanion toCompanion(bool nullToAbsent) {
    return BudgetPeriodsCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      id: Value(id),
      spaceId: Value(spaceId),
      periodType: Value(periodType),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      windowStart: windowStart == null && nullToAbsent
          ? const Value.absent()
          : Value(windowStart),
      windowEnd: windowEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(windowEnd),
      anchorDate: anchorDate == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorDate),
      holidayDataIncomplete: Value(holidayDataIncomplete),
      deadlineDate: deadlineDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineDate),
      deadlineIsHard: Value(deadlineIsHard),
      budgetTarget: budgetTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetTarget),
      unfrozenUntil: unfrozenUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(unfrozenUntil),
      unfreezeReason: unfreezeReason == null && nullToAbsent
          ? const Value.absent()
          : Value(unfreezeReason),
      createdAt: Value(createdAt),
    );
  }

  factory BudgetPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetPeriod(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $BudgetPeriodsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      periodType: $BudgetPeriodsTable.$converterperiodType.fromJson(
        serializer.fromJson<String>(json['periodType']),
      ),
      startDate: $BudgetPeriodsTable.$converterstartDate.fromJson(
        serializer.fromJson<String>(json['startDate']),
      ),
      endDate: $BudgetPeriodsTable.$converterendDaten.fromJson(
        serializer.fromJson<String?>(json['endDate']),
      ),
      windowStart: $BudgetPeriodsTable.$converterwindowStartn.fromJson(
        serializer.fromJson<String?>(json['windowStart']),
      ),
      windowEnd: $BudgetPeriodsTable.$converterwindowEndn.fromJson(
        serializer.fromJson<String?>(json['windowEnd']),
      ),
      anchorDate: $BudgetPeriodsTable.$converteranchorDaten.fromJson(
        serializer.fromJson<String?>(json['anchorDate']),
      ),
      holidayDataIncomplete: serializer.fromJson<bool>(
        json['holidayDataIncomplete'],
      ),
      deadlineDate: $BudgetPeriodsTable.$converterdeadlineDaten.fromJson(
        serializer.fromJson<String?>(json['deadlineDate']),
      ),
      deadlineIsHard: serializer.fromJson<bool>(json['deadlineIsHard']),
      budgetTarget: $BudgetPeriodsTable.$converterbudgetTargetn.fromJson(
        serializer.fromJson<String?>(json['budgetTarget']),
      ),
      unfrozenUntil: serializer.fromJson<DateTime?>(json['unfrozenUntil']),
      unfreezeReason: serializer.fromJson<String?>(json['unfreezeReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $BudgetPeriodsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'periodType': serializer.toJson<String>(
        $BudgetPeriodsTable.$converterperiodType.toJson(periodType),
      ),
      'startDate': serializer.toJson<String>(
        $BudgetPeriodsTable.$converterstartDate.toJson(startDate),
      ),
      'endDate': serializer.toJson<String?>(
        $BudgetPeriodsTable.$converterendDaten.toJson(endDate),
      ),
      'windowStart': serializer.toJson<String?>(
        $BudgetPeriodsTable.$converterwindowStartn.toJson(windowStart),
      ),
      'windowEnd': serializer.toJson<String?>(
        $BudgetPeriodsTable.$converterwindowEndn.toJson(windowEnd),
      ),
      'anchorDate': serializer.toJson<String?>(
        $BudgetPeriodsTable.$converteranchorDaten.toJson(anchorDate),
      ),
      'holidayDataIncomplete': serializer.toJson<bool>(holidayDataIncomplete),
      'deadlineDate': serializer.toJson<String?>(
        $BudgetPeriodsTable.$converterdeadlineDaten.toJson(deadlineDate),
      ),
      'deadlineIsHard': serializer.toJson<bool>(deadlineIsHard),
      'budgetTarget': serializer.toJson<String?>(
        $BudgetPeriodsTable.$converterbudgetTargetn.toJson(budgetTarget),
      ),
      'unfrozenUntil': serializer.toJson<DateTime?>(unfrozenUntil),
      'unfreezeReason': serializer.toJson<String?>(unfreezeReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BudgetPeriod copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? id,
    String? spaceId,
    PeriodType? periodType,
    CalendarDate? startDate,
    Value<CalendarDate?> endDate = const Value.absent(),
    Value<CalendarDate?> windowStart = const Value.absent(),
    Value<CalendarDate?> windowEnd = const Value.absent(),
    Value<CalendarDate?> anchorDate = const Value.absent(),
    bool? holidayDataIncomplete,
    Value<CalendarDate?> deadlineDate = const Value.absent(),
    bool? deadlineIsHard,
    Value<Decimal?> budgetTarget = const Value.absent(),
    Value<DateTime?> unfrozenUntil = const Value.absent(),
    Value<String?> unfreezeReason = const Value.absent(),
    DateTime? createdAt,
  }) => BudgetPeriod(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    periodType: periodType ?? this.periodType,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    windowStart: windowStart.present ? windowStart.value : this.windowStart,
    windowEnd: windowEnd.present ? windowEnd.value : this.windowEnd,
    anchorDate: anchorDate.present ? anchorDate.value : this.anchorDate,
    holidayDataIncomplete: holidayDataIncomplete ?? this.holidayDataIncomplete,
    deadlineDate: deadlineDate.present ? deadlineDate.value : this.deadlineDate,
    deadlineIsHard: deadlineIsHard ?? this.deadlineIsHard,
    budgetTarget: budgetTarget.present ? budgetTarget.value : this.budgetTarget,
    unfrozenUntil: unfrozenUntil.present
        ? unfrozenUntil.value
        : this.unfrozenUntil,
    unfreezeReason: unfreezeReason.present
        ? unfreezeReason.value
        : this.unfreezeReason,
    createdAt: createdAt ?? this.createdAt,
  );
  BudgetPeriod copyWithCompanion(BudgetPeriodsCompanion data) {
    return BudgetPeriod(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      periodType: data.periodType.present
          ? data.periodType.value
          : this.periodType,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      windowStart: data.windowStart.present
          ? data.windowStart.value
          : this.windowStart,
      windowEnd: data.windowEnd.present ? data.windowEnd.value : this.windowEnd,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      holidayDataIncomplete: data.holidayDataIncomplete.present
          ? data.holidayDataIncomplete.value
          : this.holidayDataIncomplete,
      deadlineDate: data.deadlineDate.present
          ? data.deadlineDate.value
          : this.deadlineDate,
      deadlineIsHard: data.deadlineIsHard.present
          ? data.deadlineIsHard.value
          : this.deadlineIsHard,
      budgetTarget: data.budgetTarget.present
          ? data.budgetTarget.value
          : this.budgetTarget,
      unfrozenUntil: data.unfrozenUntil.present
          ? data.unfrozenUntil.value
          : this.unfrozenUntil,
      unfreezeReason: data.unfreezeReason.present
          ? data.unfreezeReason.value
          : this.unfreezeReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetPeriod(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('periodType: $periodType, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('holidayDataIncomplete: $holidayDataIncomplete, ')
          ..write('deadlineDate: $deadlineDate, ')
          ..write('deadlineIsHard: $deadlineIsHard, ')
          ..write('budgetTarget: $budgetTarget, ')
          ..write('unfrozenUntil: $unfrozenUntil, ')
          ..write('unfreezeReason: $unfreezeReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    periodType,
    startDate,
    endDate,
    windowStart,
    windowEnd,
    anchorDate,
    holidayDataIncomplete,
    deadlineDate,
    deadlineIsHard,
    budgetTarget,
    unfrozenUntil,
    unfreezeReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetPeriod &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.periodType == this.periodType &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.windowStart == this.windowStart &&
          other.windowEnd == this.windowEnd &&
          other.anchorDate == this.anchorDate &&
          other.holidayDataIncomplete == this.holidayDataIncomplete &&
          other.deadlineDate == this.deadlineDate &&
          other.deadlineIsHard == this.deadlineIsHard &&
          other.budgetTarget == this.budgetTarget &&
          other.unfrozenUntil == this.unfrozenUntil &&
          other.unfreezeReason == this.unfreezeReason &&
          other.createdAt == this.createdAt);
}

class BudgetPeriodsCompanion extends UpdateCompanion<BudgetPeriod> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> id;
  final Value<String> spaceId;
  final Value<PeriodType> periodType;
  final Value<CalendarDate> startDate;
  final Value<CalendarDate?> endDate;
  final Value<CalendarDate?> windowStart;
  final Value<CalendarDate?> windowEnd;
  final Value<CalendarDate?> anchorDate;
  final Value<bool> holidayDataIncomplete;
  final Value<CalendarDate?> deadlineDate;
  final Value<bool> deadlineIsHard;
  final Value<Decimal?> budgetTarget;
  final Value<DateTime?> unfrozenUntil;
  final Value<String?> unfreezeReason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BudgetPeriodsCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.periodType = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.windowStart = const Value.absent(),
    this.windowEnd = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.holidayDataIncomplete = const Value.absent(),
    this.deadlineDate = const Value.absent(),
    this.deadlineIsHard = const Value.absent(),
    this.budgetTarget = const Value.absent(),
    this.unfrozenUntil = const Value.absent(),
    this.unfreezeReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetPeriodsCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String id,
    required String spaceId,
    required PeriodType periodType,
    required CalendarDate startDate,
    this.endDate = const Value.absent(),
    this.windowStart = const Value.absent(),
    this.windowEnd = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.holidayDataIncomplete = const Value.absent(),
    this.deadlineDate = const Value.absent(),
    this.deadlineIsHard = const Value.absent(),
    this.budgetTarget = const Value.absent(),
    this.unfrozenUntil = const Value.absent(),
    this.unfreezeReason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       id = Value(id),
       spaceId = Value(spaceId),
       periodType = Value(periodType),
       startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<BudgetPeriod> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? periodType,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? windowStart,
    Expression<String>? windowEnd,
    Expression<String>? anchorDate,
    Expression<bool>? holidayDataIncomplete,
    Expression<String>? deadlineDate,
    Expression<bool>? deadlineIsHard,
    Expression<String>? budgetTarget,
    Expression<DateTime>? unfrozenUntil,
    Expression<String>? unfreezeReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (periodType != null) 'period_type': periodType,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (windowStart != null) 'window_start': windowStart,
      if (windowEnd != null) 'window_end': windowEnd,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (holidayDataIncomplete != null)
        'holiday_data_incomplete': holidayDataIncomplete,
      if (deadlineDate != null) 'deadline_date': deadlineDate,
      if (deadlineIsHard != null) 'deadline_is_hard': deadlineIsHard,
      if (budgetTarget != null) 'budget_target': budgetTarget,
      if (unfrozenUntil != null) 'unfrozen_until': unfrozenUntil,
      if (unfreezeReason != null) 'unfreeze_reason': unfreezeReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetPeriodsCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? id,
    Value<String>? spaceId,
    Value<PeriodType>? periodType,
    Value<CalendarDate>? startDate,
    Value<CalendarDate?>? endDate,
    Value<CalendarDate?>? windowStart,
    Value<CalendarDate?>? windowEnd,
    Value<CalendarDate?>? anchorDate,
    Value<bool>? holidayDataIncomplete,
    Value<CalendarDate?>? deadlineDate,
    Value<bool>? deadlineIsHard,
    Value<Decimal?>? budgetTarget,
    Value<DateTime?>? unfrozenUntil,
    Value<String?>? unfreezeReason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BudgetPeriodsCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      anchorDate: anchorDate ?? this.anchorDate,
      holidayDataIncomplete:
          holidayDataIncomplete ?? this.holidayDataIncomplete,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      deadlineIsHard: deadlineIsHard ?? this.deadlineIsHard,
      budgetTarget: budgetTarget ?? this.budgetTarget,
      unfrozenUntil: unfrozenUntil ?? this.unfrozenUntil,
      unfreezeReason: unfreezeReason ?? this.unfreezeReason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $BudgetPeriodsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(
        $BudgetPeriodsTable.$converterperiodType.toSql(periodType.value),
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $BudgetPeriodsTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $BudgetPeriodsTable.$converterendDaten.toSql(endDate.value),
      );
    }
    if (windowStart.present) {
      map['window_start'] = Variable<String>(
        $BudgetPeriodsTable.$converterwindowStartn.toSql(windowStart.value),
      );
    }
    if (windowEnd.present) {
      map['window_end'] = Variable<String>(
        $BudgetPeriodsTable.$converterwindowEndn.toSql(windowEnd.value),
      );
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<String>(
        $BudgetPeriodsTable.$converteranchorDaten.toSql(anchorDate.value),
      );
    }
    if (holidayDataIncomplete.present) {
      map['holiday_data_incomplete'] = Variable<bool>(
        holidayDataIncomplete.value,
      );
    }
    if (deadlineDate.present) {
      map['deadline_date'] = Variable<String>(
        $BudgetPeriodsTable.$converterdeadlineDaten.toSql(deadlineDate.value),
      );
    }
    if (deadlineIsHard.present) {
      map['deadline_is_hard'] = Variable<bool>(deadlineIsHard.value);
    }
    if (budgetTarget.present) {
      map['budget_target'] = Variable<String>(
        $BudgetPeriodsTable.$converterbudgetTargetn.toSql(budgetTarget.value),
      );
    }
    if (unfrozenUntil.present) {
      map['unfrozen_until'] = Variable<DateTime>(unfrozenUntil.value);
    }
    if (unfreezeReason.present) {
      map['unfreeze_reason'] = Variable<String>(unfreezeReason.value);
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
    return (StringBuffer('BudgetPeriodsCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('periodType: $periodType, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('holidayDataIncomplete: $holidayDataIncomplete, ')
          ..write('deadlineDate: $deadlineDate, ')
          ..write('deadlineIsHard: $deadlineIsHard, ')
          ..write('budgetTarget: $budgetTarget, ')
          ..write('unfrozenUntil: $unfrozenUntil, ')
          ..write('unfreezeReason: $unfreezeReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeRecurrenceRulesTable extends IncomeRecurrenceRules
    with TableInfo<$IncomeRecurrenceRulesTable, IncomeRecurrenceRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeRecurrenceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>(
        $IncomeRecurrenceRulesTable.$convertersyncStatus,
      );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> amount =
      GeneratedColumn<String>(
        'amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($IncomeRecurrenceRulesTable.$converteramountn);
  static const VerificationMeta _isAnchorMeta = const VerificationMeta(
    'isAnchor',
  );
  @override
  late final GeneratedColumn<bool> isAnchor = GeneratedColumn<bool>(
    'is_anchor',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_anchor" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleType, String>
  scheduleType =
      GeneratedColumn<String>(
        'schedule_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ScheduleType>(
        $IncomeRecurrenceRulesTable.$converterscheduleType,
      );
  static const VerificationMeta _fixedDayMeta = const VerificationMeta(
    'fixedDay',
  );
  @override
  late final GeneratedColumn<int> fixedDay = GeneratedColumn<int>(
    'fixed_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeekdayOrdinal?, String>
  weekdayOrdinal =
      GeneratedColumn<String>(
        'weekday_ordinal',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<WeekdayOrdinal?>(
        $IncomeRecurrenceRulesTable.$converterweekdayOrdinaln,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Weekday?, String> weekdayDay =
      GeneratedColumn<String>(
        'weekday_day',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Weekday?>(
        $IncomeRecurrenceRulesTable.$converterweekdayDayn,
      );
  static const VerificationMeta _dateRangeStartMeta = const VerificationMeta(
    'dateRangeStart',
  );
  @override
  late final GeneratedColumn<int> dateRangeStart = GeneratedColumn<int>(
    'date_range_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateRangeEndMeta = const VerificationMeta(
    'dateRangeEnd',
  );
  @override
  late final GeneratedColumn<int> dateRangeEnd = GeneratedColumn<int>(
    'date_range_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BoundaryAnchor?, String>
  boundaryAnchor =
      GeneratedColumn<String>(
        'boundary_anchor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<BoundaryAnchor?>(
        $IncomeRecurrenceRulesTable.$converterboundaryAnchorn,
      );
  static const VerificationMeta _boundaryCountMeta = const VerificationMeta(
    'boundaryCount',
  );
  @override
  late final GeneratedColumn<int> boundaryCount = GeneratedColumn<int>(
    'boundary_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    title,
    amount,
    isAnchor,
    scheduleType,
    fixedDay,
    weekdayOrdinal,
    weekdayDay,
    dateRangeStart,
    dateRangeEnd,
    boundaryAnchor,
    boundaryCount,
    countryCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeRecurrenceRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_anchor')) {
      context.handle(
        _isAnchorMeta,
        isAnchor.isAcceptableOrUnknown(data['is_anchor']!, _isAnchorMeta),
      );
    }
    if (data.containsKey('fixed_day')) {
      context.handle(
        _fixedDayMeta,
        fixedDay.isAcceptableOrUnknown(data['fixed_day']!, _fixedDayMeta),
      );
    }
    if (data.containsKey('date_range_start')) {
      context.handle(
        _dateRangeStartMeta,
        dateRangeStart.isAcceptableOrUnknown(
          data['date_range_start']!,
          _dateRangeStartMeta,
        ),
      );
    }
    if (data.containsKey('date_range_end')) {
      context.handle(
        _dateRangeEndMeta,
        dateRangeEnd.isAcceptableOrUnknown(
          data['date_range_end']!,
          _dateRangeEndMeta,
        ),
      );
    }
    if (data.containsKey('boundary_count')) {
      context.handle(
        _boundaryCountMeta,
        boundaryCount.isAcceptableOrUnknown(
          data['boundary_count']!,
          _boundaryCountMeta,
        ),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeRecurrenceRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeRecurrenceRule(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $IncomeRecurrenceRulesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: $IncomeRecurrenceRulesTable.$converteramountn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount'],
        ),
      ),
      isAnchor: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_anchor'],
      )!,
      scheduleType: $IncomeRecurrenceRulesTable.$converterscheduleType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_type'],
        )!,
      ),
      fixedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixed_day'],
      ),
      weekdayOrdinal: $IncomeRecurrenceRulesTable.$converterweekdayOrdinaln
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}weekday_ordinal'],
            ),
          ),
      weekdayDay: $IncomeRecurrenceRulesTable.$converterweekdayDayn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weekday_day'],
        ),
      ),
      dateRangeStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_range_start'],
      ),
      dateRangeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_range_end'],
      ),
      boundaryAnchor: $IncomeRecurrenceRulesTable.$converterboundaryAnchorn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}boundary_anchor'],
            ),
          ),
      boundaryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boundary_count'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IncomeRecurrenceRulesTable createAlias(String alias) {
    return $IncomeRecurrenceRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<Decimal, String, String> $converteramount =
      const DecimalConverter();
  static JsonTypeConverter2<Decimal?, String?, String?> $converteramountn =
      JsonTypeConverter2.asNullable($converteramount);
  static JsonTypeConverter2<ScheduleType, String, String>
  $converterscheduleType = const EnumNameConverter<ScheduleType>(
    ScheduleType.values,
  );
  static JsonTypeConverter2<WeekdayOrdinal, String, String>
  $converterweekdayOrdinal = const EnumNameConverter<WeekdayOrdinal>(
    WeekdayOrdinal.values,
  );
  static JsonTypeConverter2<WeekdayOrdinal?, String?, String?>
  $converterweekdayOrdinaln = JsonTypeConverter2.asNullable(
    $converterweekdayOrdinal,
  );
  static JsonTypeConverter2<Weekday, String, String> $converterweekdayDay =
      const EnumNameConverter<Weekday>(Weekday.values);
  static JsonTypeConverter2<Weekday?, String?, String?> $converterweekdayDayn =
      JsonTypeConverter2.asNullable($converterweekdayDay);
  static JsonTypeConverter2<BoundaryAnchor, String, String>
  $converterboundaryAnchor = const EnumNameConverter<BoundaryAnchor>(
    BoundaryAnchor.values,
  );
  static JsonTypeConverter2<BoundaryAnchor?, String?, String?>
  $converterboundaryAnchorn = JsonTypeConverter2.asNullable(
    $converterboundaryAnchor,
  );
}

class IncomeRecurrenceRule extends DataClass
    implements Insertable<IncomeRecurrenceRule> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String id;
  final String spaceId;
  final String title;

  /// Null when the amount floats (spec 4.7, floating salary).
  final Decimal? amount;

  /// Only meaningful in income_driven Spaces; the form hides it elsewhere.
  final bool isAnchor;
  final ScheduleType scheduleType;

  /// fixed_date
  final int? fixedDay;

  /// weekday_rule
  final WeekdayOrdinal? weekdayOrdinal;
  final Weekday? weekdayDay;

  /// date_range
  final int? dateRangeStart;
  final int? dateRangeEnd;

  /// boundary_days
  final BoundaryAnchor? boundaryAnchor;
  final int? boundaryCount;

  /// Holiday calendar for this rule, overriding the Space country.
  final String? countryCode;
  final DateTime createdAt;
  const IncomeRecurrenceRule({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.id,
    required this.spaceId,
    required this.title,
    this.amount,
    required this.isAnchor,
    required this.scheduleType,
    this.fixedDay,
    this.weekdayOrdinal,
    this.weekdayDay,
    this.dateRangeStart,
    this.dateRangeEnd,
    this.boundaryAnchor,
    this.boundaryCount,
    this.countryCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converteramountn.toSql(amount),
      );
    }
    map['is_anchor'] = Variable<bool>(isAnchor);
    {
      map['schedule_type'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterscheduleType.toSql(scheduleType),
      );
    }
    if (!nullToAbsent || fixedDay != null) {
      map['fixed_day'] = Variable<int>(fixedDay);
    }
    if (!nullToAbsent || weekdayOrdinal != null) {
      map['weekday_ordinal'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterweekdayOrdinaln.toSql(
          weekdayOrdinal,
        ),
      );
    }
    if (!nullToAbsent || weekdayDay != null) {
      map['weekday_day'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterweekdayDayn.toSql(weekdayDay),
      );
    }
    if (!nullToAbsent || dateRangeStart != null) {
      map['date_range_start'] = Variable<int>(dateRangeStart);
    }
    if (!nullToAbsent || dateRangeEnd != null) {
      map['date_range_end'] = Variable<int>(dateRangeEnd);
    }
    if (!nullToAbsent || boundaryAnchor != null) {
      map['boundary_anchor'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterboundaryAnchorn.toSql(
          boundaryAnchor,
        ),
      );
    }
    if (!nullToAbsent || boundaryCount != null) {
      map['boundary_count'] = Variable<int>(boundaryCount);
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IncomeRecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return IncomeRecurrenceRulesCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      id: Value(id),
      spaceId: Value(spaceId),
      title: Value(title),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      isAnchor: Value(isAnchor),
      scheduleType: Value(scheduleType),
      fixedDay: fixedDay == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedDay),
      weekdayOrdinal: weekdayOrdinal == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdayOrdinal),
      weekdayDay: weekdayDay == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdayDay),
      dateRangeStart: dateRangeStart == null && nullToAbsent
          ? const Value.absent()
          : Value(dateRangeStart),
      dateRangeEnd: dateRangeEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(dateRangeEnd),
      boundaryAnchor: boundaryAnchor == null && nullToAbsent
          ? const Value.absent()
          : Value(boundaryAnchor),
      boundaryCount: boundaryCount == null && nullToAbsent
          ? const Value.absent()
          : Value(boundaryCount),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      createdAt: Value(createdAt),
    );
  }

  factory IncomeRecurrenceRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeRecurrenceRule(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $IncomeRecurrenceRulesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      title: serializer.fromJson<String>(json['title']),
      amount: $IncomeRecurrenceRulesTable.$converteramountn.fromJson(
        serializer.fromJson<String?>(json['amount']),
      ),
      isAnchor: serializer.fromJson<bool>(json['isAnchor']),
      scheduleType: $IncomeRecurrenceRulesTable.$converterscheduleType.fromJson(
        serializer.fromJson<String>(json['scheduleType']),
      ),
      fixedDay: serializer.fromJson<int?>(json['fixedDay']),
      weekdayOrdinal: $IncomeRecurrenceRulesTable.$converterweekdayOrdinaln
          .fromJson(serializer.fromJson<String?>(json['weekdayOrdinal'])),
      weekdayDay: $IncomeRecurrenceRulesTable.$converterweekdayDayn.fromJson(
        serializer.fromJson<String?>(json['weekdayDay']),
      ),
      dateRangeStart: serializer.fromJson<int?>(json['dateRangeStart']),
      dateRangeEnd: serializer.fromJson<int?>(json['dateRangeEnd']),
      boundaryAnchor: $IncomeRecurrenceRulesTable.$converterboundaryAnchorn
          .fromJson(serializer.fromJson<String?>(json['boundaryAnchor'])),
      boundaryCount: serializer.fromJson<int?>(json['boundaryCount']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $IncomeRecurrenceRulesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<String?>(
        $IncomeRecurrenceRulesTable.$converteramountn.toJson(amount),
      ),
      'isAnchor': serializer.toJson<bool>(isAnchor),
      'scheduleType': serializer.toJson<String>(
        $IncomeRecurrenceRulesTable.$converterscheduleType.toJson(scheduleType),
      ),
      'fixedDay': serializer.toJson<int?>(fixedDay),
      'weekdayOrdinal': serializer.toJson<String?>(
        $IncomeRecurrenceRulesTable.$converterweekdayOrdinaln.toJson(
          weekdayOrdinal,
        ),
      ),
      'weekdayDay': serializer.toJson<String?>(
        $IncomeRecurrenceRulesTable.$converterweekdayDayn.toJson(weekdayDay),
      ),
      'dateRangeStart': serializer.toJson<int?>(dateRangeStart),
      'dateRangeEnd': serializer.toJson<int?>(dateRangeEnd),
      'boundaryAnchor': serializer.toJson<String?>(
        $IncomeRecurrenceRulesTable.$converterboundaryAnchorn.toJson(
          boundaryAnchor,
        ),
      ),
      'boundaryCount': serializer.toJson<int?>(boundaryCount),
      'countryCode': serializer.toJson<String?>(countryCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IncomeRecurrenceRule copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? id,
    String? spaceId,
    String? title,
    Value<Decimal?> amount = const Value.absent(),
    bool? isAnchor,
    ScheduleType? scheduleType,
    Value<int?> fixedDay = const Value.absent(),
    Value<WeekdayOrdinal?> weekdayOrdinal = const Value.absent(),
    Value<Weekday?> weekdayDay = const Value.absent(),
    Value<int?> dateRangeStart = const Value.absent(),
    Value<int?> dateRangeEnd = const Value.absent(),
    Value<BoundaryAnchor?> boundaryAnchor = const Value.absent(),
    Value<int?> boundaryCount = const Value.absent(),
    Value<String?> countryCode = const Value.absent(),
    DateTime? createdAt,
  }) => IncomeRecurrenceRule(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    title: title ?? this.title,
    amount: amount.present ? amount.value : this.amount,
    isAnchor: isAnchor ?? this.isAnchor,
    scheduleType: scheduleType ?? this.scheduleType,
    fixedDay: fixedDay.present ? fixedDay.value : this.fixedDay,
    weekdayOrdinal: weekdayOrdinal.present
        ? weekdayOrdinal.value
        : this.weekdayOrdinal,
    weekdayDay: weekdayDay.present ? weekdayDay.value : this.weekdayDay,
    dateRangeStart: dateRangeStart.present
        ? dateRangeStart.value
        : this.dateRangeStart,
    dateRangeEnd: dateRangeEnd.present ? dateRangeEnd.value : this.dateRangeEnd,
    boundaryAnchor: boundaryAnchor.present
        ? boundaryAnchor.value
        : this.boundaryAnchor,
    boundaryCount: boundaryCount.present
        ? boundaryCount.value
        : this.boundaryCount,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    createdAt: createdAt ?? this.createdAt,
  );
  IncomeRecurrenceRule copyWithCompanion(IncomeRecurrenceRulesCompanion data) {
    return IncomeRecurrenceRule(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      isAnchor: data.isAnchor.present ? data.isAnchor.value : this.isAnchor,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      fixedDay: data.fixedDay.present ? data.fixedDay.value : this.fixedDay,
      weekdayOrdinal: data.weekdayOrdinal.present
          ? data.weekdayOrdinal.value
          : this.weekdayOrdinal,
      weekdayDay: data.weekdayDay.present
          ? data.weekdayDay.value
          : this.weekdayDay,
      dateRangeStart: data.dateRangeStart.present
          ? data.dateRangeStart.value
          : this.dateRangeStart,
      dateRangeEnd: data.dateRangeEnd.present
          ? data.dateRangeEnd.value
          : this.dateRangeEnd,
      boundaryAnchor: data.boundaryAnchor.present
          ? data.boundaryAnchor.value
          : this.boundaryAnchor,
      boundaryCount: data.boundaryCount.present
          ? data.boundaryCount.value
          : this.boundaryCount,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeRecurrenceRule(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('isAnchor: $isAnchor, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('fixedDay: $fixedDay, ')
          ..write('weekdayOrdinal: $weekdayOrdinal, ')
          ..write('weekdayDay: $weekdayDay, ')
          ..write('dateRangeStart: $dateRangeStart, ')
          ..write('dateRangeEnd: $dateRangeEnd, ')
          ..write('boundaryAnchor: $boundaryAnchor, ')
          ..write('boundaryCount: $boundaryCount, ')
          ..write('countryCode: $countryCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    title,
    amount,
    isAnchor,
    scheduleType,
    fixedDay,
    weekdayOrdinal,
    weekdayDay,
    dateRangeStart,
    dateRangeEnd,
    boundaryAnchor,
    boundaryCount,
    countryCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeRecurrenceRule &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.isAnchor == this.isAnchor &&
          other.scheduleType == this.scheduleType &&
          other.fixedDay == this.fixedDay &&
          other.weekdayOrdinal == this.weekdayOrdinal &&
          other.weekdayDay == this.weekdayDay &&
          other.dateRangeStart == this.dateRangeStart &&
          other.dateRangeEnd == this.dateRangeEnd &&
          other.boundaryAnchor == this.boundaryAnchor &&
          other.boundaryCount == this.boundaryCount &&
          other.countryCode == this.countryCode &&
          other.createdAt == this.createdAt);
}

class IncomeRecurrenceRulesCompanion
    extends UpdateCompanion<IncomeRecurrenceRule> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> title;
  final Value<Decimal?> amount;
  final Value<bool> isAnchor;
  final Value<ScheduleType> scheduleType;
  final Value<int?> fixedDay;
  final Value<WeekdayOrdinal?> weekdayOrdinal;
  final Value<Weekday?> weekdayDay;
  final Value<int?> dateRangeStart;
  final Value<int?> dateRangeEnd;
  final Value<BoundaryAnchor?> boundaryAnchor;
  final Value<int?> boundaryCount;
  final Value<String?> countryCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IncomeRecurrenceRulesCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.isAnchor = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.fixedDay = const Value.absent(),
    this.weekdayOrdinal = const Value.absent(),
    this.weekdayDay = const Value.absent(),
    this.dateRangeStart = const Value.absent(),
    this.dateRangeEnd = const Value.absent(),
    this.boundaryAnchor = const Value.absent(),
    this.boundaryCount = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeRecurrenceRulesCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String id,
    required String spaceId,
    required String title,
    this.amount = const Value.absent(),
    this.isAnchor = const Value.absent(),
    required ScheduleType scheduleType,
    this.fixedDay = const Value.absent(),
    this.weekdayOrdinal = const Value.absent(),
    this.weekdayDay = const Value.absent(),
    this.dateRangeStart = const Value.absent(),
    this.dateRangeEnd = const Value.absent(),
    this.boundaryAnchor = const Value.absent(),
    this.boundaryCount = const Value.absent(),
    this.countryCode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       id = Value(id),
       spaceId = Value(spaceId),
       title = Value(title),
       scheduleType = Value(scheduleType),
       createdAt = Value(createdAt);
  static Insertable<IncomeRecurrenceRule> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? title,
    Expression<String>? amount,
    Expression<bool>? isAnchor,
    Expression<String>? scheduleType,
    Expression<int>? fixedDay,
    Expression<String>? weekdayOrdinal,
    Expression<String>? weekdayDay,
    Expression<int>? dateRangeStart,
    Expression<int>? dateRangeEnd,
    Expression<String>? boundaryAnchor,
    Expression<int>? boundaryCount,
    Expression<String>? countryCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (isAnchor != null) 'is_anchor': isAnchor,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (fixedDay != null) 'fixed_day': fixedDay,
      if (weekdayOrdinal != null) 'weekday_ordinal': weekdayOrdinal,
      if (weekdayDay != null) 'weekday_day': weekdayDay,
      if (dateRangeStart != null) 'date_range_start': dateRangeStart,
      if (dateRangeEnd != null) 'date_range_end': dateRangeEnd,
      if (boundaryAnchor != null) 'boundary_anchor': boundaryAnchor,
      if (boundaryCount != null) 'boundary_count': boundaryCount,
      if (countryCode != null) 'country_code': countryCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeRecurrenceRulesCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? title,
    Value<Decimal?>? amount,
    Value<bool>? isAnchor,
    Value<ScheduleType>? scheduleType,
    Value<int?>? fixedDay,
    Value<WeekdayOrdinal?>? weekdayOrdinal,
    Value<Weekday?>? weekdayDay,
    Value<int?>? dateRangeStart,
    Value<int?>? dateRangeEnd,
    Value<BoundaryAnchor?>? boundaryAnchor,
    Value<int?>? boundaryCount,
    Value<String?>? countryCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IncomeRecurrenceRulesCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isAnchor: isAnchor ?? this.isAnchor,
      scheduleType: scheduleType ?? this.scheduleType,
      fixedDay: fixedDay ?? this.fixedDay,
      weekdayOrdinal: weekdayOrdinal ?? this.weekdayOrdinal,
      weekdayDay: weekdayDay ?? this.weekdayDay,
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
      boundaryAnchor: boundaryAnchor ?? this.boundaryAnchor,
      boundaryCount: boundaryCount ?? this.boundaryCount,
      countryCode: countryCode ?? this.countryCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$convertersyncStatus.toSql(
          syncStatus.value,
        ),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converteramountn.toSql(amount.value),
      );
    }
    if (isAnchor.present) {
      map['is_anchor'] = Variable<bool>(isAnchor.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterscheduleType.toSql(
          scheduleType.value,
        ),
      );
    }
    if (fixedDay.present) {
      map['fixed_day'] = Variable<int>(fixedDay.value);
    }
    if (weekdayOrdinal.present) {
      map['weekday_ordinal'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterweekdayOrdinaln.toSql(
          weekdayOrdinal.value,
        ),
      );
    }
    if (weekdayDay.present) {
      map['weekday_day'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterweekdayDayn.toSql(
          weekdayDay.value,
        ),
      );
    }
    if (dateRangeStart.present) {
      map['date_range_start'] = Variable<int>(dateRangeStart.value);
    }
    if (dateRangeEnd.present) {
      map['date_range_end'] = Variable<int>(dateRangeEnd.value);
    }
    if (boundaryAnchor.present) {
      map['boundary_anchor'] = Variable<String>(
        $IncomeRecurrenceRulesTable.$converterboundaryAnchorn.toSql(
          boundaryAnchor.value,
        ),
      );
    }
    if (boundaryCount.present) {
      map['boundary_count'] = Variable<int>(boundaryCount.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
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
    return (StringBuffer('IncomeRecurrenceRulesCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('isAnchor: $isAnchor, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('fixedDay: $fixedDay, ')
          ..write('weekdayOrdinal: $weekdayOrdinal, ')
          ..write('weekdayDay: $weekdayDay, ')
          ..write('dateRangeStart: $dateRangeStart, ')
          ..write('dateRangeEnd: $dateRangeEnd, ')
          ..write('boundaryAnchor: $boundaryAnchor, ')
          ..write('boundaryCount: $boundaryCount, ')
          ..write('countryCode: $countryCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, Income> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>($IncomesTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _recurrenceRuleIdMeta = const VerificationMeta(
    'recurrenceRuleId',
  );
  @override
  late final GeneratedColumn<String> recurrenceRuleId = GeneratedColumn<String>(
    'recurrence_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES income_recurrence_rules (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> amount =
      GeneratedColumn<String>(
        'amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($IncomesTable.$converteramountn);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String>
  expectedDate = GeneratedColumn<String>(
    'expected_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CalendarDate>($IncomesTable.$converterexpectedDate);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CalendarDate?>($IncomesTable.$converteractualDaten);
  static const VerificationMeta _budgetPeriodIdMeta = const VerificationMeta(
    'budgetPeriodId',
  );
  @override
  late final GeneratedColumn<String> budgetPeriodId = GeneratedColumn<String>(
    'budget_period_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_periods (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    recurrenceRuleId,
    title,
    amount,
    expectedDate,
    actualDate,
    budgetPeriodId,
    sortOrder,
    isPaid,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Income> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('recurrence_rule_id')) {
      context.handle(
        _recurrenceRuleIdMeta,
        recurrenceRuleId.isAcceptableOrUnknown(
          data['recurrence_rule_id']!,
          _recurrenceRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('budget_period_id')) {
      context.handle(
        _budgetPeriodIdMeta,
        budgetPeriodId.isAcceptableOrUnknown(
          data['budget_period_id']!,
          _budgetPeriodIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Income map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Income(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $IncomesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      recurrenceRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: $IncomesTable.$converteramountn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount'],
        ),
      ),
      expectedDate: $IncomesTable.$converterexpectedDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expected_date'],
        )!,
      ),
      actualDate: $IncomesTable.$converteractualDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}actual_date'],
        ),
      ),
      budgetPeriodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_period_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<Decimal, String, String> $converteramount =
      const DecimalConverter();
  static JsonTypeConverter2<Decimal?, String?, String?> $converteramountn =
      JsonTypeConverter2.asNullable($converteramount);
  static JsonTypeConverter2<CalendarDate, String, String>
  $converterexpectedDate = const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate, String, String> $converteractualDate =
      const CalendarDateConverter();
  static JsonTypeConverter2<CalendarDate?, String?, String?>
  $converteractualDaten = JsonTypeConverter2.asNullable($converteractualDate);
}

class Income extends DataClass implements Insertable<Income> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String id;
  final String spaceId;

  /// Null marks a one-off receipt.
  final String? recurrenceRuleId;
  final String title;
  final Decimal? amount;

  /// The anchor date from resolveIncomeWindow for regular incomes; the date
  /// the user picked for one-offs.
  final CalendarDate expectedDate;

  /// When the money actually arrived, if it differed. Affects neither the
  /// period assignment nor the schedule (spec 5.4).
  final CalendarDate? actualDate;
  final String? budgetPeriodId;

  /// Manual order within the day in the Feed. Sparse, gap 1024, and
  /// deliberately not unique — the constraint would break on a feed-mode
  /// switch (plan G2). Ties break on id.
  final int sortOrder;

  /// Expected versus received.
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  const Income({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.id,
    required this.spaceId,
    this.recurrenceRuleId,
    required this.title,
    this.amount,
    required this.expectedDate,
    this.actualDate,
    this.budgetPeriodId,
    required this.sortOrder,
    required this.isPaid,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $IncomesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    if (!nullToAbsent || recurrenceRuleId != null) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(
        $IncomesTable.$converteramountn.toSql(amount),
      );
    }
    {
      map['expected_date'] = Variable<String>(
        $IncomesTable.$converterexpectedDate.toSql(expectedDate),
      );
    }
    if (!nullToAbsent || actualDate != null) {
      map['actual_date'] = Variable<String>(
        $IncomesTable.$converteractualDaten.toSql(actualDate),
      );
    }
    if (!nullToAbsent || budgetPeriodId != null) {
      map['budget_period_id'] = Variable<String>(budgetPeriodId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_paid'] = Variable<bool>(isPaid);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      id: Value(id),
      spaceId: Value(spaceId),
      recurrenceRuleId: recurrenceRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleId),
      title: Value(title),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      expectedDate: Value(expectedDate),
      actualDate: actualDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDate),
      budgetPeriodId: budgetPeriodId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetPeriodId),
      sortOrder: Value(sortOrder),
      isPaid: Value(isPaid),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Income.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Income(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $IncomesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      recurrenceRuleId: serializer.fromJson<String?>(json['recurrenceRuleId']),
      title: serializer.fromJson<String>(json['title']),
      amount: $IncomesTable.$converteramountn.fromJson(
        serializer.fromJson<String?>(json['amount']),
      ),
      expectedDate: $IncomesTable.$converterexpectedDate.fromJson(
        serializer.fromJson<String>(json['expectedDate']),
      ),
      actualDate: $IncomesTable.$converteractualDaten.fromJson(
        serializer.fromJson<String?>(json['actualDate']),
      ),
      budgetPeriodId: serializer.fromJson<String?>(json['budgetPeriodId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $IncomesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'recurrenceRuleId': serializer.toJson<String?>(recurrenceRuleId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<String?>(
        $IncomesTable.$converteramountn.toJson(amount),
      ),
      'expectedDate': serializer.toJson<String>(
        $IncomesTable.$converterexpectedDate.toJson(expectedDate),
      ),
      'actualDate': serializer.toJson<String?>(
        $IncomesTable.$converteractualDaten.toJson(actualDate),
      ),
      'budgetPeriodId': serializer.toJson<String?>(budgetPeriodId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPaid': serializer.toJson<bool>(isPaid),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Income copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? id,
    String? spaceId,
    Value<String?> recurrenceRuleId = const Value.absent(),
    String? title,
    Value<Decimal?> amount = const Value.absent(),
    CalendarDate? expectedDate,
    Value<CalendarDate?> actualDate = const Value.absent(),
    Value<String?> budgetPeriodId = const Value.absent(),
    int? sortOrder,
    bool? isPaid,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Income(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    recurrenceRuleId: recurrenceRuleId.present
        ? recurrenceRuleId.value
        : this.recurrenceRuleId,
    title: title ?? this.title,
    amount: amount.present ? amount.value : this.amount,
    expectedDate: expectedDate ?? this.expectedDate,
    actualDate: actualDate.present ? actualDate.value : this.actualDate,
    budgetPeriodId: budgetPeriodId.present
        ? budgetPeriodId.value
        : this.budgetPeriodId,
    sortOrder: sortOrder ?? this.sortOrder,
    isPaid: isPaid ?? this.isPaid,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Income copyWithCompanion(IncomesCompanion data) {
    return Income(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      recurrenceRuleId: data.recurrenceRuleId.present
          ? data.recurrenceRuleId.value
          : this.recurrenceRuleId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      budgetPeriodId: data.budgetPeriodId.present
          ? data.budgetPeriodId.value
          : this.budgetPeriodId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Income(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('budgetPeriodId: $budgetPeriodId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPaid: $isPaid, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    recurrenceRuleId,
    title,
    amount,
    expectedDate,
    actualDate,
    budgetPeriodId,
    sortOrder,
    isPaid,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Income &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.recurrenceRuleId == this.recurrenceRuleId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.expectedDate == this.expectedDate &&
          other.actualDate == this.actualDate &&
          other.budgetPeriodId == this.budgetPeriodId &&
          other.sortOrder == this.sortOrder &&
          other.isPaid == this.isPaid &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class IncomesCompanion extends UpdateCompanion<Income> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String?> recurrenceRuleId;
  final Value<String> title;
  final Value<Decimal?> amount;
  final Value<CalendarDate> expectedDate;
  final Value<CalendarDate?> actualDate;
  final Value<String?> budgetPeriodId;
  final Value<int> sortOrder;
  final Value<bool> isPaid;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IncomesCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.budgetPeriodId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String id,
    required String spaceId,
    this.recurrenceRuleId = const Value.absent(),
    required String title,
    this.amount = const Value.absent(),
    required CalendarDate expectedDate,
    this.actualDate = const Value.absent(),
    this.budgetPeriodId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       id = Value(id),
       spaceId = Value(spaceId),
       title = Value(title),
       expectedDate = Value(expectedDate),
       createdAt = Value(createdAt);
  static Insertable<Income> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? recurrenceRuleId,
    Expression<String>? title,
    Expression<String>? amount,
    Expression<String>? expectedDate,
    Expression<String>? actualDate,
    Expression<String>? budgetPeriodId,
    Expression<int>? sortOrder,
    Expression<bool>? isPaid,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (recurrenceRuleId != null) 'recurrence_rule_id': recurrenceRuleId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (actualDate != null) 'actual_date': actualDate,
      if (budgetPeriodId != null) 'budget_period_id': budgetPeriodId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPaid != null) 'is_paid': isPaid,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? id,
    Value<String>? spaceId,
    Value<String?>? recurrenceRuleId,
    Value<String>? title,
    Value<Decimal?>? amount,
    Value<CalendarDate>? expectedDate,
    Value<CalendarDate?>? actualDate,
    Value<String?>? budgetPeriodId,
    Value<int>? sortOrder,
    Value<bool>? isPaid,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IncomesCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      expectedDate: expectedDate ?? this.expectedDate,
      actualDate: actualDate ?? this.actualDate,
      budgetPeriodId: budgetPeriodId ?? this.budgetPeriodId,
      sortOrder: sortOrder ?? this.sortOrder,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $IncomesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (recurrenceRuleId.present) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(
        $IncomesTable.$converteramountn.toSql(amount.value),
      );
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<String>(
        $IncomesTable.$converterexpectedDate.toSql(expectedDate.value),
      );
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(
        $IncomesTable.$converteractualDaten.toSql(actualDate.value),
      );
    }
    if (budgetPeriodId.present) {
      map['budget_period_id'] = Variable<String>(budgetPeriodId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('IncomesCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('budgetPeriodId: $budgetPeriodId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPaid: $isPaid, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant<String>('none'),
      ).withConverter<SyncStatus>($PaymentsTable.$convertersyncStatus);
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientEditedAtMeta = const VerificationMeta(
    'clientEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientEditedAt =
      GeneratedColumn<DateTime>(
        'client_edited_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _budgetPeriodIdMeta = const VerificationMeta(
    'budgetPeriodId',
  );
  @override
  late final GeneratedColumn<String> budgetPeriodId = GeneratedColumn<String>(
    'budget_period_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_periods (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PeriodAssignment, String>
  periodAssignment = GeneratedColumn<String>(
    'period_assignment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('auto'),
  ).withConverter<PeriodAssignment>($PaymentsTable.$converterperiodAssignment);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _groupRecurringIdMeta = const VerificationMeta(
    'groupRecurringId',
  );
  @override
  late final GeneratedColumn<String> groupRecurringId = GeneratedColumn<String>(
    'group_recurring_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> amount =
      GeneratedColumn<String>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($PaymentsTable.$converteramount);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> dueDate =
      GeneratedColumn<String>(
        'due_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($PaymentsTable.$converterdueDate);
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseType, String> expenseType =
      GeneratedColumn<String>(
        'expense_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExpenseType>($PaymentsTable.$converterexpenseType);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    budgetPeriodId,
    periodAssignment,
    categoryId,
    groupRecurringId,
    title,
    amount,
    dueDate,
    expenseType,
    sortOrder,
    isPaid,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    }
    if (data.containsKey('client_edited_at')) {
      context.handle(
        _clientEditedAtMeta,
        clientEditedAt.isAcceptableOrUnknown(
          data['client_edited_at']!,
          _clientEditedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEditedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('budget_period_id')) {
      context.handle(
        _budgetPeriodIdMeta,
        budgetPeriodId.isAcceptableOrUnknown(
          data['budget_period_id']!,
          _budgetPeriodIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('group_recurring_id')) {
      context.handle(
        _groupRecurringIdMeta,
        groupRecurringId.isAcceptableOrUnknown(
          data['group_recurring_id']!,
          _groupRecurringIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncStatus: $PaymentsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      ),
      clientEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_edited_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      budgetPeriodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_period_id'],
      ),
      periodAssignment: $PaymentsTable.$converterperiodAssignment.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}period_assignment'],
        )!,
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      groupRecurringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_recurring_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: $PaymentsTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount'],
        )!,
      ),
      dueDate: $PaymentsTable.$converterdueDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date'],
        )!,
      ),
      expenseType: $PaymentsTable.$converterexpenseType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expense_type'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<PeriodAssignment, String, String>
  $converterperiodAssignment = const EnumNameConverter<PeriodAssignment>(
    PeriodAssignment.values,
  );
  static JsonTypeConverter2<Decimal, String, String> $converteramount =
      const DecimalConverter();
  static JsonTypeConverter2<CalendarDate, String, String> $converterdueDate =
      const CalendarDateConverter();
  static JsonTypeConverter2<ExpenseType, String, String> $converterexpenseType =
      const EnumNameConverter<ExpenseType>(ExpenseType.values);
}

class Payment extends DataClass implements Insertable<Payment> {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  final bool isDeleted;
  final SyncStatus syncStatus;

  /// Author of the last edit, for conflict toasts (spec 10.4).
  final String? lastModifiedBy;

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  final DateTime clientEditedAt;

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  final DateTime? serverReceivedAt;
  final String id;
  final String spaceId;
  final String? budgetPeriodId;

  /// `manual` pins the row to its period against recalculation (spec 5.3).
  final PeriodAssignment periodAssignment;
  final String? categoryId;

  /// Ties one occurrence to its repeating series (spec 6.3).
  final String? groupRecurringId;
  final String title;
  final Decimal amount;
  final CalendarDate dueDate;
  final ExpenseType expenseType;

  /// See [Incomes.sortOrder] — sparse, not unique (plan G2).
  final int sortOrder;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  const Payment({
    required this.isDeleted,
    required this.syncStatus,
    this.lastModifiedBy,
    required this.clientEditedAt,
    this.serverReceivedAt,
    required this.id,
    required this.spaceId,
    this.budgetPeriodId,
    required this.periodAssignment,
    this.categoryId,
    this.groupRecurringId,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.expenseType,
    required this.sortOrder,
    required this.isPaid,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['is_deleted'] = Variable<bool>(isDeleted);
    {
      map['sync_status'] = Variable<String>(
        $PaymentsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastModifiedBy != null) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy);
    }
    map['client_edited_at'] = Variable<DateTime>(clientEditedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    if (!nullToAbsent || budgetPeriodId != null) {
      map['budget_period_id'] = Variable<String>(budgetPeriodId);
    }
    {
      map['period_assignment'] = Variable<String>(
        $PaymentsTable.$converterperiodAssignment.toSql(periodAssignment),
      );
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || groupRecurringId != null) {
      map['group_recurring_id'] = Variable<String>(groupRecurringId);
    }
    map['title'] = Variable<String>(title);
    {
      map['amount'] = Variable<String>(
        $PaymentsTable.$converteramount.toSql(amount),
      );
    }
    {
      map['due_date'] = Variable<String>(
        $PaymentsTable.$converterdueDate.toSql(dueDate),
      );
    }
    {
      map['expense_type'] = Variable<String>(
        $PaymentsTable.$converterexpenseType.toSql(expenseType),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_paid'] = Variable<bool>(isPaid);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      isDeleted: Value(isDeleted),
      syncStatus: Value(syncStatus),
      lastModifiedBy: lastModifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedBy),
      clientEditedAt: Value(clientEditedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      id: Value(id),
      spaceId: Value(spaceId),
      budgetPeriodId: budgetPeriodId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetPeriodId),
      periodAssignment: Value(periodAssignment),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      groupRecurringId: groupRecurringId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupRecurringId),
      title: Value(title),
      amount: Value(amount),
      dueDate: Value(dueDate),
      expenseType: Value(expenseType),
      sortOrder: Value(sortOrder),
      isPaid: Value(isPaid),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncStatus: $PaymentsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastModifiedBy: serializer.fromJson<String?>(json['lastModifiedBy']),
      clientEditedAt: serializer.fromJson<DateTime>(json['clientEditedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      budgetPeriodId: serializer.fromJson<String?>(json['budgetPeriodId']),
      periodAssignment: $PaymentsTable.$converterperiodAssignment.fromJson(
        serializer.fromJson<String>(json['periodAssignment']),
      ),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      groupRecurringId: serializer.fromJson<String?>(json['groupRecurringId']),
      title: serializer.fromJson<String>(json['title']),
      amount: $PaymentsTable.$converteramount.fromJson(
        serializer.fromJson<String>(json['amount']),
      ),
      dueDate: $PaymentsTable.$converterdueDate.fromJson(
        serializer.fromJson<String>(json['dueDate']),
      ),
      expenseType: $PaymentsTable.$converterexpenseType.fromJson(
        serializer.fromJson<String>(json['expenseType']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncStatus': serializer.toJson<String>(
        $PaymentsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastModifiedBy': serializer.toJson<String?>(lastModifiedBy),
      'clientEditedAt': serializer.toJson<DateTime>(clientEditedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'budgetPeriodId': serializer.toJson<String?>(budgetPeriodId),
      'periodAssignment': serializer.toJson<String>(
        $PaymentsTable.$converterperiodAssignment.toJson(periodAssignment),
      ),
      'categoryId': serializer.toJson<String?>(categoryId),
      'groupRecurringId': serializer.toJson<String?>(groupRecurringId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<String>(
        $PaymentsTable.$converteramount.toJson(amount),
      ),
      'dueDate': serializer.toJson<String>(
        $PaymentsTable.$converterdueDate.toJson(dueDate),
      ),
      'expenseType': serializer.toJson<String>(
        $PaymentsTable.$converterexpenseType.toJson(expenseType),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPaid': serializer.toJson<bool>(isPaid),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    bool? isDeleted,
    SyncStatus? syncStatus,
    Value<String?> lastModifiedBy = const Value.absent(),
    DateTime? clientEditedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    String? id,
    String? spaceId,
    Value<String?> budgetPeriodId = const Value.absent(),
    PeriodAssignment? periodAssignment,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> groupRecurringId = const Value.absent(),
    String? title,
    Decimal? amount,
    CalendarDate? dueDate,
    ExpenseType? expenseType,
    int? sortOrder,
    bool? isPaid,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Payment(
    isDeleted: isDeleted ?? this.isDeleted,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModifiedBy: lastModifiedBy.present
        ? lastModifiedBy.value
        : this.lastModifiedBy,
    clientEditedAt: clientEditedAt ?? this.clientEditedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    budgetPeriodId: budgetPeriodId.present
        ? budgetPeriodId.value
        : this.budgetPeriodId,
    periodAssignment: periodAssignment ?? this.periodAssignment,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    groupRecurringId: groupRecurringId.present
        ? groupRecurringId.value
        : this.groupRecurringId,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    dueDate: dueDate ?? this.dueDate,
    expenseType: expenseType ?? this.expenseType,
    sortOrder: sortOrder ?? this.sortOrder,
    isPaid: isPaid ?? this.isPaid,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      clientEditedAt: data.clientEditedAt.present
          ? data.clientEditedAt.value
          : this.clientEditedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      budgetPeriodId: data.budgetPeriodId.present
          ? data.budgetPeriodId.value
          : this.budgetPeriodId,
      periodAssignment: data.periodAssignment.present
          ? data.periodAssignment.value
          : this.periodAssignment,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      groupRecurringId: data.groupRecurringId.present
          ? data.groupRecurringId.value
          : this.groupRecurringId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      expenseType: data.expenseType.present
          ? data.expenseType.value
          : this.expenseType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('budgetPeriodId: $budgetPeriodId, ')
          ..write('periodAssignment: $periodAssignment, ')
          ..write('categoryId: $categoryId, ')
          ..write('groupRecurringId: $groupRecurringId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('expenseType: $expenseType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPaid: $isPaid, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    isDeleted,
    syncStatus,
    lastModifiedBy,
    clientEditedAt,
    serverReceivedAt,
    id,
    spaceId,
    budgetPeriodId,
    periodAssignment,
    categoryId,
    groupRecurringId,
    title,
    amount,
    dueDate,
    expenseType,
    sortOrder,
    isPaid,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.isDeleted == this.isDeleted &&
          other.syncStatus == this.syncStatus &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.clientEditedAt == this.clientEditedAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.budgetPeriodId == this.budgetPeriodId &&
          other.periodAssignment == this.periodAssignment &&
          other.categoryId == this.categoryId &&
          other.groupRecurringId == this.groupRecurringId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.dueDate == this.dueDate &&
          other.expenseType == this.expenseType &&
          other.sortOrder == this.sortOrder &&
          other.isPaid == this.isPaid &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<bool> isDeleted;
  final Value<SyncStatus> syncStatus;
  final Value<String?> lastModifiedBy;
  final Value<DateTime> clientEditedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String?> budgetPeriodId;
  final Value<PeriodAssignment> periodAssignment;
  final Value<String?> categoryId;
  final Value<String?> groupRecurringId;
  final Value<String> title;
  final Value<Decimal> amount;
  final Value<CalendarDate> dueDate;
  final Value<ExpenseType> expenseType;
  final Value<int> sortOrder;
  final Value<bool> isPaid;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.clientEditedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.budgetPeriodId = const Value.absent(),
    this.periodAssignment = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.groupRecurringId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.expenseType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.isDeleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    required DateTime clientEditedAt,
    this.serverReceivedAt = const Value.absent(),
    required String id,
    required String spaceId,
    this.budgetPeriodId = const Value.absent(),
    this.periodAssignment = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.groupRecurringId = const Value.absent(),
    required String title,
    required Decimal amount,
    required CalendarDate dueDate,
    required ExpenseType expenseType,
    this.sortOrder = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientEditedAt = Value(clientEditedAt),
       id = Value(id),
       spaceId = Value(spaceId),
       title = Value(title),
       amount = Value(amount),
       dueDate = Value(dueDate),
       expenseType = Value(expenseType),
       createdAt = Value(createdAt);
  static Insertable<Payment> custom({
    Expression<bool>? isDeleted,
    Expression<String>? syncStatus,
    Expression<String>? lastModifiedBy,
    Expression<DateTime>? clientEditedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? budgetPeriodId,
    Expression<String>? periodAssignment,
    Expression<String>? categoryId,
    Expression<String>? groupRecurringId,
    Expression<String>? title,
    Expression<String>? amount,
    Expression<String>? dueDate,
    Expression<String>? expenseType,
    Expression<int>? sortOrder,
    Expression<bool>? isPaid,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (clientEditedAt != null) 'client_edited_at': clientEditedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (budgetPeriodId != null) 'budget_period_id': budgetPeriodId,
      if (periodAssignment != null) 'period_assignment': periodAssignment,
      if (categoryId != null) 'category_id': categoryId,
      if (groupRecurringId != null) 'group_recurring_id': groupRecurringId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (dueDate != null) 'due_date': dueDate,
      if (expenseType != null) 'expense_type': expenseType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPaid != null) 'is_paid': isPaid,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<bool>? isDeleted,
    Value<SyncStatus>? syncStatus,
    Value<String?>? lastModifiedBy,
    Value<DateTime>? clientEditedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<String>? id,
    Value<String>? spaceId,
    Value<String?>? budgetPeriodId,
    Value<PeriodAssignment>? periodAssignment,
    Value<String?>? categoryId,
    Value<String?>? groupRecurringId,
    Value<String>? title,
    Value<Decimal>? amount,
    Value<CalendarDate>? dueDate,
    Value<ExpenseType>? expenseType,
    Value<int>? sortOrder,
    Value<bool>? isPaid,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      clientEditedAt: clientEditedAt ?? this.clientEditedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      budgetPeriodId: budgetPeriodId ?? this.budgetPeriodId,
      periodAssignment: periodAssignment ?? this.periodAssignment,
      categoryId: categoryId ?? this.categoryId,
      groupRecurringId: groupRecurringId ?? this.groupRecurringId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      expenseType: expenseType ?? this.expenseType,
      sortOrder: sortOrder ?? this.sortOrder,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $PaymentsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (clientEditedAt.present) {
      map['client_edited_at'] = Variable<DateTime>(clientEditedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (budgetPeriodId.present) {
      map['budget_period_id'] = Variable<String>(budgetPeriodId.value);
    }
    if (periodAssignment.present) {
      map['period_assignment'] = Variable<String>(
        $PaymentsTable.$converterperiodAssignment.toSql(periodAssignment.value),
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (groupRecurringId.present) {
      map['group_recurring_id'] = Variable<String>(groupRecurringId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(
        $PaymentsTable.$converteramount.toSql(amount.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(
        $PaymentsTable.$converterdueDate.toSql(dueDate.value),
      );
    }
    if (expenseType.present) {
      map['expense_type'] = Variable<String>(
        $PaymentsTable.$converterexpenseType.toSql(expenseType.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('clientEditedAt: $clientEditedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('budgetPeriodId: $budgetPeriodId, ')
          ..write('periodAssignment: $periodAssignment, ')
          ..write('categoryId: $categoryId, ')
          ..write('groupRecurringId: $groupRecurringId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('expenseType: $expenseType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPaid: $isPaid, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidayCacheTable extends HolidayCache
    with TableInfo<$HolidayCacheTable, HolidayCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidayCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _holidayDatesMeta = const VerificationMeta(
    'holidayDates',
  );
  @override
  late final GeneratedColumn<String> holidayDates = GeneratedColumn<String>(
    'holiday_dates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    countryCode,
    year,
    holidayDates,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holiday_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolidayCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('holiday_dates')) {
      context.handle(
        _holidayDatesMeta,
        holidayDates.isAcceptableOrUnknown(
          data['holiday_dates']!,
          _holidayDatesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_holidayDatesMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {countryCode, year},
  ];
  @override
  HolidayCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolidayCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      holidayDates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holiday_dates'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $HolidayCacheTable createAlias(String alias) {
    return $HolidayCacheTable(attachedDatabase, alias);
  }
}

class HolidayCacheData extends DataClass
    implements Insertable<HolidayCacheData> {
  final String id;
  final String countryCode;
  final int year;

  /// JSON array of `YYYY-MM-DD`.
  final String holidayDates;
  final DateTime fetchedAt;
  const HolidayCacheData({
    required this.id,
    required this.countryCode,
    required this.year,
    required this.holidayDates,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['country_code'] = Variable<String>(countryCode);
    map['year'] = Variable<int>(year);
    map['holiday_dates'] = Variable<String>(holidayDates);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  HolidayCacheCompanion toCompanion(bool nullToAbsent) {
    return HolidayCacheCompanion(
      id: Value(id),
      countryCode: Value(countryCode),
      year: Value(year),
      holidayDates: Value(holidayDates),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory HolidayCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolidayCacheData(
      id: serializer.fromJson<String>(json['id']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      year: serializer.fromJson<int>(json['year']),
      holidayDates: serializer.fromJson<String>(json['holidayDates']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'countryCode': serializer.toJson<String>(countryCode),
      'year': serializer.toJson<int>(year),
      'holidayDates': serializer.toJson<String>(holidayDates),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  HolidayCacheData copyWith({
    String? id,
    String? countryCode,
    int? year,
    String? holidayDates,
    DateTime? fetchedAt,
  }) => HolidayCacheData(
    id: id ?? this.id,
    countryCode: countryCode ?? this.countryCode,
    year: year ?? this.year,
    holidayDates: holidayDates ?? this.holidayDates,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  HolidayCacheData copyWithCompanion(HolidayCacheCompanion data) {
    return HolidayCacheData(
      id: data.id.present ? data.id.value : this.id,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      year: data.year.present ? data.year.value : this.year,
      holidayDates: data.holidayDates.present
          ? data.holidayDates.value
          : this.holidayDates,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolidayCacheData(')
          ..write('id: $id, ')
          ..write('countryCode: $countryCode, ')
          ..write('year: $year, ')
          ..write('holidayDates: $holidayDates, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, countryCode, year, holidayDates, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolidayCacheData &&
          other.id == this.id &&
          other.countryCode == this.countryCode &&
          other.year == this.year &&
          other.holidayDates == this.holidayDates &&
          other.fetchedAt == this.fetchedAt);
}

class HolidayCacheCompanion extends UpdateCompanion<HolidayCacheData> {
  final Value<String> id;
  final Value<String> countryCode;
  final Value<int> year;
  final Value<String> holidayDates;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const HolidayCacheCompanion({
    this.id = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.year = const Value.absent(),
    this.holidayDates = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidayCacheCompanion.insert({
    required String id,
    required String countryCode,
    required int year,
    required String holidayDates,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       countryCode = Value(countryCode),
       year = Value(year),
       holidayDates = Value(holidayDates),
       fetchedAt = Value(fetchedAt);
  static Insertable<HolidayCacheData> custom({
    Expression<String>? id,
    Expression<String>? countryCode,
    Expression<int>? year,
    Expression<String>? holidayDates,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (countryCode != null) 'country_code': countryCode,
      if (year != null) 'year': year,
      if (holidayDates != null) 'holiday_dates': holidayDates,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HolidayCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? countryCode,
    Value<int>? year,
    Value<String>? holidayDates,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return HolidayCacheCompanion(
      id: id ?? this.id,
      countryCode: countryCode ?? this.countryCode,
      year: year ?? this.year,
      holidayDates: holidayDates ?? this.holidayDates,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (holidayDates.present) {
      map['holiday_dates'] = Variable<String>(holidayDates.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidayCacheCompanion(')
          ..write('id: $id, ')
          ..write('countryCode: $countryCode, ')
          ..write('year: $year, ')
          ..write('holidayDates: $holidayDates, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomNonWorkingDaysTable extends CustomNonWorkingDays
    with TableInfo<$CustomNonWorkingDaysTable, CustomNonWorkingDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomNonWorkingDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($CustomNonWorkingDaysTable.$converterdate);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    title,
    countryCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_non_working_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomNonWorkingDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, countryCode},
  ];
  @override
  CustomNonWorkingDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomNonWorkingDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: $CustomNonWorkingDaysTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomNonWorkingDaysTable createAlias(String alias) {
    return $CustomNonWorkingDaysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CalendarDate, String, String> $converterdate =
      const CalendarDateConverter();
}

class CustomNonWorkingDay extends DataClass
    implements Insertable<CustomNonWorkingDay> {
  final String id;
  final CalendarDate date;
  final String? title;

  /// Null applies the day to every country.
  final String? countryCode;
  final DateTime createdAt;
  const CustomNonWorkingDay({
    required this.id,
    required this.date,
    this.title,
    this.countryCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['date'] = Variable<String>(
        $CustomNonWorkingDaysTable.$converterdate.toSql(date),
      );
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomNonWorkingDaysCompanion toCompanion(bool nullToAbsent) {
    return CustomNonWorkingDaysCompanion(
      id: Value(id),
      date: Value(date),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      createdAt: Value(createdAt),
    );
  }

  factory CustomNonWorkingDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomNonWorkingDay(
      id: serializer.fromJson<String>(json['id']),
      date: $CustomNonWorkingDaysTable.$converterdate.fromJson(
        serializer.fromJson<String>(json['date']),
      ),
      title: serializer.fromJson<String?>(json['title']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(
        $CustomNonWorkingDaysTable.$converterdate.toJson(date),
      ),
      'title': serializer.toJson<String?>(title),
      'countryCode': serializer.toJson<String?>(countryCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomNonWorkingDay copyWith({
    String? id,
    CalendarDate? date,
    Value<String?> title = const Value.absent(),
    Value<String?> countryCode = const Value.absent(),
    DateTime? createdAt,
  }) => CustomNonWorkingDay(
    id: id ?? this.id,
    date: date ?? this.date,
    title: title.present ? title.value : this.title,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomNonWorkingDay copyWithCompanion(CustomNonWorkingDaysCompanion data) {
    return CustomNonWorkingDay(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomNonWorkingDay(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('countryCode: $countryCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, title, countryCode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomNonWorkingDay &&
          other.id == this.id &&
          other.date == this.date &&
          other.title == this.title &&
          other.countryCode == this.countryCode &&
          other.createdAt == this.createdAt);
}

class CustomNonWorkingDaysCompanion
    extends UpdateCompanion<CustomNonWorkingDay> {
  final Value<String> id;
  final Value<CalendarDate> date;
  final Value<String?> title;
  final Value<String?> countryCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomNonWorkingDaysCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomNonWorkingDaysCompanion.insert({
    required String id,
    required CalendarDate date,
    this.title = const Value.absent(),
    this.countryCode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<CustomNonWorkingDay> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? title,
    Expression<String>? countryCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (countryCode != null) 'country_code': countryCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomNonWorkingDaysCompanion copyWith({
    Value<String>? id,
    Value<CalendarDate>? date,
    Value<String?>? title,
    Value<String?>? countryCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomNonWorkingDaysCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      countryCode: countryCode ?? this.countryCode,
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
    if (date.present) {
      map['date'] = Variable<String>(
        $CustomNonWorkingDaysTable.$converterdate.toSql(date.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
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
    return (StringBuffer('CustomNonWorkingDaysCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('countryCode: $countryCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SpacesTable spaces = $SpacesTable(this);
  late final $SpaceMembersTable spaceMembers = $SpaceMembersTable(this);
  late final $MemberLocalLabelsTable memberLocalLabels =
      $MemberLocalLabelsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $BudgetPeriodsTable budgetPeriods = $BudgetPeriodsTable(this);
  late final $IncomeRecurrenceRulesTable incomeRecurrenceRules =
      $IncomeRecurrenceRulesTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $HolidayCacheTable holidayCache = $HolidayCacheTable(this);
  late final $CustomNonWorkingDaysTable customNonWorkingDays =
      $CustomNonWorkingDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    spaces,
    spaceMembers,
    memberLocalLabels,
    userProfiles,
    categories,
    budgetPeriods,
    incomeRecurrenceRules,
    incomes,
    payments,
    holidayCache,
    customNonWorkingDays,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SpacesTableCreateCompanionBuilder = SpacesCompanion Function({
  required String id,
  required String title,
  required SpaceType spaceType,
  required BudgetMode budgetMode,
  required String ownerId,
  required StorageMode storageMode,
  Value<String?> countryCode,
  required String timezone,
  required String currencyCode,
  Value<int?> maxMembers,
  Value<bool> isArchived,
  Value<Decimal?> manualBalance,
  Value<DateTime?> manualBalanceUpdatedAt,
  Value<int> minSchemaVersion,
  Value<FeedOrderMode> feedOrderMode,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SpacesTableUpdateCompanionBuilder = SpacesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<SpaceType> spaceType,
  Value<BudgetMode> budgetMode,
  Value<String> ownerId,
  Value<StorageMode> storageMode,
  Value<String?> countryCode,
  Value<String> timezone,
  Value<String> currencyCode,
  Value<int?> maxMembers,
  Value<bool> isArchived,
  Value<Decimal?> manualBalance,
  Value<DateTime?> manualBalanceUpdatedAt,
  Value<int> minSchemaVersion,
  Value<FeedOrderMode> feedOrderMode,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SpacesTableReferences
    extends BaseReferences<_$AppDatabase, $SpacesTable, Space> {
  $$SpacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SpaceMembersTable, List<SpaceMember>>
  _spaceMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.spaceMembers,
    aliasName: 'spaces__id__space_members__space_id',
  );

  $$SpaceMembersTableProcessedTableManager get spaceMembersRefs {
    final manager = $$SpaceMembersTableTableManager(
      $_db,
      $_db.spaceMembers,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_spaceMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemberLocalLabelsTable, List<MemberLocalLabel>>
  _memberLocalLabelsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memberLocalLabels,
        aliasName: 'spaces__id__member_local_labels__space_id',
      );

  $$MemberLocalLabelsTableProcessedTableManager get memberLocalLabelsRefs {
    final manager = $$MemberLocalLabelsTableTableManager(
      $_db,
      $_db.memberLocalLabels,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memberLocalLabelsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoriesTable, List<Category>>
  _categoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: 'spaces__id__categories__space_id',
  );

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetPeriodsTable, List<BudgetPeriod>>
  _budgetPeriodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetPeriods,
    aliasName: 'spaces__id__budget_periods__space_id',
  );

  $$BudgetPeriodsTableProcessedTableManager get budgetPeriodsRefs {
    final manager = $$BudgetPeriodsTableTableManager(
      $_db,
      $_db.budgetPeriods,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetPeriodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $IncomeRecurrenceRulesTable,
    List<IncomeRecurrenceRule>
  >
  _incomeRecurrenceRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.incomeRecurrenceRules,
        aliasName: 'spaces__id__income_recurrence_rules__space_id',
      );

  $$IncomeRecurrenceRulesTableProcessedTableManager
  get incomeRecurrenceRulesRefs {
    final manager = $$IncomeRecurrenceRulesTableTableManager(
      $_db,
      $_db.incomeRecurrenceRules,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incomeRecurrenceRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: 'spaces__id__incomes__space_id',
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager(
      $_db,
      $_db.incomes,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'spaces__id__payments__space_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SpacesTableFilterComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SpaceType, SpaceType, String> get spaceType =>
      $composableBuilder(
        column: $table.spaceType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<BudgetMode, BudgetMode, String>
  get budgetMode => $composableBuilder(
    column: $table.budgetMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StorageMode, StorageMode, String>
  get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxMembers => $composableBuilder(
    column: $table.maxMembers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get manualBalance =>
      $composableBuilder(
        column: $table.manualBalance,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get manualBalanceUpdatedAt => $composableBuilder(
    column: $table.manualBalanceUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minSchemaVersion => $composableBuilder(
    column: $table.minSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FeedOrderMode, FeedOrderMode, String>
  get feedOrderMode => $composableBuilder(
    column: $table.feedOrderMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> spaceMembersRefs(
    Expression<bool> Function($$SpaceMembersTableFilterComposer f) f,
  ) {
    final $$SpaceMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceMembers,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceMembersTableFilterComposer(
            $db: $db,
            $table: $db.spaceMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memberLocalLabelsRefs(
    Expression<bool> Function($$MemberLocalLabelsTableFilterComposer f) f,
  ) {
    final $$MemberLocalLabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memberLocalLabels,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemberLocalLabelsTableFilterComposer(
            $db: $db,
            $table: $db.memberLocalLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoriesRefs(
    Expression<bool> Function($$CategoriesTableFilterComposer f) f,
  ) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetPeriodsRefs(
    Expression<bool> Function($$BudgetPeriodsTableFilterComposer f) f,
  ) {
    final $$BudgetPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomeRecurrenceRulesRefs(
    Expression<bool> Function($$IncomeRecurrenceRulesTableFilterComposer f) f,
  ) {
    final $$IncomeRecurrenceRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.incomeRecurrenceRules,
          getReferencedColumn: (t) => t.spaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IncomeRecurrenceRulesTableFilterComposer(
                $db: $db,
                $table: $db.incomeRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spaceType => $composableBuilder(
    column: $table.spaceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetMode => $composableBuilder(
    column: $table.budgetMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxMembers => $composableBuilder(
    column: $table.maxMembers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualBalance => $composableBuilder(
    column: $table.manualBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get manualBalanceUpdatedAt => $composableBuilder(
    column: $table.manualBalanceUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minSchemaVersion => $composableBuilder(
    column: $table.minSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedOrderMode => $composableBuilder(
    column: $table.feedOrderMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<SpaceType, String> get spaceType =>
      $composableBuilder(column: $table.spaceType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BudgetMode, String> get budgetMode =>
      $composableBuilder(
        column: $table.budgetMode,
        builder: (column) => column,
      );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StorageMode, String> get storageMode =>
      $composableBuilder(
        column: $table.storageMode,
        builder: (column) => column,
      );

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxMembers => $composableBuilder(
    column: $table.maxMembers,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String> get manualBalance =>
      $composableBuilder(
        column: $table.manualBalance,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get manualBalanceUpdatedAt => $composableBuilder(
    column: $table.manualBalanceUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minSchemaVersion => $composableBuilder(
    column: $table.minSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FeedOrderMode, String> get feedOrderMode =>
      $composableBuilder(
        column: $table.feedOrderMode,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> spaceMembersRefs<T extends Object>(
    Expression<T> Function($$SpaceMembersTableAnnotationComposer a) f,
  ) {
    final $$SpaceMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceMembers,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.spaceMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memberLocalLabelsRefs<T extends Object>(
    Expression<T> Function($$MemberLocalLabelsTableAnnotationComposer a) f,
  ) {
    final $$MemberLocalLabelsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memberLocalLabels,
          getReferencedColumn: (t) => t.spaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemberLocalLabelsTableAnnotationComposer(
                $db: $db,
                $table: $db.memberLocalLabels,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($$CategoriesTableAnnotationComposer a) f,
  ) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetPeriodsRefs<T extends Object>(
    Expression<T> Function($$BudgetPeriodsTableAnnotationComposer a) f,
  ) {
    final $$BudgetPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomeRecurrenceRulesRefs<T extends Object>(
    Expression<T> Function($$IncomeRecurrenceRulesTableAnnotationComposer a) f,
  ) {
    final $$IncomeRecurrenceRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.incomeRecurrenceRules,
          getReferencedColumn: (t) => t.spaceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IncomeRecurrenceRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.incomeRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpacesTable,
          Space,
          $$SpacesTableFilterComposer,
          $$SpacesTableOrderingComposer,
          $$SpacesTableAnnotationComposer,
          $$SpacesTableCreateCompanionBuilder,
          $$SpacesTableUpdateCompanionBuilder,
          (Space, $$SpacesTableReferences),
          Space,
          PrefetchHooks Function({
            bool spaceMembersRefs,
            bool memberLocalLabelsRefs,
            bool categoriesRefs,
            bool budgetPeriodsRefs,
            bool incomeRecurrenceRulesRefs,
            bool incomesRefs,
            bool paymentsRefs,
          })
        > {
  $$SpacesTableTableManager(_$AppDatabase db, $SpacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<SpaceType> spaceType = const Value.absent(),
                Value<BudgetMode> budgetMode = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<StorageMode> storageMode = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int?> maxMembers = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<Decimal?> manualBalance = const Value.absent(),
                Value<DateTime?> manualBalanceUpdatedAt = const Value.absent(),
                Value<int> minSchemaVersion = const Value.absent(),
                Value<FeedOrderMode> feedOrderMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion(
                id: id,
                title: title,
                spaceType: spaceType,
                budgetMode: budgetMode,
                ownerId: ownerId,
                storageMode: storageMode,
                countryCode: countryCode,
                timezone: timezone,
                currencyCode: currencyCode,
                maxMembers: maxMembers,
                isArchived: isArchived,
                manualBalance: manualBalance,
                manualBalanceUpdatedAt: manualBalanceUpdatedAt,
                minSchemaVersion: minSchemaVersion,
                feedOrderMode: feedOrderMode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required SpaceType spaceType,
                required BudgetMode budgetMode,
                required String ownerId,
                required StorageMode storageMode,
                Value<String?> countryCode = const Value.absent(),
                required String timezone,
                required String currencyCode,
                Value<int?> maxMembers = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<Decimal?> manualBalance = const Value.absent(),
                Value<DateTime?> manualBalanceUpdatedAt = const Value.absent(),
                Value<int> minSchemaVersion = const Value.absent(),
                Value<FeedOrderMode> feedOrderMode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion.insert(
                id: id,
                title: title,
                spaceType: spaceType,
                budgetMode: budgetMode,
                ownerId: ownerId,
                storageMode: storageMode,
                countryCode: countryCode,
                timezone: timezone,
                currencyCode: currencyCode,
                maxMembers: maxMembers,
                isArchived: isArchived,
                manualBalance: manualBalance,
                manualBalanceUpdatedAt: manualBalanceUpdatedAt,
                minSchemaVersion: minSchemaVersion,
                feedOrderMode: feedOrderMode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpacesTable, Space>(table),
                  $$SpacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                spaceMembersRefs = false,
                memberLocalLabelsRefs = false,
                categoriesRefs = false,
                budgetPeriodsRefs = false,
                incomeRecurrenceRulesRefs = false,
                incomesRefs = false,
                paymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (spaceMembersRefs) db.spaceMembers,
                    if (memberLocalLabelsRefs) db.memberLocalLabels,
                    if (categoriesRefs) db.categories,
                    if (budgetPeriodsRefs) db.budgetPeriods,
                    if (incomeRecurrenceRulesRefs) db.incomeRecurrenceRules,
                    if (incomesRefs) db.incomes,
                    if (paymentsRefs) db.payments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (spaceMembersRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          SpaceMember
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._spaceMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).spaceMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memberLocalLabelsRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          MemberLocalLabel
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._memberLocalLabelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).memberLocalLabelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoriesRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          Category
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetPeriodsRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          BudgetPeriod
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._budgetPeriodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetPeriodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomeRecurrenceRulesRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          IncomeRecurrenceRule
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._incomeRecurrenceRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).incomeRecurrenceRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomesRefs)
                        await $_getPrefetchedData<Space, $SpacesTable, Income>(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._incomesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).incomesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<Space, $SpacesTable, Payment>(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SpacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpacesTable,
      Space,
      $$SpacesTableFilterComposer,
      $$SpacesTableOrderingComposer,
      $$SpacesTableAnnotationComposer,
      $$SpacesTableCreateCompanionBuilder,
      $$SpacesTableUpdateCompanionBuilder,
      (Space, $$SpacesTableReferences),
      Space,
      PrefetchHooks Function({
        bool spaceMembersRefs,
        bool memberLocalLabelsRefs,
        bool categoriesRefs,
        bool budgetPeriodsRefs,
        bool incomeRecurrenceRulesRefs,
        bool incomesRefs,
        bool paymentsRefs,
      })
    >;
typedef $$SpaceMembersTableCreateCompanionBuilder =
    SpaceMembersCompanion Function({
      required String spaceId,
      required String userId,
      required DateTime joinedAt,
      Value<int> rowid,
    });
typedef $$SpaceMembersTableUpdateCompanionBuilder =
    SpaceMembersCompanion Function({
      Value<String> spaceId,
      Value<String> userId,
      Value<DateTime> joinedAt,
      Value<int> rowid,
    });

final class $$SpaceMembersTableReferences
    extends BaseReferences<_$AppDatabase, $SpaceMembersTable, SpaceMember> {
  $$SpaceMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('space_members__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpaceMembersTableFilterComposer
    extends Composer<_$AppDatabase, $SpaceMembersTable> {
  $$SpaceMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $SpaceMembersTable> {
  $$SpaceMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpaceMembersTable> {
  $$SpaceMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpaceMembersTable,
          SpaceMember,
          $$SpaceMembersTableFilterComposer,
          $$SpaceMembersTableOrderingComposer,
          $$SpaceMembersTableAnnotationComposer,
          $$SpaceMembersTableCreateCompanionBuilder,
          $$SpaceMembersTableUpdateCompanionBuilder,
          (SpaceMember, $$SpaceMembersTableReferences),
          SpaceMember,
          PrefetchHooks Function({bool spaceId})
        > {
  $$SpaceMembersTableTableManager(_$AppDatabase db, $SpaceMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpaceMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpaceMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpaceMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> spaceId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpaceMembersCompanion(
                spaceId: spaceId,
                userId: userId,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String spaceId,
                required String userId,
                required DateTime joinedAt,
                Value<int> rowid = const Value.absent(),
              }) => SpaceMembersCompanion.insert(
                spaceId: spaceId,
                userId: userId,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpaceMembersTable, SpaceMember>(table),
                  $$SpaceMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({spaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (spaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.spaceId,
                        referencedTable: $$SpaceMembersTableReferences
                            ._spaceIdTable(db),
                        referencedColumn: $$SpaceMembersTableReferences
                            ._spaceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpaceMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpaceMembersTable,
      SpaceMember,
      $$SpaceMembersTableFilterComposer,
      $$SpaceMembersTableOrderingComposer,
      $$SpaceMembersTableAnnotationComposer,
      $$SpaceMembersTableCreateCompanionBuilder,
      $$SpaceMembersTableUpdateCompanionBuilder,
      (SpaceMember, $$SpaceMembersTableReferences),
      SpaceMember,
      PrefetchHooks Function({bool spaceId})
    >;
typedef $$MemberLocalLabelsTableCreateCompanionBuilder =
    MemberLocalLabelsCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      required DateTime clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      required String spaceId,
      required String viewerUserId,
      required String targetUserId,
      Value<String?> localName,
      Value<String?> localRole,
      Value<int> rowid,
    });
typedef $$MemberLocalLabelsTableUpdateCompanionBuilder =
    MemberLocalLabelsCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      Value<DateTime> clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      Value<String> spaceId,
      Value<String> viewerUserId,
      Value<String> targetUserId,
      Value<String?> localName,
      Value<String?> localRole,
      Value<int> rowid,
    });

final class $$MemberLocalLabelsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MemberLocalLabelsTable,
          MemberLocalLabel
        > {
  $$MemberLocalLabelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('member_local_labels__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemberLocalLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $MemberLocalLabelsTable> {
  $$MemberLocalLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewerUserId => $composableBuilder(
    column: $table.viewerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetUserId => $composableBuilder(
    column: $table.targetUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localRole => $composableBuilder(
    column: $table.localRole,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemberLocalLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemberLocalLabelsTable> {
  $$MemberLocalLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewerUserId => $composableBuilder(
    column: $table.viewerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUserId => $composableBuilder(
    column: $table.targetUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localRole => $composableBuilder(
    column: $table.localRole,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemberLocalLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemberLocalLabelsTable> {
  $$MemberLocalLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get viewerUserId => $composableBuilder(
    column: $table.viewerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetUserId => $composableBuilder(
    column: $table.targetUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localName =>
      $composableBuilder(column: $table.localName, builder: (column) => column);

  GeneratedColumn<String> get localRole =>
      $composableBuilder(column: $table.localRole, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemberLocalLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemberLocalLabelsTable,
          MemberLocalLabel,
          $$MemberLocalLabelsTableFilterComposer,
          $$MemberLocalLabelsTableOrderingComposer,
          $$MemberLocalLabelsTableAnnotationComposer,
          $$MemberLocalLabelsTableCreateCompanionBuilder,
          $$MemberLocalLabelsTableUpdateCompanionBuilder,
          (MemberLocalLabel, $$MemberLocalLabelsTableReferences),
          MemberLocalLabel,
          PrefetchHooks Function({bool spaceId})
        > {
  $$MemberLocalLabelsTableTableManager(
    _$AppDatabase db,
    $MemberLocalLabelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberLocalLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberLocalLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemberLocalLabelsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> viewerUserId = const Value.absent(),
                Value<String> targetUserId = const Value.absent(),
                Value<String?> localName = const Value.absent(),
                Value<String?> localRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberLocalLabelsCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                spaceId: spaceId,
                viewerUserId: viewerUserId,
                targetUserId: targetUserId,
                localName: localName,
                localRole: localRole,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String spaceId,
                required String viewerUserId,
                required String targetUserId,
                Value<String?> localName = const Value.absent(),
                Value<String?> localRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberLocalLabelsCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                spaceId: spaceId,
                viewerUserId: viewerUserId,
                targetUserId: targetUserId,
                localName: localName,
                localRole: localRole,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemberLocalLabelsTable, MemberLocalLabel>(table),
                  $$MemberLocalLabelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({spaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (spaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.spaceId,
                        referencedTable: $$MemberLocalLabelsTableReferences
                            ._spaceIdTable(db),
                        referencedColumn: $$MemberLocalLabelsTableReferences
                            ._spaceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MemberLocalLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemberLocalLabelsTable,
      MemberLocalLabel,
      $$MemberLocalLabelsTableFilterComposer,
      $$MemberLocalLabelsTableOrderingComposer,
      $$MemberLocalLabelsTableAnnotationComposer,
      $$MemberLocalLabelsTableCreateCompanionBuilder,
      $$MemberLocalLabelsTableUpdateCompanionBuilder,
      (MemberLocalLabel, $$MemberLocalLabelsTableReferences),
      MemberLocalLabel,
      PrefetchHooks Function({bool spaceId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      required DateTime clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      required String userId,
      required String nickname,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      Value<DateTime> clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      Value<String> userId,
      Value<String> nickname,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                userId: userId,
                nickname: nickname,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String userId,
                required String nickname,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                userId: userId,
                nickname: nickname,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<bool> isDeleted,
  Value<SyncStatus> syncStatus,
  Value<String?> lastModifiedBy,
  required DateTime clientEditedAt,
  Value<DateTime?> serverReceivedAt,
  required String id,
  required String spaceId,
  required String title,
  Value<String?> color,
  Value<String?> icon,
  Value<ExpenseType> expenseType,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<bool> isDeleted,
  Value<SyncStatus> syncStatus,
  Value<String?> lastModifiedBy,
  Value<DateTime> clientEditedAt,
  Value<DateTime?> serverReceivedAt,
  Value<String> id,
  Value<String> spaceId,
  Value<String> title,
  Value<String?> color,
  Value<String?> icon,
  Value<ExpenseType> expenseType,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('categories__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'categories__id__payments__category_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseType, ExpenseType, String>
  get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseType, String> get expenseType =>
      $composableBuilder(
        column: $table.expenseType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool spaceId, bool paymentsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<ExpenseType> expenseType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                title: title,
                color: color,
                icon: icon,
                expenseType: expenseType,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String id,
                required String spaceId,
                required String title,
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<ExpenseType> expenseType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                title: title,
                color: color,
                icon: icon,
                expenseType: expenseType,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({spaceId = false, paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (spaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.spaceId,
                        referencedTable: $$CategoriesTableReferences
                            ._spaceIdTable(db),
                        referencedColumn: $$CategoriesTableReferences
                            ._spaceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Payment
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).paymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool spaceId, bool paymentsRefs})
    >;
typedef $$BudgetPeriodsTableCreateCompanionBuilder =
    BudgetPeriodsCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      required DateTime clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      required String id,
      required String spaceId,
      required PeriodType periodType,
      required CalendarDate startDate,
      Value<CalendarDate?> endDate,
      Value<CalendarDate?> windowStart,
      Value<CalendarDate?> windowEnd,
      Value<CalendarDate?> anchorDate,
      Value<bool> holidayDataIncomplete,
      Value<CalendarDate?> deadlineDate,
      Value<bool> deadlineIsHard,
      Value<Decimal?> budgetTarget,
      Value<DateTime?> unfrozenUntil,
      Value<String?> unfreezeReason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BudgetPeriodsTableUpdateCompanionBuilder =
    BudgetPeriodsCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      Value<DateTime> clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      Value<String> id,
      Value<String> spaceId,
      Value<PeriodType> periodType,
      Value<CalendarDate> startDate,
      Value<CalendarDate?> endDate,
      Value<CalendarDate?> windowStart,
      Value<CalendarDate?> windowEnd,
      Value<CalendarDate?> anchorDate,
      Value<bool> holidayDataIncomplete,
      Value<CalendarDate?> deadlineDate,
      Value<bool> deadlineIsHard,
      Value<Decimal?> budgetTarget,
      Value<DateTime?> unfrozenUntil,
      Value<String?> unfreezeReason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BudgetPeriodsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetPeriodsTable, BudgetPeriod> {
  $$BudgetPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('budget_periods__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: 'budget_periods__id__incomes__budget_period_id',
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager(
      $_db,
      $_db.incomes,
    ).filter((f) => f.budgetPeriodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'budget_periods__id__payments__budget_period_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.budgetPeriodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BudgetPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetPeriodsTable> {
  $$BudgetPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PeriodType, PeriodType, String>
  get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get windowEnd => $composableBuilder(
    column: $table.windowEnd,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get holidayDataIncomplete => $composableBuilder(
    column: $table.holidayDataIncomplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get deadlineDate => $composableBuilder(
    column: $table.deadlineDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get deadlineIsHard => $composableBuilder(
    column: $table.deadlineIsHard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get budgetTarget =>
      $composableBuilder(
        column: $table.budgetTarget,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get unfrozenUntil => $composableBuilder(
    column: $table.unfrozenUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unfreezeReason => $composableBuilder(
    column: $table.unfreezeReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.budgetPeriodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.budgetPeriodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetPeriodsTable> {
  $$BudgetPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowEnd => $composableBuilder(
    column: $table.windowEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get holidayDataIncomplete => $composableBuilder(
    column: $table.holidayDataIncomplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineDate => $composableBuilder(
    column: $table.deadlineDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deadlineIsHard => $composableBuilder(
    column: $table.deadlineIsHard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetTarget => $composableBuilder(
    column: $table.budgetTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unfrozenUntil => $composableBuilder(
    column: $table.unfrozenUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unfreezeReason => $composableBuilder(
    column: $table.unfreezeReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetPeriodsTable> {
  $$BudgetPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PeriodType, String> get periodType =>
      $composableBuilder(
        column: $table.periodType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CalendarDate, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get windowStart =>
      $composableBuilder(
        column: $table.windowStart,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get windowEnd =>
      $composableBuilder(column: $table.windowEnd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get anchorDate =>
      $composableBuilder(
        column: $table.anchorDate,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get holidayDataIncomplete => $composableBuilder(
    column: $table.holidayDataIncomplete,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get deadlineDate =>
      $composableBuilder(
        column: $table.deadlineDate,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get deadlineIsHard => $composableBuilder(
    column: $table.deadlineIsHard,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal?, String> get budgetTarget =>
      $composableBuilder(
        column: $table.budgetTarget,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get unfrozenUntil => $composableBuilder(
    column: $table.unfrozenUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unfreezeReason => $composableBuilder(
    column: $table.unfreezeReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.budgetPeriodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.budgetPeriodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetPeriodsTable,
          BudgetPeriod,
          $$BudgetPeriodsTableFilterComposer,
          $$BudgetPeriodsTableOrderingComposer,
          $$BudgetPeriodsTableAnnotationComposer,
          $$BudgetPeriodsTableCreateCompanionBuilder,
          $$BudgetPeriodsTableUpdateCompanionBuilder,
          (BudgetPeriod, $$BudgetPeriodsTableReferences),
          BudgetPeriod,
          PrefetchHooks Function({
            bool spaceId,
            bool incomesRefs,
            bool paymentsRefs,
          })
        > {
  $$BudgetPeriodsTableTableManager(_$AppDatabase db, $BudgetPeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<PeriodType> periodType = const Value.absent(),
                Value<CalendarDate> startDate = const Value.absent(),
                Value<CalendarDate?> endDate = const Value.absent(),
                Value<CalendarDate?> windowStart = const Value.absent(),
                Value<CalendarDate?> windowEnd = const Value.absent(),
                Value<CalendarDate?> anchorDate = const Value.absent(),
                Value<bool> holidayDataIncomplete = const Value.absent(),
                Value<CalendarDate?> deadlineDate = const Value.absent(),
                Value<bool> deadlineIsHard = const Value.absent(),
                Value<Decimal?> budgetTarget = const Value.absent(),
                Value<DateTime?> unfrozenUntil = const Value.absent(),
                Value<String?> unfreezeReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetPeriodsCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                periodType: periodType,
                startDate: startDate,
                endDate: endDate,
                windowStart: windowStart,
                windowEnd: windowEnd,
                anchorDate: anchorDate,
                holidayDataIncomplete: holidayDataIncomplete,
                deadlineDate: deadlineDate,
                deadlineIsHard: deadlineIsHard,
                budgetTarget: budgetTarget,
                unfrozenUntil: unfrozenUntil,
                unfreezeReason: unfreezeReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String id,
                required String spaceId,
                required PeriodType periodType,
                required CalendarDate startDate,
                Value<CalendarDate?> endDate = const Value.absent(),
                Value<CalendarDate?> windowStart = const Value.absent(),
                Value<CalendarDate?> windowEnd = const Value.absent(),
                Value<CalendarDate?> anchorDate = const Value.absent(),
                Value<bool> holidayDataIncomplete = const Value.absent(),
                Value<CalendarDate?> deadlineDate = const Value.absent(),
                Value<bool> deadlineIsHard = const Value.absent(),
                Value<Decimal?> budgetTarget = const Value.absent(),
                Value<DateTime?> unfrozenUntil = const Value.absent(),
                Value<String?> unfreezeReason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BudgetPeriodsCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                periodType: periodType,
                startDate: startDate,
                endDate: endDate,
                windowStart: windowStart,
                windowEnd: windowEnd,
                anchorDate: anchorDate,
                holidayDataIncomplete: holidayDataIncomplete,
                deadlineDate: deadlineDate,
                deadlineIsHard: deadlineIsHard,
                budgetTarget: budgetTarget,
                unfrozenUntil: unfrozenUntil,
                unfreezeReason: unfreezeReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetPeriodsTable, BudgetPeriod>(table),
                  $$BudgetPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({spaceId = false, incomesRefs = false, paymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (incomesRefs) db.incomes,
                    if (paymentsRefs) db.payments,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (spaceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.spaceId,
                            referencedTable: $$BudgetPeriodsTableReferences
                                ._spaceIdTable(db),
                            referencedColumn: $$BudgetPeriodsTableReferences
                                ._spaceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (incomesRefs)
                        await $_getPrefetchedData<
                          BudgetPeriod,
                          $BudgetPeriodsTable,
                          Income
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetPeriodsTableReferences
                              ._incomesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetPeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).incomesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetPeriodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          BudgetPeriod,
                          $BudgetPeriodsTable,
                          Payment
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetPeriodsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetPeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetPeriodId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BudgetPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetPeriodsTable,
      BudgetPeriod,
      $$BudgetPeriodsTableFilterComposer,
      $$BudgetPeriodsTableOrderingComposer,
      $$BudgetPeriodsTableAnnotationComposer,
      $$BudgetPeriodsTableCreateCompanionBuilder,
      $$BudgetPeriodsTableUpdateCompanionBuilder,
      (BudgetPeriod, $$BudgetPeriodsTableReferences),
      BudgetPeriod,
      PrefetchHooks Function({
        bool spaceId,
        bool incomesRefs,
        bool paymentsRefs,
      })
    >;
typedef $$IncomeRecurrenceRulesTableCreateCompanionBuilder =
    IncomeRecurrenceRulesCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      required DateTime clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      required String id,
      required String spaceId,
      required String title,
      Value<Decimal?> amount,
      Value<bool> isAnchor,
      required ScheduleType scheduleType,
      Value<int?> fixedDay,
      Value<WeekdayOrdinal?> weekdayOrdinal,
      Value<Weekday?> weekdayDay,
      Value<int?> dateRangeStart,
      Value<int?> dateRangeEnd,
      Value<BoundaryAnchor?> boundaryAnchor,
      Value<int?> boundaryCount,
      Value<String?> countryCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IncomeRecurrenceRulesTableUpdateCompanionBuilder =
    IncomeRecurrenceRulesCompanion Function({
      Value<bool> isDeleted,
      Value<SyncStatus> syncStatus,
      Value<String?> lastModifiedBy,
      Value<DateTime> clientEditedAt,
      Value<DateTime?> serverReceivedAt,
      Value<String> id,
      Value<String> spaceId,
      Value<String> title,
      Value<Decimal?> amount,
      Value<bool> isAnchor,
      Value<ScheduleType> scheduleType,
      Value<int?> fixedDay,
      Value<WeekdayOrdinal?> weekdayOrdinal,
      Value<Weekday?> weekdayDay,
      Value<int?> dateRangeStart,
      Value<int?> dateRangeEnd,
      Value<BoundaryAnchor?> boundaryAnchor,
      Value<int?> boundaryCount,
      Value<String?> countryCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$IncomeRecurrenceRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IncomeRecurrenceRulesTable,
          IncomeRecurrenceRule
        > {
  $$IncomeRecurrenceRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('income_recurrence_rules__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: 'income_recurrence_rules__id__incomes__recurrence_rule_id',
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager($_db, $_db.incomes).filter(
      (f) => f.recurrenceRuleId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IncomeRecurrenceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeRecurrenceRulesTable> {
  $$IncomeRecurrenceRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isAnchor => $composableBuilder(
    column: $table.isAnchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleType, ScheduleType, String>
  get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get fixedDay => $composableBuilder(
    column: $table.fixedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeekdayOrdinal?, WeekdayOrdinal, String>
  get weekdayOrdinal => $composableBuilder(
    column: $table.weekdayOrdinal,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Weekday?, Weekday, String> get weekdayDay =>
      $composableBuilder(
        column: $table.weekdayDay,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get dateRangeStart => $composableBuilder(
    column: $table.dateRangeStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateRangeEnd => $composableBuilder(
    column: $table.dateRangeEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BoundaryAnchor?, BoundaryAnchor, String>
  get boundaryAnchor => $composableBuilder(
    column: $table.boundaryAnchor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get boundaryCount => $composableBuilder(
    column: $table.boundaryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.recurrenceRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomeRecurrenceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeRecurrenceRulesTable> {
  $$IncomeRecurrenceRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAnchor => $composableBuilder(
    column: $table.isAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fixedDay => $composableBuilder(
    column: $table.fixedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdayOrdinal => $composableBuilder(
    column: $table.weekdayOrdinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdayDay => $composableBuilder(
    column: $table.weekdayDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateRangeStart => $composableBuilder(
    column: $table.dateRangeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateRangeEnd => $composableBuilder(
    column: $table.dateRangeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boundaryAnchor => $composableBuilder(
    column: $table.boundaryAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get boundaryCount => $composableBuilder(
    column: $table.boundaryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeRecurrenceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeRecurrenceRulesTable> {
  $$IncomeRecurrenceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isAnchor =>
      $composableBuilder(column: $table.isAnchor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleType, String> get scheduleType =>
      $composableBuilder(
        column: $table.scheduleType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get fixedDay =>
      $composableBuilder(column: $table.fixedDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeekdayOrdinal?, String>
  get weekdayOrdinal => $composableBuilder(
    column: $table.weekdayOrdinal,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Weekday?, String> get weekdayDay =>
      $composableBuilder(
        column: $table.weekdayDay,
        builder: (column) => column,
      );

  GeneratedColumn<int> get dateRangeStart => $composableBuilder(
    column: $table.dateRangeStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateRangeEnd => $composableBuilder(
    column: $table.dateRangeEnd,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BoundaryAnchor?, String>
  get boundaryAnchor => $composableBuilder(
    column: $table.boundaryAnchor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get boundaryCount => $composableBuilder(
    column: $table.boundaryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.recurrenceRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomeRecurrenceRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeRecurrenceRulesTable,
          IncomeRecurrenceRule,
          $$IncomeRecurrenceRulesTableFilterComposer,
          $$IncomeRecurrenceRulesTableOrderingComposer,
          $$IncomeRecurrenceRulesTableAnnotationComposer,
          $$IncomeRecurrenceRulesTableCreateCompanionBuilder,
          $$IncomeRecurrenceRulesTableUpdateCompanionBuilder,
          (IncomeRecurrenceRule, $$IncomeRecurrenceRulesTableReferences),
          IncomeRecurrenceRule,
          PrefetchHooks Function({bool spaceId, bool incomesRefs})
        > {
  $$IncomeRecurrenceRulesTableTableManager(
    _$AppDatabase db,
    $IncomeRecurrenceRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeRecurrenceRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IncomeRecurrenceRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IncomeRecurrenceRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<Decimal?> amount = const Value.absent(),
                Value<bool> isAnchor = const Value.absent(),
                Value<ScheduleType> scheduleType = const Value.absent(),
                Value<int?> fixedDay = const Value.absent(),
                Value<WeekdayOrdinal?> weekdayOrdinal = const Value.absent(),
                Value<Weekday?> weekdayDay = const Value.absent(),
                Value<int?> dateRangeStart = const Value.absent(),
                Value<int?> dateRangeEnd = const Value.absent(),
                Value<BoundaryAnchor?> boundaryAnchor = const Value.absent(),
                Value<int?> boundaryCount = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeRecurrenceRulesCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                title: title,
                amount: amount,
                isAnchor: isAnchor,
                scheduleType: scheduleType,
                fixedDay: fixedDay,
                weekdayOrdinal: weekdayOrdinal,
                weekdayDay: weekdayDay,
                dateRangeStart: dateRangeStart,
                dateRangeEnd: dateRangeEnd,
                boundaryAnchor: boundaryAnchor,
                boundaryCount: boundaryCount,
                countryCode: countryCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String id,
                required String spaceId,
                required String title,
                Value<Decimal?> amount = const Value.absent(),
                Value<bool> isAnchor = const Value.absent(),
                required ScheduleType scheduleType,
                Value<int?> fixedDay = const Value.absent(),
                Value<WeekdayOrdinal?> weekdayOrdinal = const Value.absent(),
                Value<Weekday?> weekdayDay = const Value.absent(),
                Value<int?> dateRangeStart = const Value.absent(),
                Value<int?> dateRangeEnd = const Value.absent(),
                Value<BoundaryAnchor?> boundaryAnchor = const Value.absent(),
                Value<int?> boundaryCount = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IncomeRecurrenceRulesCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                title: title,
                amount: amount,
                isAnchor: isAnchor,
                scheduleType: scheduleType,
                fixedDay: fixedDay,
                weekdayOrdinal: weekdayOrdinal,
                weekdayDay: weekdayDay,
                dateRangeStart: dateRangeStart,
                dateRangeEnd: dateRangeEnd,
                boundaryAnchor: boundaryAnchor,
                boundaryCount: boundaryCount,
                countryCode: countryCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $IncomeRecurrenceRulesTable,
                    IncomeRecurrenceRule
                  >(table),
                  $$IncomeRecurrenceRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({spaceId = false, incomesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (incomesRefs) db.incomes],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (spaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.spaceId,
                        referencedTable: $$IncomeRecurrenceRulesTableReferences
                            ._spaceIdTable(db),
                        referencedColumn: $$IncomeRecurrenceRulesTableReferences
                            ._spaceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (incomesRefs)
                    await $_getPrefetchedData<
                      IncomeRecurrenceRule,
                      $IncomeRecurrenceRulesTable,
                      Income
                    >(
                      currentTable: table,
                      referencedTable: $$IncomeRecurrenceRulesTableReferences
                          ._incomesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IncomeRecurrenceRulesTableReferences(
                            db,
                            table,
                            p0,
                          ).incomesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.recurrenceRuleId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IncomeRecurrenceRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeRecurrenceRulesTable,
      IncomeRecurrenceRule,
      $$IncomeRecurrenceRulesTableFilterComposer,
      $$IncomeRecurrenceRulesTableOrderingComposer,
      $$IncomeRecurrenceRulesTableAnnotationComposer,
      $$IncomeRecurrenceRulesTableCreateCompanionBuilder,
      $$IncomeRecurrenceRulesTableUpdateCompanionBuilder,
      (IncomeRecurrenceRule, $$IncomeRecurrenceRulesTableReferences),
      IncomeRecurrenceRule,
      PrefetchHooks Function({bool spaceId, bool incomesRefs})
    >;
typedef $$IncomesTableCreateCompanionBuilder = IncomesCompanion Function({
  Value<bool> isDeleted,
  Value<SyncStatus> syncStatus,
  Value<String?> lastModifiedBy,
  required DateTime clientEditedAt,
  Value<DateTime?> serverReceivedAt,
  required String id,
  required String spaceId,
  Value<String?> recurrenceRuleId,
  required String title,
  Value<Decimal?> amount,
  required CalendarDate expectedDate,
  Value<CalendarDate?> actualDate,
  Value<String?> budgetPeriodId,
  Value<int> sortOrder,
  Value<bool> isPaid,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$IncomesTableUpdateCompanionBuilder = IncomesCompanion Function({
  Value<bool> isDeleted,
  Value<SyncStatus> syncStatus,
  Value<String?> lastModifiedBy,
  Value<DateTime> clientEditedAt,
  Value<DateTime?> serverReceivedAt,
  Value<String> id,
  Value<String> spaceId,
  Value<String?> recurrenceRuleId,
  Value<String> title,
  Value<Decimal?> amount,
  Value<CalendarDate> expectedDate,
  Value<CalendarDate?> actualDate,
  Value<String?> budgetPeriodId,
  Value<int> sortOrder,
  Value<bool> isPaid,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$IncomesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomesTable, Income> {
  $$IncomesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('incomes__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IncomeRecurrenceRulesTable _recurrenceRuleIdTable(_$AppDatabase db) =>
      db.incomeRecurrenceRules.createAlias(
        'incomes__recurrence_rule_id__income_recurrence_rules__id',
      );

  $$IncomeRecurrenceRulesTableProcessedTableManager? get recurrenceRuleId {
    final $_column = $_itemColumn<String>('recurrence_rule_id');
    if ($_column == null) return null;
    final manager = $$IncomeRecurrenceRulesTableTableManager(
      $_db,
      $_db.incomeRecurrenceRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurrenceRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetPeriodsTable _budgetPeriodIdTable(_$AppDatabase db) => db
      .budgetPeriods
      .createAlias('incomes__budget_period_id__budget_periods__id');

  $$BudgetPeriodsTableProcessedTableManager? get budgetPeriodId {
    final $_column = $_itemColumn<String>('budget_period_id');
    if ($_column == null) return null;
    final manager = $$BudgetPeriodsTableTableManager(
      $_db,
      $_db.budgetPeriods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetPeriodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncomesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncomeRecurrenceRulesTableFilterComposer get recurrenceRuleId {
    final $$IncomeRecurrenceRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceRuleId,
          referencedTable: $db.incomeRecurrenceRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IncomeRecurrenceRulesTableFilterComposer(
                $db: $db,
                $table: $db.incomeRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BudgetPeriodsTableFilterComposer get budgetPeriodId {
    final $$BudgetPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPeriodId,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncomeRecurrenceRulesTableOrderingComposer get recurrenceRuleId {
    final $$IncomeRecurrenceRulesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceRuleId,
          referencedTable: $db.incomeRecurrenceRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IncomeRecurrenceRulesTableOrderingComposer(
                $db: $db,
                $table: $db.incomeRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BudgetPeriodsTableOrderingComposer get budgetPeriodId {
    final $$BudgetPeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPeriodId,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get expectedDate =>
      $composableBuilder(
        column: $table.expectedDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get actualDate =>
      $composableBuilder(
        column: $table.actualDate,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IncomeRecurrenceRulesTableAnnotationComposer get recurrenceRuleId {
    final $$IncomeRecurrenceRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceRuleId,
          referencedTable: $db.incomeRecurrenceRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IncomeRecurrenceRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.incomeRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BudgetPeriodsTableAnnotationComposer get budgetPeriodId {
    final $$BudgetPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPeriodId,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomesTable,
          Income,
          $$IncomesTableFilterComposer,
          $$IncomesTableOrderingComposer,
          $$IncomesTableAnnotationComposer,
          $$IncomesTableCreateCompanionBuilder,
          $$IncomesTableUpdateCompanionBuilder,
          (Income, $$IncomesTableReferences),
          Income,
          PrefetchHooks Function({
            bool spaceId,
            bool recurrenceRuleId,
            bool budgetPeriodId,
          })
        > {
  $$IncomesTableTableManager(_$AppDatabase db, $IncomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<Decimal?> amount = const Value.absent(),
                Value<CalendarDate> expectedDate = const Value.absent(),
                Value<CalendarDate?> actualDate = const Value.absent(),
                Value<String?> budgetPeriodId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                recurrenceRuleId: recurrenceRuleId,
                title: title,
                amount: amount,
                expectedDate: expectedDate,
                actualDate: actualDate,
                budgetPeriodId: budgetPeriodId,
                sortOrder: sortOrder,
                isPaid: isPaid,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String id,
                required String spaceId,
                Value<String?> recurrenceRuleId = const Value.absent(),
                required String title,
                Value<Decimal?> amount = const Value.absent(),
                required CalendarDate expectedDate,
                Value<CalendarDate?> actualDate = const Value.absent(),
                Value<String?> budgetPeriodId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                recurrenceRuleId: recurrenceRuleId,
                title: title,
                amount: amount,
                expectedDate: expectedDate,
                actualDate: actualDate,
                budgetPeriodId: budgetPeriodId,
                sortOrder: sortOrder,
                isPaid: isPaid,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomesTable, Income>(table),
                  $$IncomesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                spaceId = false,
                recurrenceRuleId = false,
                budgetPeriodId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (spaceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.spaceId,
                            referencedTable: $$IncomesTableReferences
                                ._spaceIdTable(db),
                            referencedColumn: $$IncomesTableReferences
                                ._spaceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recurrenceRuleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recurrenceRuleId,
                            referencedTable: $$IncomesTableReferences
                                ._recurrenceRuleIdTable(db),
                            referencedColumn: $$IncomesTableReferences
                                ._recurrenceRuleIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (budgetPeriodId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.budgetPeriodId,
                            referencedTable: $$IncomesTableReferences
                                ._budgetPeriodIdTable(db),
                            referencedColumn: $$IncomesTableReferences
                                ._budgetPeriodIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$IncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomesTable,
      Income,
      $$IncomesTableFilterComposer,
      $$IncomesTableOrderingComposer,
      $$IncomesTableAnnotationComposer,
      $$IncomesTableCreateCompanionBuilder,
      $$IncomesTableUpdateCompanionBuilder,
      (Income, $$IncomesTableReferences),
      Income,
      PrefetchHooks Function({
        bool spaceId,
        bool recurrenceRuleId,
        bool budgetPeriodId,
      })
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<bool> isDeleted,
  Value<SyncStatus> syncStatus,
  Value<String?> lastModifiedBy,
  required DateTime clientEditedAt,
  Value<DateTime?> serverReceivedAt,
  required String id,
  required String spaceId,
  Value<String?> budgetPeriodId,
  Value<PeriodAssignment> periodAssignment,
  Value<String?> categoryId,
  Value<String?> groupRecurringId,
  required String title,
  required Decimal amount,
  required CalendarDate dueDate,
  required ExpenseType expenseType,
  Value<int> sortOrder,
  Value<bool> isPaid,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<bool> isDeleted,
  Value<SyncStatus> syncStatus,
  Value<String?> lastModifiedBy,
  Value<DateTime> clientEditedAt,
  Value<DateTime?> serverReceivedAt,
  Value<String> id,
  Value<String> spaceId,
  Value<String?> budgetPeriodId,
  Value<PeriodAssignment> periodAssignment,
  Value<String?> categoryId,
  Value<String?> groupRecurringId,
  Value<String> title,
  Value<Decimal> amount,
  Value<CalendarDate> dueDate,
  Value<ExpenseType> expenseType,
  Value<int> sortOrder,
  Value<bool> isPaid,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('payments__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetPeriodsTable _budgetPeriodIdTable(_$AppDatabase db) => db
      .budgetPeriods
      .createAlias('payments__budget_period_id__budget_periods__id');

  $$BudgetPeriodsTableProcessedTableManager? get budgetPeriodId {
    final $_column = $_itemColumn<String>('budget_period_id');
    if ($_column == null) return null;
    final manager = $$BudgetPeriodsTableTableManager(
      $_db,
      $_db.budgetPeriods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetPeriodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('payments__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PeriodAssignment, PeriodAssignment, String>
  get periodAssignment => $composableBuilder(
    column: $table.periodAssignment,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get groupRecurringId => $composableBuilder(
    column: $table.groupRecurringId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseType, ExpenseType, String>
  get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetPeriodsTableFilterComposer get budgetPeriodId {
    final $$BudgetPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPeriodId,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodAssignment => $composableBuilder(
    column: $table.periodAssignment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupRecurringId => $composableBuilder(
    column: $table.groupRecurringId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseType => $composableBuilder(
    column: $table.expenseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetPeriodsTableOrderingComposer get budgetPeriodId {
    final $$BudgetPeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPeriodId,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get clientEditedAt => $composableBuilder(
    column: $table.clientEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PeriodAssignment, String>
  get periodAssignment => $composableBuilder(
    column: $table.periodAssignment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupRecurringId => $composableBuilder(
    column: $table.groupRecurringId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseType, String> get expenseType =>
      $composableBuilder(
        column: $table.expenseType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetPeriodsTableAnnotationComposer get budgetPeriodId {
    final $$BudgetPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetPeriodId,
      referencedTable: $db.budgetPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({
            bool spaceId,
            bool budgetPeriodId,
            bool categoryId,
          })
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                Value<DateTime> clientEditedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String?> budgetPeriodId = const Value.absent(),
                Value<PeriodAssignment> periodAssignment = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> groupRecurringId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<Decimal> amount = const Value.absent(),
                Value<CalendarDate> dueDate = const Value.absent(),
                Value<ExpenseType> expenseType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                budgetPeriodId: budgetPeriodId,
                periodAssignment: periodAssignment,
                categoryId: categoryId,
                groupRecurringId: groupRecurringId,
                title: title,
                amount: amount,
                dueDate: dueDate,
                expenseType: expenseType,
                sortOrder: sortOrder,
                isPaid: isPaid,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<bool> isDeleted = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> lastModifiedBy = const Value.absent(),
                required DateTime clientEditedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                required String id,
                required String spaceId,
                Value<String?> budgetPeriodId = const Value.absent(),
                Value<PeriodAssignment> periodAssignment = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> groupRecurringId = const Value.absent(),
                required String title,
                required Decimal amount,
                required CalendarDate dueDate,
                required ExpenseType expenseType,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                isDeleted: isDeleted,
                syncStatus: syncStatus,
                lastModifiedBy: lastModifiedBy,
                clientEditedAt: clientEditedAt,
                serverReceivedAt: serverReceivedAt,
                id: id,
                spaceId: spaceId,
                budgetPeriodId: budgetPeriodId,
                periodAssignment: periodAssignment,
                categoryId: categoryId,
                groupRecurringId: groupRecurringId,
                title: title,
                amount: amount,
                dueDate: dueDate,
                expenseType: expenseType,
                sortOrder: sortOrder,
                isPaid: isPaid,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, Payment>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({spaceId = false, budgetPeriodId = false, categoryId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (spaceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.spaceId,
                            referencedTable: $$PaymentsTableReferences
                                ._spaceIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._spaceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (budgetPeriodId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.budgetPeriodId,
                            referencedTable: $$PaymentsTableReferences
                                ._budgetPeriodIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._budgetPeriodIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$PaymentsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({
        bool spaceId,
        bool budgetPeriodId,
        bool categoryId,
      })
    >;
typedef $$HolidayCacheTableCreateCompanionBuilder =
    HolidayCacheCompanion Function({
      required String id,
      required String countryCode,
      required int year,
      required String holidayDates,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$HolidayCacheTableUpdateCompanionBuilder =
    HolidayCacheCompanion Function({
      Value<String> id,
      Value<String> countryCode,
      Value<int> year,
      Value<String> holidayDates,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$HolidayCacheTableFilterComposer
    extends Composer<_$AppDatabase, $HolidayCacheTable> {
  $$HolidayCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holidayDates => $composableBuilder(
    column: $table.holidayDates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HolidayCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidayCacheTable> {
  $$HolidayCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holidayDates => $composableBuilder(
    column: $table.holidayDates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HolidayCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidayCacheTable> {
  $$HolidayCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get holidayDates => $composableBuilder(
    column: $table.holidayDates,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$HolidayCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolidayCacheTable,
          HolidayCacheData,
          $$HolidayCacheTableFilterComposer,
          $$HolidayCacheTableOrderingComposer,
          $$HolidayCacheTableAnnotationComposer,
          $$HolidayCacheTableCreateCompanionBuilder,
          $$HolidayCacheTableUpdateCompanionBuilder,
          (
            HolidayCacheData,
            BaseReferences<_$AppDatabase, $HolidayCacheTable, HolidayCacheData>,
          ),
          HolidayCacheData,
          PrefetchHooks Function()
        > {
  $$HolidayCacheTableTableManager(_$AppDatabase db, $HolidayCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidayCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidayCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidayCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> holidayDates = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidayCacheCompanion(
                id: id,
                countryCode: countryCode,
                year: year,
                holidayDates: holidayDates,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String countryCode,
                required int year,
                required String holidayDates,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => HolidayCacheCompanion.insert(
                id: id,
                countryCode: countryCode,
                year: year,
                holidayDates: holidayDates,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HolidayCacheTable, HolidayCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HolidayCacheTable,
                    HolidayCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HolidayCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolidayCacheTable,
      HolidayCacheData,
      $$HolidayCacheTableFilterComposer,
      $$HolidayCacheTableOrderingComposer,
      $$HolidayCacheTableAnnotationComposer,
      $$HolidayCacheTableCreateCompanionBuilder,
      $$HolidayCacheTableUpdateCompanionBuilder,
      (
        HolidayCacheData,
        BaseReferences<_$AppDatabase, $HolidayCacheTable, HolidayCacheData>,
      ),
      HolidayCacheData,
      PrefetchHooks Function()
    >;
typedef $$CustomNonWorkingDaysTableCreateCompanionBuilder =
    CustomNonWorkingDaysCompanion Function({
      required String id,
      required CalendarDate date,
      Value<String?> title,
      Value<String?> countryCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomNonWorkingDaysTableUpdateCompanionBuilder =
    CustomNonWorkingDaysCompanion Function({
      Value<String> id,
      Value<CalendarDate> date,
      Value<String?> title,
      Value<String?> countryCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomNonWorkingDaysTableFilterComposer
    extends Composer<_$AppDatabase, $CustomNonWorkingDaysTable> {
  $$CustomNonWorkingDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomNonWorkingDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomNonWorkingDaysTable> {
  $$CustomNonWorkingDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomNonWorkingDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomNonWorkingDaysTable> {
  $$CustomNonWorkingDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomNonWorkingDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomNonWorkingDaysTable,
          CustomNonWorkingDay,
          $$CustomNonWorkingDaysTableFilterComposer,
          $$CustomNonWorkingDaysTableOrderingComposer,
          $$CustomNonWorkingDaysTableAnnotationComposer,
          $$CustomNonWorkingDaysTableCreateCompanionBuilder,
          $$CustomNonWorkingDaysTableUpdateCompanionBuilder,
          (
            CustomNonWorkingDay,
            BaseReferences<
              _$AppDatabase,
              $CustomNonWorkingDaysTable,
              CustomNonWorkingDay
            >,
          ),
          CustomNonWorkingDay,
          PrefetchHooks Function()
        > {
  $$CustomNonWorkingDaysTableTableManager(
    _$AppDatabase db,
    $CustomNonWorkingDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomNonWorkingDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomNonWorkingDaysTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomNonWorkingDaysTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CalendarDate> date = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomNonWorkingDaysCompanion(
                id: id,
                date: date,
                title: title,
                countryCode: countryCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CalendarDate date,
                Value<String?> title = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomNonWorkingDaysCompanion.insert(
                id: id,
                date: date,
                title: title,
                countryCode: countryCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomNonWorkingDaysTable, CustomNonWorkingDay>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomNonWorkingDaysTable,
                    CustomNonWorkingDay
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomNonWorkingDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomNonWorkingDaysTable,
      CustomNonWorkingDay,
      $$CustomNonWorkingDaysTableFilterComposer,
      $$CustomNonWorkingDaysTableOrderingComposer,
      $$CustomNonWorkingDaysTableAnnotationComposer,
      $$CustomNonWorkingDaysTableCreateCompanionBuilder,
      $$CustomNonWorkingDaysTableUpdateCompanionBuilder,
      (
        CustomNonWorkingDay,
        BaseReferences<
          _$AppDatabase,
          $CustomNonWorkingDaysTable,
          CustomNonWorkingDay
        >,
      ),
      CustomNonWorkingDay,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SpacesTableTableManager get spaces =>
      $$SpacesTableTableManager(_db, _db.spaces);
  $$SpaceMembersTableTableManager get spaceMembers =>
      $$SpaceMembersTableTableManager(_db, _db.spaceMembers);
  $$MemberLocalLabelsTableTableManager get memberLocalLabels =>
      $$MemberLocalLabelsTableTableManager(_db, _db.memberLocalLabels);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$BudgetPeriodsTableTableManager get budgetPeriods =>
      $$BudgetPeriodsTableTableManager(_db, _db.budgetPeriods);
  $$IncomeRecurrenceRulesTableTableManager get incomeRecurrenceRules =>
      $$IncomeRecurrenceRulesTableTableManager(_db, _db.incomeRecurrenceRules);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$HolidayCacheTableTableManager get holidayCache =>
      $$HolidayCacheTableTableManager(_db, _db.holidayCache);
  $$CustomNonWorkingDaysTableTableManager get customNonWorkingDays =>
      $$CustomNonWorkingDaysTableTableManager(_db, _db.customNonWorkingDays);
}
