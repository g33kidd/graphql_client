// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of graphql_client_generator.parser;

/// Generates code for GraphQL Operation.
class GQLOperationGenerator extends Object
    with SelectionSet
    implements Generable {
  final OperationDefinitionContext _operationContext;
  final Map<String, GQLFragmentGenerator> _fragmentsMap;
  final GQLSettings _settings;

  /// Constructor.
  GQLOperationGenerator(
      this._operationContext, this._fragmentsMap, this._settings);

  @override
  SelectionSetContext get selectionSetContext => _operationContext.selectionSet;

  @override
  GQLSettings get settings => _settings;

  @override
  Map<String, GQLFragmentGenerator> get fragmentsMap => _fragmentsMap;

  /// Name of the operation.
  String get name => _operationContext.name;

  /// Gets the type of the operation.
  String get type {
    if (_operationContext.isQuery) {
      return 'query';
    }
    if (_operationContext.isMutation) {
      return 'mutation';
    }
    throw new StateError('Unknow Opration Type');
  }

  /// Gets the operation arguments.
  String get arguments => _operationContext.variableDefinitions != null
      ? _operationContext.variableDefinitions.toSource()
      : '';

  /// Gets the operation.
  String get operationName =>
      '${name[0].toUpperCase()}${name.substring(1)}${type[0].toUpperCase()}${type.substring(1)}';

  /// Gets the type of the operation.
  String get operationType {
    if (_operationContext.isQuery) {
      return 'queryType';
    }
    if (_operationContext.isMutation) {
      return 'mutationType';
    }
    throw new StateError('Unknow Opration Type');
  }

  List<Reference> get mixin => [
    isNotEmpty ? const Reference('Fields') : null,
    arguments.isNotEmpty ? const Reference('Arguments') : null,
  ].where((r) => r != null).toList();

  List<Method> get methods {
    final operationFieldsNames = fields.map((f) => f.name);
    final operationFieldsDeclarations = operationFieldsNames.join(', ');
    final cloneMethodFields = 'new $operationName()${
        operationFieldsNames.isNotEmpty ?
        '..${operationFieldsNames.map((n) => '$n = $n.gqlClone()').join('..')}' :
        ''
    }';

    return [
      new Method((b) => b
        ..name = 'gqlType'
        ..type = MethodType.getter
        ..lambda = true
        ..returns = const Reference('String')
        ..body = new Code('$operationType')
        ..annotations.add(const CodeExpression(const Code('override')))),
      new Method((b) => b
        ..name = 'gqlName'
        ..type = MethodType.getter
        ..lambda = true
        ..returns = const Reference('String')
        ..body = new Code("'$name'")
        ..annotations.add(const CodeExpression(const Code('override')))),
      arguments.isNotEmpty
          ? new Method((b) => b
            ..name = 'gqlArguments'
            ..type = MethodType.getter
            ..lambda = true
            ..returns = const Reference('String')
            ..body = new Code("r'$arguments'")
            ..annotations.add(const CodeExpression(const Code('override'))))
          : null,
      isNotEmpty
          ? new Method((b) => b
            ..name = 'gqlFields'
            ..type = MethodType.getter
            ..lambda = true
            ..returns = const Reference('List<GQLField>')
            ..body = new Code('[$operationFieldsDeclarations]')
            ..annotations.add(const CodeExpression(const Code('override'))))
          : null,
      new Method((b) => b
        ..name = 'gqlClone'
        ..returns = new Reference(operationName)
        ..lambda = true
        ..body = new Code(cloneMethodFields)
        ..annotations.add(const CodeExpression(const Code('override')))),
    ].where((m) => m != null).toList();
  }

  @override
  List<Spec> generate() => [
    new Class((b) => b
      ..name = operationName
      ..extend = const Reference('Object')
      ..mixins.addAll(mixin)
      ..implements.add(const Reference('GQLOperation'))
      ..methods.addAll(methods)
      ..fields.addAll(fields))
  ]..addAll(parseSelections(fieldsGenerators, []));
}
