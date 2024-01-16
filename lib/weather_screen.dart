import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  String toHour(String value) {
    DateTime date = DateTime.parse(value);
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  String kelvinToCelsius(double kelvin) {
    if (kelvin < 0) {
      throw ArgumentError("La température ne peut pas être inférieure à 0.");
    }

    return "${(kelvin - 273.15).ceil()}°";
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    // String cityName = 'Lome';
    try {
      final res = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=Lome,tg&APPID=e06149bf54af785efb82791676f5ccf2",
        ),
      );
      final Map<String, dynamic> data = jsonDecode(res.body);

      if (data['cod'] != "200") {
        throw "Une erreur s'est produite";
      }

      // debugPrint(data['list'][0]['main']['temp'].toString());

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Refresh");
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            // print(snapshot.data);
            // print(snapshot.runtimeType);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            final currentWeatherData = data['list'][0];

            final currentTemp =
                kelvinToCelsius(currentWeatherData['main']['temp']);

            final currentSky = currentWeatherData['weather'][0]['main'];

            final currentPressure = currentWeatherData['main']['pressure'];

            final currentHumidity = currentWeatherData['main']['humidity'];

            final currentWind = currentWeatherData['wind']['speed'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Card
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                // "300 K",
                                "$currentTemp °C",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                currentSky == "Clouds" || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              Text(
                                currentSky.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // hours weather card
                  const Text(
                    "Weather Forecast",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 125,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: ((context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky = hourlyForecast['weather'][0]['main'];
                        final hourlyTemp =
                            kelvinToCelsius(hourlyForecast['main']['temp']);
                        return HourlyWheatherItem(
                          hour: toHour(data['list'][index + 1]['dt_txt']),
                          icon: hourlySky == "Clouds" || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          temperature: hourlyTemp.toString(),
                        );
                      }),
                    ),
                  ),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       for (var i = 0; i < 5; i++)
                  //         HourlyWheatherItem(
                  //           hour: toHour(data['list'][i + 1]['dt_txt']),
                  //           icon: data['list'][i + 1]['weather'][0]['main'] == "Clouds" || data['list'][i + 1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                  //           temperature: "301.54",
                  //         )
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 25),
                  //additional informations
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalItem(
                        icon: Icons.water_drop,
                        label: "Humidity",
                        value: currentHumidity.toString(),
                      ),
                      AdditionalItem(
                        icon: Icons.air,
                        label: "Wind Speed",
                        value: currentWind.toString(),
                      ),
                      AdditionalItem(
                        icon: Icons.beach_access,
                        label: "Pressure",
                        value: currentPressure.toString(),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}

class AdditionalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            icon,
            size: 32,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HourlyWheatherItem extends StatelessWidget {
  final String hour;
  final IconData icon;
  final String temperature;
  const HourlyWheatherItem({
    super.key,
    required this.hour,
    required this.icon,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 120,
      child: Card(
        elevation: 6,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                hour,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                icon,
                size: 32,
              ),
              Text(
                temperature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
