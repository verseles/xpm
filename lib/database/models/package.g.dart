// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPackageCollection on Isar {
  IsarCollection<Package> get packages => this.collection();
}

const PackageSchema = CollectionSchema(
  name: r'Package',
  id: 6192244575192772594,
  properties: {
    r'arch': PropertySchema(
      id: 0,
      name: r'arch',
      type: IsarType.stringList,
    ),
    r'defaults': PropertySchema(
      id: 1,
      name: r'defaults',
      type: IsarType.stringList,
    ),
    r'desc': PropertySchema(
      id: 2,
      name: r'desc',
      type: IsarType.string,
    ),
    r'installed': PropertySchema(
      id: 3,
      name: r'installed',
      type: IsarType.string,
    ),
    r'methods': PropertySchema(
      id: 4,
      name: r'methods',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'script': PropertySchema(
      id: 6,
      name: r'script',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 8,
      name: r'url',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 9,
      name: r'version',
      type: IsarType.string,
    )
  },
  estimateSize: _packageEstimateSize,
  serialize: _packageSerialize,
  deserialize: _packageDeserialize,
  deserializeProp: _packageDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'desc': IndexSchema(
      id: 2795170529049215929,
      name: r'desc',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'desc',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'arch': IndexSchema(
      id: -7338939058228875704,
      name: r'arch',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'arch',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'methods': IndexSchema(
      id: -8295275548635774836,
      name: r'methods',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'methods',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'defaults': IndexSchema(
      id: -2394386331792021166,
      name: r'defaults',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'defaults',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'installed': IndexSchema(
      id: -2396502518995561215,
      name: r'installed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'installed',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'repo': LinkSchema(
      id: 1196525232780566038,
      name: r'repo',
      target: r'Repo',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _packageGetId,
  getLinks: _packageGetLinks,
  attach: _packageAttach,
  version: '3.1.0+1',
);

int _packageEstimateSize(
  Package object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.arch;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.defaults;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.desc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.installed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.methods;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.script.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.version;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _packageSerialize(
  Package object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.arch);
  writer.writeStringList(offsets[1], object.defaults);
  writer.writeString(offsets[2], object.desc);
  writer.writeString(offsets[3], object.installed);
  writer.writeStringList(offsets[4], object.methods);
  writer.writeString(offsets[5], object.name);
  writer.writeString(offsets[6], object.script);
  writer.writeString(offsets[7], object.title);
  writer.writeString(offsets[8], object.url);
  writer.writeString(offsets[9], object.version);
}

Package _packageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Package();
  object.arch = reader.readStringList(offsets[0]);
  object.defaults = reader.readStringList(offsets[1]);
  object.desc = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.installed = reader.readStringOrNull(offsets[3]);
  object.methods = reader.readStringList(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.script = reader.readString(offsets[6]);
  object.title = reader.readStringOrNull(offsets[7]);
  object.url = reader.readStringOrNull(offsets[8]);
  object.version = reader.readStringOrNull(offsets[9]);
  return object;
}

P _packageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringList(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _packageGetId(Package object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _packageGetLinks(Package object) {
  return [object.repo];
}

void _packageAttach(IsarCollection<dynamic> col, Id id, Package object) {
  object.id = id;
  object.repo.attach(col, col.isar.collection<Repo>(), r'repo', id);
}

extension PackageQueryWhereSort on QueryBuilder<Package, Package, QWhere> {
  QueryBuilder<Package, Package, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PackageQueryWhere on QueryBuilder<Package, Package, QWhereClause> {
  QueryBuilder<Package, Package, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> descIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'desc',
        value: [null],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> descIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'desc',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> descEqualTo(String? desc) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'desc',
        value: [desc],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> descNotEqualTo(String? desc) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'desc',
              lower: [],
              upper: [desc],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'desc',
              lower: [desc],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'desc',
              lower: [desc],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'desc',
              lower: [],
              upper: [desc],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [null],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> titleEqualTo(String? title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> titleNotEqualTo(String? title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> archIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'arch',
        value: [null],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> archIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'arch',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> archEqualTo(List<String>? arch) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'arch',
        value: [arch],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> archNotEqualTo(List<String>? arch) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'arch',
              lower: [],
              upper: [arch],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'arch',
              lower: [arch],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'arch',
              lower: [arch],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'arch',
              lower: [],
              upper: [arch],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> methodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'methods',
        value: [null],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> methodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'methods',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> methodsEqualTo(List<String>? methods) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'methods',
        value: [methods],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> methodsNotEqualTo(List<String>? methods) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'methods',
              lower: [],
              upper: [methods],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'methods',
              lower: [methods],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'methods',
              lower: [methods],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'methods',
              lower: [],
              upper: [methods],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> defaultsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'defaults',
        value: [null],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> defaultsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'defaults',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> defaultsEqualTo(List<String>? defaults) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'defaults',
        value: [defaults],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> defaultsNotEqualTo(List<String>? defaults) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'defaults',
              lower: [],
              upper: [defaults],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'defaults',
              lower: [defaults],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'defaults',
              lower: [defaults],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'defaults',
              lower: [],
              upper: [defaults],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> installedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'installed',
        value: [null],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> installedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'installed',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> installedEqualTo(String? installed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'installed',
        value: [installed],
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterWhereClause> installedNotEqualTo(String? installed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'installed',
              lower: [],
              upper: [installed],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'installed',
              lower: [installed],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'installed',
              lower: [installed],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'installed',
              lower: [],
              upper: [installed],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PackageQueryFilter on QueryBuilder<Package, Package, QFilterCondition> {
  QueryBuilder<Package, Package, QAfterFilterCondition> archIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'arch',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'arch',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'arch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'arch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'arch',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'arch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'arch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'arch',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'arch',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arch',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'arch',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'arch',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'arch',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'arch',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'arch',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'arch',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> archLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'arch',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'defaults',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'defaults',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaults',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaults',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaults',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaults',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaults',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaults',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaults',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaults',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaults',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaults',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaults',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaults',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaults',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaults',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaults',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> defaultsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'defaults',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'desc',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'desc',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'desc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'desc',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> descIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'installed',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'installed',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'installed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'installed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'installed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'installed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installed',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> installedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'installed',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'methods',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'methods',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'methods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'methods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'methods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'methods',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'methods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'methods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'methods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'methods',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'methods',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'methods',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'methods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'methods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'methods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'methods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'methods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> methodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'methods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'script',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'script',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'script',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'script',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'script',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'script',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'script',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'script',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'script',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> scriptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'script',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'version',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'version',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'version',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: '',
      ));
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'version',
        value: '',
      ));
    });
  }
}

extension PackageQueryObject on QueryBuilder<Package, Package, QFilterCondition> {}

extension PackageQueryLinks on QueryBuilder<Package, Package, QFilterCondition> {
  QueryBuilder<Package, Package, QAfterFilterCondition> repo(FilterQuery<Repo> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'repo');
    });
  }

  QueryBuilder<Package, Package, QAfterFilterCondition> repoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'repo', 0, true, 0, true);
    });
  }
}

extension PackageQuerySortBy on QueryBuilder<Package, Package, QSortBy> {
  QueryBuilder<Package, Package, QAfterSortBy> sortByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByDescDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByInstalled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installed', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByInstalledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installed', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByScript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'script', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByScriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'script', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension PackageQuerySortThenBy on QueryBuilder<Package, Package, QSortThenBy> {
  QueryBuilder<Package, Package, QAfterSortBy> thenByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByDescDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByInstalled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installed', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByInstalledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installed', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByScript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'script', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByScriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'script', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Package, Package, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension PackageQueryWhereDistinct on QueryBuilder<Package, Package, QDistinct> {
  QueryBuilder<Package, Package, QDistinct> distinctByArch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'arch');
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByDefaults() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaults');
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'desc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByInstalled({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByMethods() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'methods');
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByScript({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'script', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Package, Package, QDistinct> distinctByVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension PackageQueryProperty on QueryBuilder<Package, Package, QQueryProperty> {
  QueryBuilder<Package, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Package, List<String>?, QQueryOperations> archProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'arch');
    });
  }

  QueryBuilder<Package, List<String>?, QQueryOperations> defaultsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaults');
    });
  }

  QueryBuilder<Package, String?, QQueryOperations> descProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'desc');
    });
  }

  QueryBuilder<Package, String?, QQueryOperations> installedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installed');
    });
  }

  QueryBuilder<Package, List<String>?, QQueryOperations> methodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'methods');
    });
  }

  QueryBuilder<Package, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Package, String, QQueryOperations> scriptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'script');
    });
  }

  QueryBuilder<Package, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Package, String?, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<Package, String?, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
