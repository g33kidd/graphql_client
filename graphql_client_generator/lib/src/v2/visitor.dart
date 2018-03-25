// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

library graphql_client_generator.visitor;

import 'package:graphql_parser/graphql_parser.dart';
import 'package:graphql_parser/visitor.dart';
import 'package:code_builder/code_builder.dart';

import 'settings.dart';

part 'field.dart';
part 'fragment.dart';
part 'operation.dart';
part 'node.dart';

/// Parses the GraphQL DocumentContext and goes through to build some code.
// class GQLVisitor extends GraphQLVisitor {
//   final GeneratorSettings _settings;

//   final Map<String, Spec> operations;
//   final Map<String, Spec> fragments;
//   final Map<String, Spec> fields;

//   /// The generated code.
//   final List<Spec> code;

//   /// Constructor.
//   GQLVisitor(this._settings) :
//     operations = {},
//     fragments = {},
//     fields = {},
//     code = [];

//   /// Returns the generated code.
//   List<Spec> execute(String gql) {
//     final document = new Parser(scan(gql)).parseDocument();
//     visitDocument(document);
//     return code;
//   }

//   @override
//   void visitOperationDefinition(OperationDefinitionContext ctx) {
//     final operation = new Operation(ctx);

//     final newClass = new Class((b) => b
//       ..name = operation.className
//       ..extend = const Reference('Object')
//       ..implements.add(const Reference('GQLOperation'))
//       ..mixins.addAll(operation.mixin)
//       ..methods.addAll([
//         new Method((b) => b
//           ..name = 'gqlType'
//           ..returns = const Reference('String')
//           ..lambda = true
//           ..body = new Code('${operation.type}')
//           ..annotations.add(const CodeExpression(const Code('override')))
//         ),
//       ])
//     );

//     code.add(newClass);
//   }

//   @override
//   void visitField(FieldContext ctx) {
//     String realName, alias;

//     if (ctx.fieldName.alias == null) {
//       realName = alias = ctx.fieldName.name;
//     } else {
//       realName = ctx.fieldName.alias.name;
//       alias = ctx.fieldName.alias.alias;
//     }

//     print(realName);
//     print(alias);
//   }
// }

class FragmentSpreadResolution {
  final String name;
  final Node parent;

  FragmentSpreadResolution(this.name, this.parent);
}

class GQLVisitor {
  final GeneratorSettings _settings;

  final Map<String, Operation> operations;
  final Map<String, Fragment> fragments;

  final List<FragmentSpreadResolution> _spreadResolutions;

  GQLVisitor(this._settings)
      : operations = {},
        fragments = {},
        _spreadResolutions = [];

  /// Parses the GraphQL string and produces a [DocumentContext].
  List<Spec> execute(String gql) {
    final parser = new Parser(scan(gql));
    final document = parser.parseDocument();

    print(document.definitions.toString());
    _visitDocument(document);

    return [];
  }

  void _resolveFragmentSpreads() {
    _spreadResolutions.forEach(_resolveFragmentSpread);
  }

  void _resolveFragmentSpread(FragmentSpreadResolution f) {
    final fragment = fragments[f.name];
    f.parent.fragments.add(fragment);
  }

  void _visitDocument(DocumentContext ctx) {
    ctx.definitions
        .where((ctx) => ctx is FragmentDefinitionContext)
        .forEach(_visitFragmentDefinition);
    ctx.definitions
        .where((ctx) => ctx is OperationDefinitionContext)
        .forEach(_visitOperationDefinition);

    _resolveFragmentSpreads();
  }

  void _visitOperationDefinition(OperationDefinitionContext ctx) {
    final operation = new Operation(ctx);

    print(operation.className);
    operations[operation.name] = operation;

    _visitSelectionSet(ctx.selectionSet, operation);
  }

  void _visitFragmentDefinition(FragmentDefinitionContext ctx) {
    final fragment = new Fragment(ctx);

    print(fragment.name);
    fragments[fragment.name] = fragment;

    _visitSelectionSet(ctx.selectionSet, fragment);
  }

  void _visitSelectionSet(SelectionSetContext ctx, Node parent) {
    if (ctx != null && ctx.selections.isNotEmpty) {
      for (var selection in ctx.selections) {
        _visitSelection(selection, parent);
      }
    }
  }

  void _visitSelection(SelectionContext ctx, Node parent) {
    if (ctx.field != null) {
      _visitField(ctx.field, parent);
    }

    if (ctx.fragmentSpread != null) {
      _visitFragmentSpread(ctx.fragmentSpread, parent);
    }
  }

  void _visitField(FieldContext ctx, Node parent) {
    final field = new GQLField(ctx, _settings)..parent = parent;

    print(field.resolverName);
    parent.children.add(field);

    _visitSelectionSet(ctx.selectionSet, field);
  }

  void _visitFragmentSpread(FragmentSpreadContext ctx, Node parent) {
    print(ctx.name);
    _spreadResolutions.add(new FragmentSpreadResolution(ctx.name, parent));
  }
}
