import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  // State variables
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 50;
  String _selectedActivity = 'Play';
  TextEditingController _nameController = TextEditingController();

  // Timers and win tracking
  Timer? _hungerTimer;
  Timer? _winTimer;
  int _happySeconds = 0; // Tracks consecutive seconds with happiness > 80
  bool _hasWon = false;

  @override
  void initState() {
    super.initState();

    // Hunger timer (every 30 seconds)
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel += 5;
        if (hungerLevel > 100) hungerLevel = 100;
        _updateHappiness();
        _checkGameStatus();
      });
    });

    // Win timer (every second)
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (happinessLevel > 80) {
        _happySeconds++;
        if (_happySeconds >= 180 && !_hasWon) { // 3 minutes
          _hasWon = true;
          _showWinDialog();
        }
      } else {
        _happySeconds = 0; // Reset if happiness drops
      }
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // Pet actions
  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      energyLevel -= 10;
      _updateHunger();
      _checkGameStatus();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      energyLevel += 5;
      _updateHappiness();
      _checkGameStatus();
    });
  }

  void _performActivity() {
    setState(() {
      switch (_selectedActivity) {
        case 'Play':
          happinessLevel += 15;
          energyLevel -= 15;
          hungerLevel -= 5;
          break;
        case 'Sleep':
          energyLevel += 20;
          hungerLevel += 5;
          break;
        case 'Walk':
          happinessLevel += 10;
          energyLevel -= 10;
          hungerLevel -= 5;
          break;
      }
      // Clamp values
      happinessLevel = happinessLevel.clamp(0, 100);
      energyLevel = energyLevel.clamp(0, 100);
      hungerLevel = hungerLevel.clamp(0, 100);

      _checkGameStatus();
    });
  }

  // Happiness and hunger logic
  void _updateHappiness() {
    if (hungerLevel > 80) {
      happinessLevel -= 20;
    } else if (hungerLevel < 30) {
      happinessLevel += 10;
    }
    happinessLevel = happinessLevel.clamp(0, 100);
  }

  void _updateHunger() {
    hungerLevel += 5;
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel -= 20;
      happinessLevel = happinessLevel.clamp(0, 100);
    }
  }

  // Mood and color
  Color _moodColor(int happiness) {
    if (happiness > 70) return Colors.green;
    if (happiness >= 30) return Colors.blue;
    return Colors.red;
  }

  String _moodText(int happiness) {
    if (happiness > 70) return "Happy ";
    if (happiness >= 30) return "Neutral ";
    return "Growling ";
  }

  // Game status
  void _checkGameStatus() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Game Over"),
        content: Text("Your pet is too hungry and unhappy!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text("Restart"),
          )
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Congratulations!"),
        content: Text("Your pet has been happy for 3 minutes! You win! "),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text("Restart"),
          )
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      energyLevel = 50;
      _happySeconds = 0;
      _hasWon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Pet image with dynamic color
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _moodColor(happinessLevel),
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/image_pet.png',
                    width: 300,
                    height: 300,
                  ),
                ),
                SizedBox(height: 16),
                // Pet name input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Pet Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      petName = _nameController.text.isEmpty
                          ? "Your Pet"
                          : _nameController.text;
                    });
                  },
                  child: Text('Set Name'),
                ),
                SizedBox(height: 16),
                // Pet info
                Text('Name: $petName', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Mood: ${_moodText(happinessLevel)}',
                    style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Happiness Level: $happinessLevel',
                    style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Energy Level: $energyLevel', style: TextStyle(fontSize: 20)),
                SizedBox(height: 16),
                // Action buttons
                ElevatedButton(
                  onPressed: _playWithPet,
                  child: Text('Play with Your Pet'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _feedPet,
                  child: Text('Feed Your Pet'),
                ),
                SizedBox(height: 16),
                // Energy bar
                LinearProgressIndicator(
                  value: energyLevel / 100,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                  minHeight: 10,
                ),
                SizedBox(height: 16),
                // Activity selection
                DropdownButton<String>(
                  value: _selectedActivity,
                  items: ['Play', 'Sleep', 'Walk']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivity = value!;
                    });
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _performActivity,
                  child: Text('Perform Activity'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
