import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getPlaceFromCoordinates(num lat, num long) async {
  var url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$long&format=json');
  var response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load data. Status code: ${response.statusCode}');
  }
  var data = json.decode(response.body);
  // print('Data: $data');
  List<String> address = data['display_name'].toString().split(", ");
  return address.sublist(0, address.length-2).join(', ');
}