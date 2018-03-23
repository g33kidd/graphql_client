// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

library graphql_client_generator.builder;

import 'package:path/path.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class Renderer {
  final DartEmitter _emitter;
  final DartFormatter _formatter;

  /// Renders the new code that has been generated?
  Renderer(this._emitter, this._formatter);

  /// Generates a header for the generated code.
  String renderHeader(AssetId outputId) {
    final package = outputId.package;
    final name = basename(outputId.path);
    final nameWithoutExtension =
        basenameWithoutExtension(outputId.path).split('.').first;
    var dartLibrary = dirname(outputId.path)
        .replaceAll('lib', '')
        .split('/')
        .where((s) => s.isNotEmpty)
        .join('.');
    dartLibrary = dartLibrary.isNotEmpty ? '.$dartLibrary.' : '.';

    return '''
    \/\/ GENERATED CODE - DO NOT MODIFY BY HAND
  
    \/\/ File $name
  
    \/\/ ignore_for_file: public_member_api_docs
    \/\/ ignore_for_file: slash_for_doc_comments
    
    library $package$dartLibrary$nameWithoutExtension;
    ''';
  }

  /// Builds the code?
  String buildLibrary({AssetId outputId, List<Spec> gqlDefinitions}) {
    final library = new Library((b) {
      b.directives.add(
        new Directive.import('package:graphql_client/graphql_dsl.dart'));
      b.body.addAll(gqlDefinitions);
    });

    return _formatter.format('''
    ${renderHeader(outputId)}
    
    ${library.accept(_emitter)}
    ''');
  }
}
