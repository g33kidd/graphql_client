// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

library graphql_client_generator.builder;

import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'parser.dart';
import 'renderer.dart';
import 'settings.dart';

/// Builder for generating code.
class GQLBuilder implements Builder {

  /// Constructor.
  const GQLBuilder(GQLSettings settings);

  // /// Generates code.
  // GQLBuilder(GQLSettings settings)
  //     : _renderer = new Renderer(new DartEmitter(), new DartFormatter()),
  //       _parser = new GQLParser(settings);

  /// GQL Factory builder.
  factory GQLBuilder.fromOptions(BuilderOptions options) {
    if (options.config['throw_in_constructor'] == true) {
      throw new StateError('Throwing on purpose cause you asked for it!');
    }

    return new GQLBuilder(
      new GQLSettings()
    );
  }

  @override
  Future<Null> build(BuildStep buildStep) async {
    final _parser = new GQLParser(new GQLSettings());
    final _renderer = new Renderer(new DartEmitter(), new DartFormatter());

    final outputId = buildStep.inputId.changeExtension('.graphql.dart');
    final gql = await buildStep.readAsString(buildStep.inputId);

    final gqlDefinitions = _parser.parse(gql);

    final code = _renderer.buildLibrary(
        outputId: outputId, gqlDefinitions: gqlDefinitions);

    await buildStep.writeAsString(
      outputId, 
      code
    );
  }

  @override
  final Map<String, List<String>> buildExtensions = const {
    '.graphql': const ['.graphql.dart']
  };

  @override
  String toString() => 'GQLBuilder';
}

/// GQLBuilder for build_runner
Builder graphqlBuilder(BuilderOptions options) =>
  new GQLBuilder.fromOptions(options);