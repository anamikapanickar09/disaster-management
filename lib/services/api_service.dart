import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, String> reverseMap = {};

Future<String> getPlaceFromCoordinates(num lat, num long) async {
  if(reverseMap.containsKey('$long,$lat')){
    return reverseMap['$long,$lat']!;
  }
  var url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$long&format=json');
  // var url = Uri.parse('https://us1.locationiq.com/v1/reverse?key=pk.b380150eb46bec94722c1c92c7dc69ca&lat=$lat&lon=$long&format=json');
  var response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load data. Status code: ${response.statusCode}');
  }
  // return json.decode(response.body).toString();
  var data = json.decode(response.body);
  // print('Data: $data');
  List<String> address = data['display_name'].toString().split(", ");
  String addressString = address.sublist(0, address.length-2).join(', ');
  reverseMap['$long,$lat'] = addressString;
  return addressString;
}