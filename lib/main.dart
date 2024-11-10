import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Calculator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color buttonBackground;
  final Color textColor;
  final Color displayTextColor;
  final Color operatorTextColor;
  final Color expressionColor;

  ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.buttonBackground,
    required this.textColor,
    required this.displayTextColor,
    required this.operatorTextColor,
    required this.expressionColor,
  });
}

class ThemeAnimationClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  ThemeAnimationClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(ThemeAnimationClipper oldClipper) {
    return center != oldClipper.center || radius != oldClipper.radius;
  }
}

class ExpressionParser {
  static double evaluate(String expression) {
    try {
      expression = expression.replaceAll(' ', '');
      while (expression.contains('(')) {
        int openBracket = expression.lastIndexOf('(');
        int closeBracket = expression.indexOf(')', openBracket);
        if (closeBracket == -1) throw FormatException('Mismatched brackets');
        
        String subExpr = expression.substring(openBracket + 1, closeBracket);
        double subResult = evaluate(subExpr);
        
        expression = expression.substring(0, openBracket) +
                    subResult.toString() +
                    expression.substring(closeBracket + 1);
      }
      
      List<String> numbers = [];
      List<String> operators = [];
      String currentNumber = '';
      
      for (int i = 0; i < expression.length; i++) {
        String char = expression[i];
        if (char == '+' || char == '-' || char == '×' || char == '÷') {
          if (currentNumber.isEmpty && char == '-') {
            currentNumber = '-';
          } else {
            if (currentNumber.isNotEmpty) {
              numbers.add(currentNumber);
              currentNumber = '';
            }
            operators.add(char);
          }
        } else {
          currentNumber += char;
        }
      }
      if (currentNumber.isNotEmpty) {
        numbers.add(currentNumber);
      }
      
      List<double> values = numbers.map((n) => double.parse(n)).toList();
      
      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == '×' || operators[i] == '÷') {
          double result;
          if (operators[i] == '×') {
            result = values[i] * values[i + 1];
          } else {
            if (values[i + 1] == 0) throw FormatException('Division by zero');
            result = values[i] / values[i + 1];
          }
          values[i] = result;
          values.removeAt(i + 1);
          operators.removeAt(i);
          i--;
        }
      }
      
      double result = values[0];
      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == '+') {
          result += values[i + 1];
        } else if (operators[i] == '-') {
          result -= values[i + 1];
        }
      }
      
      return result;
    } catch (e) {
      throw FormatException('Invalid expression');
    }
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> 
    with TickerProviderStateMixin {
  String _expression = '';
  String _result = '0';
  Offset? _themeToggleCenter;
  double _maxRadius = 0;
  int _selectedTheme = 0;
  
  final List<ThemeColors> themes = [
    ThemeColors(
      primary: Colors.orange[700]!,
      secondary: Colors.grey[850]!,
      background: const Color(0xFF121212),
      buttonBackground: const Color(0xFF2D2D2D),
      textColor: Colors.white,
      displayTextColor: Colors.white,
      operatorTextColor: Colors.white,
      expressionColor: Colors.grey[400]!,
    ),
    ThemeColors(
      primary: Colors.blue[700]!,
      secondary: Colors.grey[200]!,
      background: Colors.white,
      buttonBackground: const Color(0xFFF0F0F0),
      textColor: Colors.black87,
      displayTextColor: Colors.black,
      operatorTextColor: Colors.white,
      expressionColor: Colors.grey[600]!,
    ),
    ThemeColors(
      primary: Colors.lightBlue[400]!,
      secondary: const Color(0xFF1A237E),
      background: const Color(0xFF0D1B2A),
      buttonBackground: const Color(0xFF1B2A44),
      textColor: Colors.white,
      displayTextColor: Colors.lightBlue[200]!,
      operatorTextColor: Colors.white,
      expressionColor: Colors.lightBlue[100]!,
    ),
  ];

  late ThemeColors _currentTheme;
  late AnimationController _buttonController;
  late AnimationController _themeController;
  late Animation<double> _buttonScale;
  late Animation<double> _themeRadius;

  @override
  void initState() {
    super.initState();
    _currentTheme = themes[0];
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _themeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _themeRadius = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _themeController, curve: Curves.easeOutCirc),
    );
  }

  void _cycleTheme(BuildContext context, TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    
    setState(() {
      _themeToggleCenter = localOffset;
      final Size size = box.size;
      _maxRadius = math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));
      _selectedTheme = (_selectedTheme + 1) % themes.length;
      _currentTheme = themes[_selectedTheme];
    });
    
    _themeController.forward(from: 0.0);
  }

  Widget _buildAdvancedButton(String text, {Color? color, bool isOperation = false}) {
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: GestureDetector(
            onTapDown: (_) => _buttonController.forward(),
            onTapUp: (_) => _buttonController.reverse(),
            onTapCancel: () => _buttonController.reverse(),
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color ?? _currentTheme.buttonBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentTheme.background.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(35),
                  onTap: () => _onInput(text),
                  child: Center(
                    child: Transform.scale(
                      scale: _buttonScale.value * 1.1,  // Text pop-out effect
                      child: Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'Host Grotesk',
                          fontSize: 24,
                          color: isOperation
                              ? (color != null ? _currentTheme.operatorTextColor : _currentTheme.primary)
                              : _currentTheme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _currentTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTapDown: (details) => _cycleTheme(context, details),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentTheme.buttonBackground,
                          ),
                          child: Icon(
                            Icons.palette,
                            color: _currentTheme.textColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _expression,
                          style: GoogleFonts.robotoMono(
                            fontSize: 24,
                            color: _currentTheme.expressionColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _themeRadius,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _themeRadius.value,
                              child: Text(
                                _result,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _currentTheme.displayTextColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 4,
                    children: [
                      _buildAdvancedButton('C', color: Colors.red[400], isOperation: true),
                      _buildAdvancedButton('(', color: _currentTheme.primary, isOperation: true),
                      _buildAdvancedButton(')', color: _currentTheme.primary, isOperation: true),
                      _buildAdvancedButton('÷', color: _currentTheme.primary, isOperation: true),
                      _buildAdvancedButton('7'),
                      _buildAdvancedButton('8'),
                      _buildAdvancedButton('9'),
                      _buildAdvancedButton('×', color: _currentTheme.primary, isOperation: true),
                      _buildAdvancedButton('4'),
                      _buildAdvancedButton('5'),
                      _buildAdvancedButton('6'),
                      _buildAdvancedButton('-', color: _currentTheme.primary, isOperation: true),
                      _buildAdvancedButton('1'),
                      _buildAdvancedButton('2'),
                      _buildAdvancedButton('3'),
                      _buildAdvancedButton('+', color: _currentTheme.primary, isOperation: true),
                      _buildAdvancedButton('±'),
                      _buildAdvancedButton('0'),
                      _buildAdvancedButton('.'),
                      _buildAdvancedButton('=', color: _currentTheme.primary, isOperation: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onInput(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          if (_expression.isNotEmpty) {
            _calculateResult();
          } else {
            _result = '0';
          }
        }
      } else if (value == '=') {
        _calculateResult(finalResult: true);
      } else if (value == '±') {
        if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        } else {
          _expression = '-$_expression';
        }
        if (_expression.isNotEmpty) {
          _calculateResult();
        }
      } else {
        _expression += value;
        _calculateResult();
      }
    });
  }

  void _calculateResult({bool finalResult = false}) {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }

    try {
      double eval = ExpressionParser.evaluate(_expression);
      if (finalResult) _expression = eval.toString();
      _result = eval % 1 == 0 ? eval.toInt().toString() : eval.toStringAsFixed(8);
    } catch (e) {
      _result = 'Error';
    }
  }
}
