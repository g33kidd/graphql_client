// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of graphql_client_generator.generator;

class GQLFieldGenerator extends GQLField implements Generable {
  GQLFieldGenerator(FieldContext ctx, GeneratorSettings settings)
      : super(ctx, settings);

  String get resolverName =>
      '${name[0].toUpperCase()}${name.substring(1)}$resolverSuffix';

  List<Reference> get mixin => [
        isEmpty ? const Reference('Scalar') : const Reference('Fields'),
        isList ? new Reference('Collection<$resolverName>') : null,
        alias != null ? const Reference('Alias') : null,
        arguments.isNotEmpty ? const Reference('Arguments') : null,
        directives.isNotEmpty ? const Reference('Directives') : null,
        fragments.isNotEmpty ? const Reference('Fragments') : null,
      ].where((r) => r != null).toList();

  List<Method> get methods {
    final resolverFields = children;

    // I don't know where f.name should be coming from or where it
    // could possibly have been generated. Replaced with static string for now
    // - g33k
    final resolverFieldsNames = resolverFields.map((f) => 'test');
    final resolverFieldsDeclarations = resolverFieldsNames.join(', ');
    final cloneMethodFields = 'new $resolverName()${
        alias != null ?
        '..gqlAliasId = gqlAliasId' :
        ''
    }${
        resolverFieldsNames.isNotEmpty ?
        '..${resolverFieldsNames.map((n) => '$n = $n.gqlClone()').join('..')}' :
        ''
    }';
    final fragmentFieldsNames = [];
        // fragmentSpreads.map((f) => '_${f.assignmentName}');
    final fragmentFieldsDeclarations = fragmentFieldsNames.join(', ');

    return [
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
            ..body = new Code("r'$arguments")
            ..annotations.add(const CodeExpression(const Code('override'))))
          : null,
      directives.isNotEmpty
          ? new Method((b) => b
            ..name = 'gqlDirectives'
            ..type = MethodType.getter
            ..lambda = true
            ..returns = const Reference('String')
            ..body = new Code("'$directives'")
            ..annotations.add(const CodeExpression(const Code('override'))))
          : null,
      isNotEmpty
          ? new Method((b) => b
            ..name = 'gqlFields'
            ..type = MethodType.getter
            ..lambda = true
            ..returns = const Reference('List<GQLField>')
            ..body = new Code('[$resolverFieldsDeclarations]')
            ..annotations.add(const CodeExpression(const Code('override'))))
          : null,
    //   fragmentSpreads.isNotEmpty
    //       ? new Method((b) => b
    //         ..name = 'gqlFragments'
    //         ..type = MethodType.getter
    //         ..lambda = true
    //         ..body = new Code('[$fragmentFieldsDeclarations]')
    //         ..returns = const Reference('List<GQLFragment>')
    //         ..annotations.add(const CodeExpression(const Code('override'))))
    //       : null,
      new Method((b) => b
        ..name = 'gqlClone'
        ..returns = new Reference(resolverName)
        ..lambda = true
        ..body = new Code(cloneMethodFields)
        ..annotations.add(const CodeExpression(const Code('override')))),
    ].where((m) => m != null).toList();
  }

  @override
  List<Spec> generate() => [
        new Class(
          (b) => b
            ..name = resolverName
            ..extend = const Reference('Object')
            ..mixins.addAll(mixin),
        )
      ];
}
