// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

library graphql_client_generator.generator;

import 'package:code_builder/code_builder.dart';
import 'package:graphql_parser/graphql_parser.dart';

import 'visitor.dart';
import 'settings.dart';

part 'constants.dart';
part 'generable.dart';
part 'field_generator.dart';

class GQLGenerator {
  final GQLVisitor _visitor;

  GQLGenerator(this._visitor);

  List<Spec> generate(String gql) {
    final parser = new Parser(scan(gql));
    final document = parser.parseDocument();
    return _visitor.execute(gql);

    // final code = <Spec>[];

    // _visitor.execute(gql);

    // print(_visitor.operations);
    // _visitor.operations.forEach((opName, operation) {
    //   print(operation.name);
    //   print(operation.typeToString);
    //   print(operation.children);

    //   final opFields = <Field>[];

    //   for (var child in operation.children) {
    //     if (child is GQLField) {
          
    //     }
    //   }

    //   final opMethods = <Method>[
    //     new Method((b) => b
    //       ..name = 'gqlType'
    //       ..type = MethodType.getter
    //       ..lambda = true
    //       ..returns = const Reference('String')
    //       ..body = new Code("'${operation.typeToString}'")
    //       ..annotations.add(const CodeExpression(const Code('override')))
    //     ),

    //     new Method((b) => b
    //       ..name = 'gqlName'
    //       ..type = MethodType.getter
    //       ..lambda = true
    //       ..returns = const Reference('String')
    //       ..body = new Code("'${operation.name}'")
    //       ..annotations.add(const CodeExpression(const Code('override')))
    //     ),

    //     new Method((b) => b
    //       ..name = 'gqlClone'
    //       ..lambda = true
    //       ..returns = new Reference(opName)
    //       ..body = new Code("'${operation.name}'")
    //       ..annotations.add(const CodeExpression(const Code('override')))
    //     ),
    //   ];
      
    //   final spec = new Class((b) => b
    //     ..name = '${operation.name[0].toUpperCase()}${operation.name.substring(1)}$resolverSuffix'
    //     ..methods.addAll(opMethods)
    //     ..extend = const Reference('Object')
    //     ..implements.add(const Reference('GQLOperation'))
    //   );

    //   code.add(spec);
    // });

    // return code;
  }
}
