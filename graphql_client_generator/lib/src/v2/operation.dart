// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of graphql_client_generator.visitor;

enum OperationType { query, mutation }

String renderOperationType(OperationType type) {
  switch (type) {
    case OperationType.query:
      return 'query';
      break;
    case OperationType.mutation:
      return 'mutation';
      break;
  }
}

class Operation implements Node {
  final OperationDefinitionContext _ctx;

  @override
  Node parent;

  @override
  List<Node> children;

  @override
  List<Fragment> fragments;

  List<Reference> get mixin => [
    isNotEmpty ? const Reference('Fields') : null,
    arguments.isNotEmpty ? const Reference('Arguments') : null,
  ].where((r) => r != null).toList();

  Operation(this._ctx)
      : parent = null,
        children = [],
        fragments = [];

  String get name => _ctx.name;

  OperationType get type {
    if (_ctx.isQuery) {
      return OperationType.query;
    }
    if (_ctx.isMutation) {
      return OperationType.mutation;
    }
    throw new StateError('Unknow Opration Type');
  }

  String get classType => '${typeToString[0].toUpperCase()}${typeToString.substring(1)}';
  String get className => '${name[0].toUpperCase()}${name.substring(1)}$classType';

  String get typeToString => renderOperationType(type);

  String get arguments => _ctx.variableDefinitions != null
      ? _ctx.variableDefinitions.toSource()
      : '';

  String get directives => _ctx.directives.map((d) => d.toSource()).join(', ');

  bool get isNotEmpty => _ctx.selectionSet != null && _ctx.selectionSet.selections.isNotEmpty;
}
