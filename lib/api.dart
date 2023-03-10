import 'package:http/http.dart' as http;

var secret = "";
generateQR({appName, appInfo, secretCode}) async {
  secret = secretCode;
  var request = http.Request(
      'GET',
      Uri.parse('https://www.authenticatorApi.com/pair'
          '.aspx?AppName=${Uri.encodeComponent(appName)}&AppInfo=${Uri.encodeComponent(appInfo)}&SecretCode=${secretCode}'));

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    return await response.stream.bytesToString();
  } else {
    print(response.reasonPhrase);
  }
}

validateApp(pin) async {
  var request = http.Request(
      'GET',
      Uri.parse('https://www.authenticatorApi.com/Validate'
          '.aspx?Pin=${pin}&SecretCode=${secret}'));

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    return await response.stream.bytesToString() == "False" ? false : true;
  } else {
    print(response.reasonPhrase);
  }
}
