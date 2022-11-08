import 'dart:collection';
import 'package:http/http.dart' as Http;

  main() async {
    String url = 'https://clist.by:443/api/v1/contest/?username=grayb1ade&api_key=d73257490d8ecc2b63194fcdb6f1147219f00528s';
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Accept', () => 'application/json');

    Http.Response response = await Http.get(
        url,
        headers: headers,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
