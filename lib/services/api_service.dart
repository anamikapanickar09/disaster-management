import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster/services/firebase_notofications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Map<String, String> reverseMap = {};
FirebaseFirestore _firestore = FirebaseFirestore.instance;
http.Client http_client = http.Client();

Future<String> getPlaceFromCoordinates(num lat, num long) async {
  final String key = '$long,$lat';
  if (reverseMap.containsKey(key)) {
    return reverseMap['$long,$lat']!;
  }

  try {
    var place = (await _firestore.collection('coordinate_place_collection').doc(key).get())["place"];
    print(place);
    return place;
  } catch (e) {
    var url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$long&format=json');
    // var url = Uri.parse('https://us1.locationiq.com/v1/reverse?key=pk.b380150eb46bec94722c1c92c7dc69ca&lat=$lat&lon=$long&format=json');
    var response = await http_client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
    // return json.decode(response.body).toString();
    var data = json.decode(response.body);
    // print('Data: $data');
    List<String> address = data['display_name'].toString().split(", ");
    String addressString = address.sublist(0, address.length - 2).join(', ');
    reverseMap['$long,$lat'] = addressString;
    _firestore.collection('coordinate_place_collection').doc(key).set({"place": addressString});
    return addressString;
  }
}

Future<String> classifyText(String text) async {
  final Uri url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent");
  const String apiKey = "AIzaSyB2WCbw8GDnPTDrOx8GI3TZhV6Rr-3X89o";
  const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  var body = jsonEncode({
    "contents": [
      {
        "parts": [
          {
            "text": "You are given a string sent by a person who is affected by a crisis. "
                "There are 2 types of people. Doctors and Volunteers. "
                "The job given to you is to figure out to whom to send the text. "
                "REPLY IN A SINGLE WORD. \"DOCTOR\" or \"VOLUNTEER\". "
                "And if the string does not relate to anything in the context, you should say \"ERROR\". "
                "No additional info needed. Not even a period or linebreak after the word. Here is the text: '$text'"
          }
        ]
      }
    ]
  });

  // Send the POST request
  var response = await http.post(
    url.replace(
        queryParameters: {'key': apiKey}), // Add the API key as query parameter
    headers: headers,
    body: body,
  );

  // Check the response status
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var returnText = jsonResponse["candidates"][0]["content"]["parts"][0]
            ["text"]
        .toString()
        .replaceAll("\n", '');
    return returnText;
  }
  throw Exception('Failed to load data. Status code: ${response.statusCode}');
}

void sendAlert(
    {required String name,
    required String userType,
    required String comment,
    required Position position}) async {
  String receiver = await classifyText(comment);

  await FirebaseFirestore.instance.collection('alerts').add({
    'name': name,
    'userType': userType,
    'comment': comment,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': FieldValue.serverTimestamp(),
    'closed': false,
    'committed': false,
  });

  FCMService().sendNotification(
      topic: receiver.trim().toLowerCase(),
      title: "Alert!",
      body: comment,
      accessToken: await FirebaseAuthTokenManager.getAccessToken());
}

void main() async {
  print(await classifyText("i need water please"));
}
