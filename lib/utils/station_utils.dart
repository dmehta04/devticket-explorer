import 'dart:math';

String guessNearestStation(double lat, double lng) {
  final stations = <String, List<double>>{
    'berlin_hbf': [52.5251, 13.3694],
    'hamburg_hbf': [53.5526, 10.0067],
    'munich_hbf': [48.1402, 11.5581],
    'cologne_hbf': [50.9429, 6.9589],
    'frankfurt_hbf': [50.1070, 8.6632],
    'stuttgart_hbf': [48.7841, 9.1817],
    'hannover_hbf': [52.3767, 9.7413],
    'leipzig_hbf': [51.3455, 12.3821],
    'dresden_hbf': [51.0404, 13.7320],
    'nuremberg_hbf': [49.4457, 11.0831],
  };

  String nearest = 'frankfurt_hbf';
  double minDist = double.infinity;

  for (final entry in stations.entries) {
    final d = _distance(lat, lng, entry.value[0], entry.value[1]);
    if (d < minDist) {
      minDist = d;
      nearest = entry.key;
    }
  }
  return nearest;
}

double _distance(double lat1, double lng1, double lat2, double lng2) {
  final dx = lat1 - lat2;
  final dy = (lng1 - lng2) * cos(lat1 * pi / 180);
  return sqrt(dx * dx + dy * dy);
}
