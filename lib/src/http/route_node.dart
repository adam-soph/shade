import 'package:shade/src/utilities/pair.dart';
import 'route_step.dart';

/// The result of a [RouteNode]'s [climb] function.
///
/// If match is `false` then [routeNode], [pathParameters], and [path] will be `null`.
class ClimbResult {
  final bool match;
  final RouteNode routeNode;
  final String path;
  final Map<String, String> pathParameters;

  const ClimbResult(this.match, this.routeNode, this.path, this.pathParameters);
}

/// A node in a [Router]'s tree.
class RouteNode {
  Map<String, Iterable<RouteStep>> endpoints;
  Iterable<RouteStep> catchAllEndpoint;
  Map<String, RouteNode> literalChildren;
  Pair<String, RouteNode> variableChild;
  RouteNode catchAllChild;

  RouteNode() {
    this.endpoints = {};
    this.literalChildren = {};
  }

  ClimbResult climb(Iterator<String> segments,
      Map<String, String> pathParameters, StringBuffer path) {
    if (!segments.moveNext()) {
      return ClimbResult(true, this, path.toString(), pathParameters);
    }

    var currentSegment = segments.current;

    for (var literal in this.literalChildren.keys) {
      if (literal == currentSegment) {
        path.write("/" + literal);
        return this
            .literalChildren[literal]
            .climb(segments, pathParameters, path);
      }
    }

    if (this.variableChild != null) {
      path.write("/:" + this.variableChild.left);
      pathParameters[this.variableChild.left] = currentSegment;
      return this.variableChild.right.climb(segments, pathParameters, path);
    }

    if (this.catchAllChild != null) {
      path.write("/*");
      return ClimbResult(
          true, this.catchAllChild, path.toString(), pathParameters);
    }

    return ClimbResult(false, null, null, null);
  }
}
