import 'package:hive/hive.dart';

part 'request.g.dart'; // Hive generates this file

String requestBoxName = "requestBox";

enum HttpMethod { get, post, put, delete }

@HiveType(typeId: 999)
class Request {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final Map<String, dynamic>? data;

  @HiveField(2)
  final Map<String, dynamic>? queryParameters;

  @HiveField(3)
  final Map<String, String>? headers;

  @HiveField(4)
  final HttpMethod httpMethod;

  Request(
      {required this.url,
      this.data,
      this.queryParameters,
      this.headers,
      required this.httpMethod});

  get method => httpMethod;
}
