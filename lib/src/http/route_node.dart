import 'package:shade/src/utilities/pair.dart';
import 'route_step.dart';

class ClimbResult {

  final bool match;
  final RouteNode routeNode;
  final Map<String, String> pathParameters;

  const ClimbResult(this.match, this.routeNode, this.pathParameters);

}

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


  ClimbResult climb(Iterator<String> segments, Map<String, String> pathParameters) {
    
    if (!segments.moveNext()) {
      return ClimbResult(true, this, pathParameters);
    }

    var currentSegment = segments.current;

    for (var literal in this.literalChildren.keys) {
      if (literal == currentSegment) {
        return this.literalChildren[literal].climb(segments, pathParameters);
      }
    }

    if (this.variableChild != null) {
      pathParameters[this.variableChild.left] = currentSegment;
      return this.variableChild.right.climb(segments, pathParameters);
    }

    if (this.catchAllChild != null) {
      return ClimbResult(true, this.catchAllChild, pathParameters);
    }

    return ClimbResult(false, null, null);
  }

}