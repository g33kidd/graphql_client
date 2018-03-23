// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:build_runner/build_runner.dart';
import 'package:build_config/build_config.dart';
import 'package:graphql_client_generator/graphql_client_generator.dart';

/// Build phases
final List<BuilderApplication> phases = [
  apply(
    'gql_builder|gql_builder', 
    [(_) => new GQLBuilder(
      new GQLSettings(collectionFields: const ['nodes', 'edges'])
    )],
    toRoot(),
    hideOutput: true,
    isOptional: false,
    defaultGenerateFor: const InputSet(
      include: const ['**/*.graphql']
    )
  )
];