import 'dart:core';

String mdtServerApiRootUrl = "/api" ;// const String.fromEnvironment('mode') == 'javascript' ? "/api" : "http://localhost:8080/api";
//String mdtServerApiRootUrl = "https://localhost:8080/api";
final String appVersion = "v1";
final String appPath = "/applications/${appVersion}";
final String artifactsPath = "/art/${appVersion}";
final String inPath = "/in/${appVersion}";
final String usersPath = "/users/${appVersion}";