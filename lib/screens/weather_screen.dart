import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../services/firestore_service.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final FirestoreService _firestoreService = FirestoreService();
  WeatherData? _currentWeather;
  bool _isLoading = false;
  bool _showHistory = false;
  String? _errorMessage;

  Future<void> _fetchWeather() async {
    if (_cityController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a city name');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(_cityController.text);

      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });

      if (weather != null) {
        final userId = Provider.of<AuthService>(
          context,
          listen: false,
        ).currentUser?.uid;
        if (userId != null) {
          await _firestoreService.saveWeather(userId, weather).catchError((
            error,
          ) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch weather. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(
      context,
      listen: false,
    ).currentUser?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.lightBlue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.cloud : Icons.history),
            tooltip: _showHistory ? 'Show Weather' : 'Show History',
            onPressed: () => setState(() {
              _showHistory = !_showHistory;
              _errorMessage = null;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await Provider.of<AuthService>(
                  context,
                  listen: false,
                ).signOut();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to logout'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_showHistory) ...[
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
              if (_showHistory && userId != null)
                _buildHistoryList(userId)
              else if (_isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Fetching weather data...'),
                      ],
                    ),
                  ),
                )
              else if (_currentWeather != null)
                _buildWeatherCard()
              else
                _buildWelcomeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter city name',
                  hintText: 'e.g. London, New York',
                  border: InputBorder.none,
                  icon: const Icon(Icons.location_city, color: Colors.blue),
                ),
                onSubmitted: (_) => _fetchWeather(),
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              ),
              onPressed: _fetchWeather,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Card(
        key: ValueKey(_currentWeather?.city),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                _currentWeather!.city,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentWeather!.temp.round()}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currentWeather!.description
                    .split(' ')
                    .map((s) => s[0].toUpperCase() + s.substring(1))
                    .join(' '),
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Icon(
                _getWeatherIcon(_currentWeather!.description),
                size: 72,
                color: _getWeatherColor(_currentWeather!.description),
              ),
              const SizedBox(height: 8),
              Text(
                _getWeatherMessage(_currentWeather!.description),
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, size: 100, color: Colors.blue.shade300),
            const SizedBox(height: 24),
            Text(
              'Welcome to Weather App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a city to see the current weather',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() => _showHistory = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View History',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(String userId) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weather Search History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getWeatherHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No weather history found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Text(
                          'Search for cities to see them here!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final record = snapshot.data![index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getWeatherIcon(record['description'] ?? ''),
                          color: Colors.blue,
                        ),
                        title: Text(
                          record['city'] ?? 'Unknown City',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${record['temp']?.round() ?? 'N/A'}°C - ${(record['description'] ?? 'No description').toString().split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _firestoreService.deleteWeatherRecord(
                                userId,
                                record['docId'],
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Delete failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        onTap: () {
                          _cityController.text = record['city'] ?? '';
                          setState(() {
                            _showHistory = false;
                            _currentWeather = WeatherData(
                              city: record['city'],
                              temp: record['temp']?.toDouble() ?? 0.0,
                              description: record['description'],
                            );
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('sun') || desc.contains('clear')) {
      return Icons.wb_sunny;
    } else if (desc.contains('rain')) {
      return Icons.beach_access;
    } else if (desc.contains('cloud')) {
      return Icons.cloud;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return Icons.flash_on;
    } else if (desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('fog') || desc.contains('mist')) {
      return Icons.cloud_queue;
    }
    return Icons.wb_cloudy;
  }

  Color _getWeatherColor(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('sun') || desc.contains('clear')) {
      return Colors.amber;
    } else if (desc.contains('rain')) {
      return Colors.blue;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return Colors.deepPurple;
    } else if (desc.contains('snow')) {
      return Colors.lightBlue;
    }
    return Colors.grey;
  }

  String _getWeatherMessage(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('sun') || desc.contains('clear')) {
      return 'Perfect day to go outside!';
    } else if (desc.contains('rain')) {
      return 'Don\'t forget your umbrella!';
    } else if (desc.contains('cloud')) {
      return 'Partly cloudy skies today';
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return 'Stay indoors if possible!';
    } else if (desc.contains('snow')) {
      return 'Great time for winter activities!';
    } else if (desc.contains('fog') || desc.contains('mist')) {
      return 'Drive carefully in low visibility';
    }
    return 'Enjoy your day!';
  }
}
