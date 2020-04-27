import 'dart:convert';
import 'dart:io';

import 'state.dart';

class Response {

  bool _sent;
  State _locals;
  HttpResponse _httpResponse;

  bool get sent => this._sent;
  State get locals => this._locals;
  HttpHeaders get headers => this._httpResponse.headers;

  void set statusCode(int value) => this._httpResponse.statusCode = value;

  Response(HttpResponse httpResponse) {
    this._sent = false;
    this._locals = State();
    this._httpResponse = httpResponse;
  }

  void sendJson(Object jsonValue) {
    this.send(json.encode(jsonValue), ContentType.json);
  }

  sendText(String text) async {
    this.send(text, ContentType.text);
  }

  void sendHtml(File htmlFile) async {
    this.headers.contentType = ContentType.html;
    this._httpResponse.addStream(htmlFile.openRead())
                        .then((_) => this._httpResponse.flush())
                        .then((_) => this._httpResponse.close());
    this._sent = true;
  }

  void send(Object content, [ContentType contentType]) {
    if (contentType != null) {
      this._httpResponse.headers.contentType = contentType;
    }
    this._httpResponse.write(content);
    this._httpResponse.close();
    this._sent = true;
  }
  
}
