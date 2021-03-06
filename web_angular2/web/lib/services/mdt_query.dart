import 'package:angular2/core.dart';
import 'dart:async';
import "dart:html" show window;
import 'dart:convert';
import 'package:http/http.dart';
import '../model/errors.dart';
import 'src/mdt_conf_query.dart';
import 'src/mdt_users_query.dart';
import 'src/mdt_applications_query.dart';
import 'src/mdt_artifacts_query.dart';
import 'src/mdt_http_client.dart';

//num Platform { ANDROID, IOS, OTHER }

//final String mdtServerApiRootUrl = "http://localhost:8080/api";


/* var currentLocation = location.location.href;
    if (mdtServerApiRootUrl.matchAsPrefix("/api") != null){
      Uri currentUrl = Uri.parse(currentLocation);
      mdtServerApiRootUrl = "${currentUrl.scheme}://${currentUrl.host}:${currentUrl.port}${mdtServerApiRootUrl}";
    }*/


abstract class MDTQueryServiceAware {
  void loginExceptionOccured();
}

abstract class fakeClass {

}

@Injectable()
class MDTQueryService extends fakeClass with MDTQueryServiceUsers,MDTQueryServiceApplications,MDTQueryServiceArtifacts{
  Client _http;
 MDTQueryServiceAware mdtQueryServiceAware;
  /*
  void setHttpService(MDTQueryServiceAware mdtQueryServiceAware,Http http,LocationWrapper location) {
    this._http = http;
    this._mdtQueryServiceAware = mdtQueryServiceAware;
  }*/

  MDTQueryService(this._http) {
    print("MDTQueryService constructor, mode ${const String.fromEnvironment('mode')} base URL $mdtServerApiRootUrl");
  }

  void logout(){
    MDTHttpClient client =  this._http;
    client.reset();
  }

  Map allHeaders({String contentType}) {
    var requestContentType =
        contentType != null ? contentType : 'application/json; charset=utf-8';
    var initialHeaders = {
      "content-type": requestContentType,
      "accept": 'application/json' /*,"Access-Control-Allow-Headers":"*"*/
    };
  /*  if (lastAuthorizationHeader.length > 0) {
      initialHeaders['authorization'] = lastAuthorizationHeader;
    } else {
      initialHeaders.remove('authorization');
    }*/
    return initialHeaders;
  }

  Future checkAuthorizationHeader(Response response) async {
    if (response.statusCode == 401) {
      //return to home / login
      mdtQueryServiceAware?.loginExceptionOccured();
      /*if (_mdtQueryServiceAware != null){

        _mdtQueryServiceAware.loginExceptionOccured();
      }*/
    }
    return;
    /*if (response.status == 401) {
      lastAuthorizationHeader = '';
      throw new LoginError();
    }*/
/*
    var newHeader = response.headers('authorization');
    print("auth Header $newHeader");
    if (newHeader != null) {
      lastAuthorizationHeader = newHeader;
    }*/
  }

  Map parseResponse(Response response,{checkAuthorization:true}) {
    if (checkAuthorization) {
      checkAuthorizationHeader(response);
    }

    var responseData = response.body;
    if (responseData is Map) {
      return responseData;
    }
    return JSON.decode(responseData);
  }

  Future<Response> sendRequest(String method, String url,
      {String query, String body, String contentType}) async {
    //var url = '$baseUrlHost$path';
    var http = this._http;
    if (query != null) {
      url = '$url$query';
    }
    var headers = contentType == null
        ? allHeaders()
        : allHeaders(contentType: contentType);
    var httpBody = body;
    if (body == null) {
      httpBody = '';
    }
    try {
      switch (method) {
        case 'GET':
          return await http.get(url,
              headers: allHeaders(contentType: contentType));
        case 'POST':
          return await http.post(url, body:httpBody, headers: headers);
        case 'PUT':
          return await http.put(url, body:httpBody, headers: headers);
        case 'DELETE':
          return await http.delete(url, headers: headers);
      }
    } catch (e) {
      print("send request error $e");
      if (e.status == 0){
        throw new ConnectionError();
      }
      return e;
    }
    return null;
  }

 void sendRedirect(String url){
   // Fix for firefox
   window.location.assign(url);
   // Old Way
  /* AnchorElement anchorElt = new AnchorElement(href:url);//  document.createElement('a');
   document.body.children.add(anchorElt);
   //document.append(tl);

  // tl..attributes['href'] = url
   // ..attributes['download'] = filename
   anchorElt.click();
  */
 }

  //server logs
  Future<String> loadLogs(String logName,{int maxLines}) async{
    String url = "${mdtServerApiRootUrl}/logs/v1/tail/${logName}";
    if (maxLines != null ){
      url = "${url}?lines=$maxLines";
    }
    var response = await sendRequest('GET', url);
    var responseJson = parseResponse(response);

    if (responseJson["error"] != null) {
      throw new BaseError(responseJson["error"]["message"]);
    }

    return responseJson["data"];
  }

}
