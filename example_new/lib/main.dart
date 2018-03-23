import 'package:graphql_client_generator/graphql_client_generator.dart';
import 'package:graphql_client_generator/src/parser.dart';
import 'package:graphql_client_generator/src/renderer.dart';
import 'package:graphql_client_generator/src/settings.dart';

void main() {

  final graphql = 'query Account {accounts {id}}';
  final parser = new GQLParser(
    new GQLSettings()
  );

  print(parser.parse(graphql));

}