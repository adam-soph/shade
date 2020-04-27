
import 'dart:io';
import 'dart:typed_data';

class Request {

  HttpRequest _httpRequest;
  Map<String, String> _pathParameters;

  String get httpMethod => this._httpRequest.method;
  String get path => this._httpRequest.requestedUri.path;
  String get scheme => this._httpRequest.requestedUri.scheme;
  String get authority => this._httpRequest.requestedUri.authority;
  String get origin => this._httpRequest.requestedUri.origin;
  String get host => this._httpRequest.requestedUri.host;
  bool get hasAuthority => this._httpRequest.requestedUri.hasAuthority;

  int get contentLength => this._httpRequest.contentLength;
  HttpSession get session => this._httpRequest.session;
  HttpHeaders get headers => this._httpRequest.headers;
  List<Cookie> get cookies => this._httpRequest.cookies;
  Stream<Uint8List> get stream => this._httpRequest;
  bool get persistentConnection => this._httpRequest.persistentConnection;
  X509Certificate get certificate => this._httpRequest.certificate;
  HttpConnectionInfo get connectionInfo => this._httpRequest.connectionInfo;


  Request(HttpRequest httpRequest, Map<String, String> pathParameters):
    _httpRequest = httpRequest,
    _pathParameters = pathParameters;

  String getQueryParameter(String key) {
    return this._httpRequest.requestedUri.queryParameters[key];
  }

  String getPathParameter(String key) {
    return this._pathParameters[key];
  }

}
