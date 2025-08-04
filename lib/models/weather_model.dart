class WeatherData {
  final String city;
  final double temp;
  final String description;

  WeatherData({
    required this.city,
    required this.temp,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'],
      temp: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
    );
  }

  Map<String, dynamic> toMap() => {
    'city': city,
    'temp': temp,
    'description': description,
    'timestamp': DateTime.now().toString(),
  };
}
