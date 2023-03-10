import 'dart:io';
import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import 'api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

TextEditingController name = TextEditingController(),
    number = TextEditingController(),
    pin = TextEditingController();
var qr = "";
int d = Random().nextInt(255);
var key = "";

class _HomeState extends State<Home> {
  setkeyGoogleAuth(ds) async {
    bool isInstalled = await DeviceApps.isAppInstalled('com.google.android.apps.authenticator2');

    if (Platform.isAndroid) {
      // AndroidIntent intent = const AndroidIntent(
      //   action: 'action_view',
      //   data: 'https://play.google.com/store/apps/details?'
      //       'id=com.google.android.apps.myapp',
      // );

      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: '${ds}',
      );
      await intent.launch();
    }
    // if (isInstalled != false) {
    //   AndroidIntent intent = AndroidIntent(action: 'action_view', data: data);
    //   await intent.launch();
    // } else {}
  }

  var mlt = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        "Key For 2FA",
                        style: TextStyle(fontSize: 38),
                      ),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(label: Text('Name')),
                      ),
                      TextFormField(
                        controller: number,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                        decoration: InputDecoration(label: Text('Mobile Number')),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            qr = await generateQR(
                                appName: 'Test Authentication',
                                appInfo: '${name.text}${d}',
                                secretCode: '${d}_${name.text}_${number.text}');
                            RegExp regExp = new RegExp(
                              r"(?<=chl=)(.*)(?=' border=0></a>)",
                              caseSensitive: false,
                              multiLine: false,
                            );
                            print(qr);

                            var de = Uri.decodeFull(qr);

                            key = regExp.stringMatch(de).toString();
                            print(key);
                            print(de);

                            setState(() {});
                          },
                          child: Text("Generate")),
                      qr != ""
                          ? ElevatedButton(
                              onPressed: () async {
                                await setkeyGoogleAuth(key);
                              },
                              child: Text("Copy Code - $key"))
                          : Container(),
                      qr != ""
                          ? Html(
                              data: """${qr}""",
                              onImageTap: (url, context, attributes, element) async {
                                await setkeyGoogleAuth(key);
                              },
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
              Card(
                color: mlt == null
                    ? Colors.white
                    : mlt
                        ? Colors.green
                        : Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        "Verify PIN",
                        style: TextStyle(fontSize: 38),
                      ),
                      TextFormField(
                        controller: pin,
                        decoration: InputDecoration(label: Text('Pin')),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            mlt = await validateApp(pin.text);

                            setState(() {});
                          },
                          child: Text("Verify")),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
