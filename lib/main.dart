
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ColorShadeMatchApp());
}

const purple = Color(0xFF8060D8);
const backgroundColor = Color(0xFFF7F2FF);

class ColorShadeMatchApp extends StatelessWidget {
  const ColorShadeMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Shade Match',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------- หน้าเข้าเกม ----------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8E8FF),
              Color(0xFFE8EFFF),
              Color(0xFFFFE8F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.palette_rounded,
                    size: 100,
                    color: purple,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Color Shade Match',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF44317F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ท้าทายสายตา จับคู่เฉดสีให้ใกล้เคียงที่สุด!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 36),
                  _mainButton(
                    text: 'เริ่มเกม',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _mainButton(
                    text: 'วิธีเล่น',
                    icon: Icons.help_outline_rounded,
                    outlined: true,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('วิธีเล่น'),
                          content: const Text(
                            '1. จดจำสีเป้าหมายที่แสดง\n'
                            '2. เลือกช่องสีที่มีเฉดใกล้เคียงที่สุด\n'
                            '3. ตอบถูกเพื่อรับคะแนน\n'
                            '4. กดผิดครบ 3 ครั้ง เกมจะจบทันที\n'
                            '5. มีเวลาเล่น 60 วินาที',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('เข้าใจแล้ว'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _mainButton(
                    text: 'ผู้จัดทำ',
                    icon: Icons.person_outline_rounded,
                    outlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _mainButton({
  required String text,
  required IconData icon,
  required VoidCallback onPressed,
  bool outlined = false,
}) {
  return SizedBox(
    width: 280,
    height: 54,
    child: outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
            style: OutlinedButton.styleFrom(
              foregroundColor: purple,
              side: const BorderSide(color: purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
  );
}

// ---------------- หน้าเล่นเกม ----------------

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  Timer? timer;
  int secondsLeft = 60;
  int mistakes = 0;
  int score = 0;
  int targetIndex = 0;
  bool gameEnded = false;

  late List<Color> shades;
  late Color targetColor;

  @override
  void initState() {
    super.initState();
    _newRound();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || gameEnded) return;

      setState(() {
        secondsLeft--;
      });

      if (secondsLeft <= 0) {
        _endGame('หมดเวลา!');
      }
    });
  }

  void _newRound() {
    final hue = random.nextDouble() * 360;
    final saturation = 0.45 + random.nextDouble() * 0.45;
    final lightness = 0.35 + random.nextDouble() * 0.35;

    targetColor = HSLColor.fromAHSL(
      1,
      hue,
      saturation,
      lightness,
    ).toColor();

    // สร้างสีที่มีเฉดใกล้เคียงกัน
    shades = List.generate(12, (index) {
      final hueShift = (index - 5.5) * 2.2;
      final lightShift = (index - 5.5) * 0.018;

      return HSLColor.fromColor(targetColor)
          .withHue((hue + hueShift) % 360)
          .withLightness(
            (lightness + lightShift).clamp(0.05, 0.95),
          )
          .toColor();
    });

    targetIndex = random.nextInt(shades.length);
    shades[targetIndex] = targetColor;
  }

  void _chooseColor(int index) {
    if (gameEnded) return;

    if (index == targetIndex) {
      setState(() {
        score += 10;
        _newRound();
      });
    } else {
      setState(() {
        mistakes++;
      });

      if (mistakes >= 3) {
        _endGame('ตอบผิดครบ 3 ครั้ง!');
      }
    }
  }

  void _endGame(String reason) {
    if (gameEnded) return;

    gameEnded = true;
    timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          reason: reason,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Shade Match'),
        backgroundColor: backgroundColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'ออกจากเกม',
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              timer?.cancel();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _statCard('เวลา', '$secondsLeft วินาที',
                      Icons.timer_outlined),
                  const SizedBox(width: 10),
                  _statCard('คะแนน', '$score', Icons.star_rounded),
                  const SizedBox(width: 10),
                  _statCard('ตอบผิด', '$mistakes/3',
                      Icons.close_rounded),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'จำสีนี้ไว้ แล้วเลือกสีที่ตรงกัน!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: targetColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: targetColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'เลือกเฉดสีเดียวกันจากตาราง',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: shades.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _chooseColor(index),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: shades[index],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.touch_app_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: purple, size: 22),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- หน้าเกมจบ ----------------

class ResultScreen extends StatelessWidget {
  final int score;
  final String reason;

  const ResultScreen({
    super.key,
    required this.score,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8E8FF),
              Color(0xFFE8EFFF),
              Color(0xFFFFE8F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 100,
                    color: Color(0xFFFFB547),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF44317F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(reason, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text('คะแนนของคุณ'),
                        const SizedBox(height: 8),
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _mainButton(
                    text: 'เล่นอีกครั้ง',
                    icon: Icons.replay_rounded,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _mainButton(
                    text: 'กลับหน้าหลัก',
                    icon: Icons.home_rounded,
                    outlined: true,
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- หน้าผู้จัดทำ ----------------

class CreatorScreen extends StatelessWidget {
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8E8FF),
              Color(0xFFE8EFFF),
              Color(0xFFFFE8F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.palette_rounded,
                      size: 80,
                      color: purple,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'ผู้จัดทำ',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44317F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'COLOR SHADE MATCH',
                      style: TextStyle(
                        letterSpacing: 2,
                        color: purple,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _creatorInfo('ชื่อ - นามสกุล', 'พรชิตา ชั่งทอง'),
                    const SizedBox(height: 16),
                    _creatorInfo('รหัสนักศึกษา', '016830641003-1'),
                    const SizedBox(height: 30),
                    _mainButton(
                      text: 'กลับหน้าหลัก',
                      icon: Icons.home_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _creatorInfo(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9DFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: purple,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF30234F),
            ),
          ),
        ],
      ),
    );
  }
}
