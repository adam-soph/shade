import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'exceptions.dart';
import 'router.dart';
import 'route_Step.dart';

/// This object repersents the scope and life cycle of a request to your applciation.
/// 
/// A new [RequestContext] is created for every request.
class RequestContext {

  final Request _request;
  final Response _response;
  final Iterator<RouteStep> _chain;
  final ErrorRouteStep _errorFunction;

  const RequestContext._(this._request, Response this._response, Iterator<RouteStep> this._chain, ErrorRouteStep this._errorFunction);

  /// This will start a new [RequestContext].
  static void start(HttpRequest httpRequest, RouteResult routeResult, ErrorRouteStep errorFunction) {
    
    var res = Response._(httpRequest.response);
    var req = Request._(httpRequest, routeResult.path, routeResult.pathParameters);
    
    if (!routeResult.matchEndpoint || !routeResult.matchPath) {
      errorFunction(req, res, RouteNotFoundException(httpRequest.requestedUri.path, httpRequest.method));
    } else {
      RequestContext._(req, res, routeResult.chain, errorFunction).._step();
    }
  }

  void _step([dynamic error]) {

    if (error != null) {
      this._errorFunction(this._request, this._response, error);
    }

    if (this._chain.moveNext()) {
      var routeFunction = this._chain.current;
      try {
        routeFunction(this._request, this._response, this._step);
      } catch (error) {
        this._errorFunction(this._request, this._response, error);
      }
    }
  }

}


/// An [Application] HTTP Request.
/// 
/// This is a high-level [HttpRequest] wrapper. If you need to access this object directly use [raw].
class Request {

  HttpRequest _raw;
  String _path;
  Map<String, String> _pathParameters;

  Stream<Uint8List> get data => _raw;

  /// The path the endpoint.
  /// 
  /// Examples: 
  /// `/request/:path`
  /// `/all/*`
  String get path => _path;

  /// The HTTP method of the request.
  /// 
  /// This will always be uppercase.
  String get method => this._raw.method.toUpperCase();

  /// The raw [HttpRequest].
  HttpRequest get raw => this._raw;

  /// A [Map] of the path parameters.
  Map<String, String> get pathParameters => this._pathParameters;

  /// A [Map] of the query string parameters.
  Map<String, String> get queryParameters => this._raw.requestedUri.queryParameters;

  Request._(HttpRequest httpRequest, String path, Map<String, String> pathParameters):
    _path = path,
    _raw = httpRequest,
    _pathParameters = pathParameters;

}

/// An HTTP Response.
/// 
/// An instance of this class is passed through all the [RouteStep]s.
/// 
/// This class is a wrapper that adds additional functionality around a the [HttpResponse] class,
/// to access it use [raw].
class Response {

  bool _sent;
  State _state;
  HttpResponse _raw;

  /// A boolean indicating if a response has been sent in the current [RequestContext].
  /// 
  /// This will reflect if the response has been sent reguardless if it is send using
  /// the raw [HttpResponse] or not.
  bool get sent => this._sent;

  /// The state of of the current [RequestContext].
  State get state => this._state;

  /// The raw [HttpResponse].
  HttpResponse get raw => this._raw;

  /// The [HttpHeaders] of the current [RequestContext].
  HttpHeaders get headers => this._raw.headers;

  /// Sets the statusCode to be sent when [send] is called.
  /// 
  /// This will also be sent for [sendJson], [sendHtml], and [sendText].
  void set statusCode(int value) => this._raw.statusCode = value;

  Response._(HttpResponse httpResponse) {
    this._sent = false;
    this._state = State();
    this._raw = httpResponse;
    this._raw.done.then((_) => this._sent = true);
  }

  
  Future sendJson(Object jsonValue) {
    return this.send(json.encode(jsonValue), ContentType.json);
  }

  Future sendText(String text) {
    return this.send(text, ContentType.text);
  }

  Future sendHtml(File htmlFile) {
    this.headers.contentType = ContentType.html;
    return this._raw.addStream(htmlFile.openRead())
                        .then((_) => this._raw.flush())
                        .then((_) => this._raw.close());
  }

  Future send(Object content, [ContentType contentType]) {
    if (contentType != null) {
      this._raw.headers.contentType = contentType;
    }
    this._raw.write(content);
    return this._raw.close();
  }
  
}

/// This is the current state of the [RequestContext].
/// 
/// This class mainly serves a place to store data between [RouteStep]s.
class State {

  Map<String, dynamic> _state_map;

  State() {
    this._state_map = {};
  }

  void forEach(void action(String key, local)) {
    this._state_map.forEach(action);
  }

  T getLocal<T>(String key) {
    if (this._state_map[key] is T) {
      return this._state_map[key];
    }
    return null;
  }

  operator [](String key) => this._state_map[key];

  void operator []=(String key, value) => this._state_map[key] = value;
  
}


