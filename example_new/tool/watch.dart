// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:build_runner/build_runner.dart';

import 'phases.dart';

Future<ServeHandler> main() async => await watch(phases);
