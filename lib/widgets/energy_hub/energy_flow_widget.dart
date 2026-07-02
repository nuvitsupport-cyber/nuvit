// lib/widgets/energy_hub/energy_flow_widget.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../models/energy_flow/energy_flow_state.dart';

class EnergyFlowWidget extends StatelessWidget {
  final EnergyFlowState? state; // Приймаємо стан

  const EnergyFlowWidget({super.key, this.state});

  static const Color neonGreen = Color(0xFF55FF00); 
  static const Color neonOrange = Color(0xFFFF9900); // Колір для мережі/генератора
  static const Color cardBg = Color(0xFF0A153A);    
  static const Color innerBg = Color(0xFF020D2D);   

  // Допоміжна функція форматування кВт
  String _formatKw(double watts) {
    if (watts == 0) return '0 Вт';
    if (watts.abs() < 1000) return '${watts.abs().toStringAsFixed(0)} Вт';
    return '${(watts.abs() / 1000).toStringAsFixed(2)} кВт';
  }

  @override
  Widget build(BuildContext context) {
    final flow = state ?? EnergyFlowState.empty();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        
        return Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12), 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Моніторинг енергопотоків',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Візуалізація розподілу потужності в реальному часі.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
              const SizedBox(height: 24),
              
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFlowDiagram(flow)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildBalanceCard(flow)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildFlowDiagram(flow),
                    const SizedBox(height: 20),
                    _buildBalanceCard(flow),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlowDiagram(EnergyFlowState flow) {
    // Збільшуємо висоту, щоб вмістити верхній вузол СЕС
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: innerBg, 
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          
          final cx = width / 2;
          final cy = (height / 2) + 20.0; // Опускаємо центр нижче для даху

          const double wallHalfWidth = 50.0; 
          const double wallHalfHeight = 35.0;
          const double roofHeight = 45.0;

          final double wallLeftX = cx - wallHalfWidth;
          final double wallRightX = cx + wallHalfWidth;
          final double houseBottomY = cy + wallHalfHeight;

          final double sideNodesY = cy - 25.0;     
          final double bottomNodeY = houseBottomY + 28.0;  
          final double topNodeY = (cy - wallHalfHeight) - roofHeight - 45.0;
          
          final double leftIconX = wallLeftX - 55.0; 
          final double rightIconX = wallRightX + 55.0;

          const double iconRadius = 21.5; 

          // Логіка відображення правого вузла
          bool useGen = flow.isGeneratorRunning;
          String rightTitle = useGen ? 'Генератор' : 'Мережа';
          IconData rightIcon = useGen ? Icons.settings_input_component_rounded : Icons.electric_bolt_rounded;
          double rightPower = useGen ? flow.generatorPowerWatts : flow.gridPowerWatts;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: NuvitHouseBackgroundPainter(
                    cx: cx, cy: cy,
                    wallHalfWidth: wallHalfWidth,
                    wallHalfHeight: wallHalfHeight,
                    roofHeight: roofHeight,
                  ),
                ),
              ),

              // Лінії потоків з передачею даних напрямку
              Positioned.fill(
                child: CustomPaint(
                  painter: EnergyFlowPainter(
                    cx: cx, cy: cy,
                    wallHalfWidth: wallHalfWidth,
                    wallLeftX: wallLeftX,
                    wallRightX: wallRightX,
                    sideNodesY: sideNodesY,
                    bottomNodeY: bottomNodeY,
                    topNodeY: topNodeY + 30, // точка входу в іконку
                    leftIconEdgeX: leftIconX,
                    rightIconEdgeX: rightIconX,
                    roofHeight: roofHeight,
                    wallHalfHeight: wallHalfHeight,
                    // Дані для напрямку:
                    solarWatts: flow.solarGenerationWatts,
                    batteryWatts: flow.batteryPowerWatts,
                    rightNodeWatts: rightPower,
                    houseWatts: flow.houseConsumptionWatts,
                  ),
                ),
              ),

              // Центральний вузол
              Positioned(
                left: cx - 7, top: cy - 7,
                child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: neonGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: neonGreen.withOpacity(0.8), blurRadius: 16, spreadRadius: 4)
                    ],
                  ),
                ),
              ),

              // ВЕРХНІЙ ВУЗОЛ (СЕС)
              Positioned(
                left: cx - 60,
                top: topNodeY,
                width: 120,
                child: _buildSideNode('Генерація СЕС', _formatKw(flow.solarGenerationWatts), Icons.solar_power_rounded),
              ),

              // ЛІВИЙ ВУЗОЛ (АКБ)
              Positioned(
                left: leftIconX - 60,
                width: 120,
                bottom: height - (sideNodesY + iconRadius) + 8,
                child: _buildSideNode('Акумулятор', _formatKw(flow.batteryPowerWatts), Icons.battery_charging_full_rounded),
              ),

              // ПРАВИЙ ВУЗОЛ (Мережа / Генератор)
              Positioned(
                left: rightIconX - 60,
                width: 120,
                bottom: height - (sideNodesY + iconRadius) + 8,
                child: _buildSideNode(rightTitle, _formatKw(rightPower), rightIcon, iconColor: useGen ? neonOrange : neonGreen),
              ),

              // НИЖНІЙ ВУЗОЛ (Будинок)
              Positioned(
                left: cx - 21.5, 
                top: bottomNodeY - iconRadius,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg, 
                        shape: BoxShape.circle,
                        border: Border.all(color: neonGreen.withOpacity(0.2), width: 1.5),
                      ),
                      child: const Icon(Icons.home_rounded, color: neonGreen, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Споживання', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                        Text(
                          _formatKw(flow.houseConsumptionWatts),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSideNode(String title, String value, IconData icon, {Color iconColor = neonGreen}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardBg, 
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(EnergyFlowState flow) {
    bool isSurplus = flow.energyBalanceWatts > 0;
    bool isDeficit = flow.energyBalanceWatts < 0;
    
    String sign = isSurplus ? "+" : (isDeficit ? "-" : "");
    String status = isSurplus ? "Надлишок генерації" : (isDeficit ? "Дефіцит енергії" : "Баланс ідеальний");
    Color mainColor = isDeficit ? neonOrange : neonGreen;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: innerBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Енергетичний баланс', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            '$sign${_formatKw(flow.energyBalanceWatts.abs())}',
            style: TextStyle(color: mainColor, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(status, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          const Spacer(),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(painter: ChartPainter(color: mainColor)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              Text('12:00', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              Text('24:00', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ... (NuvitHouseBackgroundPainter залишається без змін)
class NuvitHouseBackgroundPainter extends CustomPainter {
  final double cx, cy, wallHalfWidth, wallHalfHeight, roofHeight;
  NuvitHouseBackgroundPainter({required this.cx, required this.cy, required this.wallHalfWidth, required this.wallHalfHeight, required this.roofHeight});

  @override
  void paint(Canvas canvas, Size size) {
    const double overhang = 12.0;
    final double wallLeftX = cx - wallHalfWidth;
    final double wallRightX = cx + wallHalfWidth;
    final double roofBaseY = cy - wallHalfHeight;
    final double houseBottomY = cy + wallHalfHeight;
    final double roofPeakY = roofBaseY - roofHeight;

    final housePath = Path()
      ..moveTo(wallLeftX - overhang, roofBaseY)
      ..lineTo(cx, roofPeakY)
      ..lineTo(wallRightX + overhang, roofBaseY)
      ..lineTo(wallRightX, roofBaseY) 
      ..lineTo(wallRightX, houseBottomY)
      ..lineTo(wallLeftX, houseBottomY)
      ..lineTo(wallLeftX, roofBaseY)  
      ..close();

    final houseGlow = Paint()
      ..color = Colors.white.withOpacity(0.15) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final housePaint = Paint()
      ..color = Colors.white.withOpacity(0.4) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(housePath, houseGlow);
    canvas.drawPath(housePath, housePaint);
  }

  @override
  bool shouldRepaint(covariant NuvitHouseBackgroundPainter oldDelegate) => oldDelegate.cx != cx || oldDelegate.cy != cy;
}


class EnergyFlowPainter extends CustomPainter {
  final double cx, cy, wallHalfWidth, wallLeftX, wallRightX;
  final double sideNodesY, bottomNodeY, topNodeY;
  final double leftIconEdgeX, rightIconEdgeX, roofHeight, wallHalfHeight;
  
  // Дані стану
  final double solarWatts;
  final double batteryWatts;
  final double rightNodeWatts;
  final double houseWatts;

  EnergyFlowPainter({
    required this.cx, required this.cy, required this.wallHalfWidth, required this.wallLeftX, required this.wallRightX,
    required this.sideNodesY, required this.bottomNodeY, required this.topNodeY, required this.leftIconEdgeX, required this.rightIconEdgeX,
    required this.roofHeight, required this.wallHalfHeight,
    required this.solarWatts, required this.batteryWatts, required this.rightNodeWatts, required this.houseWatts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EnergyFlowWidget.neonGreen
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = EnergyFlowWidget.neonGreen.withOpacity(0.35)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final double dy = cy - sideNodesY;
    final double dx = dy; 

    // СЕС (Дах)
    if (solarWatts > 0) {
      final pathTop = Path()..moveTo(cx, cy)..lineTo(cx, (cy - wallHalfHeight) - roofHeight + 5);
      canvas.drawPath(pathTop, glowPaint); canvas.drawPath(pathTop, paint);
      // Стрілка завжди до центру (вниз)
      _drawArrow(canvas, Offset(cx, (cy - wallHalfHeight) - roofHeight + 15), math.pi / 2, paint, glowPaint);
    }

    // Батарея (Ліворуч)
    if (batteryWatts != 0) {
      final pathLeft = Path()..moveTo(cx, cy)..lineTo(wallLeftX, cy)..lineTo(wallLeftX - dx, sideNodesY)..lineTo(leftIconEdgeX, sideNodesY);
      canvas.drawPath(pathLeft, glowPaint); canvas.drawPath(pathLeft, paint);
      
      if (batteryWatts > 0) { // Розряд (до центру)
        _drawArrow(canvas, Offset(wallLeftX - dx/2, sideNodesY + dy/2), 0, paint, glowPaint); 
      } else { // Заряд (від центру)
        _drawArrow(canvas, Offset(leftIconEdgeX + 10, sideNodesY), math.pi, paint, glowPaint);
      }
    }

    // Мережа / Генератор (Праворуч)
    if (rightNodeWatts != 0) {
      final pathRight = Path()..moveTo(cx, cy)..lineTo(wallRightX, cy)..lineTo(wallRightX + dx, sideNodesY)..lineTo(rightIconEdgeX, sideNodesY);
      canvas.drawPath(pathRight, glowPaint); canvas.drawPath(pathRight, paint);
      
      if (rightNodeWatts > 0) { // Імпорт (до центру)
        _drawArrow(canvas, Offset(wallRightX + dx/2, sideNodesY + dy/2), math.pi, paint, glowPaint); 
      } else { // Експорт (від центру)
        _drawArrow(canvas, Offset(rightIconEdgeX - 10, sideNodesY), 0, paint, glowPaint);
      }
    }

    // Будинок (Знизу)
    if (houseWatts > 0) {
      final pathBottom = Path()..moveTo(cx, cy)..lineTo(cx, bottomNodeY);
      canvas.drawPath(pathBottom, glowPaint); canvas.drawPath(pathBottom, paint);
      // Завжди до будинку (вниз)
      _drawArrow(canvas, Offset(cx, bottomNodeY - 5), math.pi / 2, paint, glowPaint);
    }

    // Крапки на перетині ліній
    final dotPaint = Paint()..color = EnergyFlowWidget.neonGreen;
    final dotGlow = Paint()..color = EnergyFlowWidget.neonGreen.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    void drawDot(Offset offset) {
      canvas.drawCircle(offset, 3.5, dotGlow); canvas.drawCircle(offset, 3.5, dotPaint);
    }

    if (batteryWatts != 0) drawDot(Offset(wallLeftX, cy)); 
    if (rightNodeWatts != 0) drawDot(Offset(wallRightX, cy)); 
  }

  void _drawArrow(Canvas canvas, Offset tip, double angle, Paint paint, Paint glow) {
    final path = Path();
    const double arrowSize = 7.0;
    path.moveTo(0, 0); path.lineTo(-arrowSize, -arrowSize * 0.7); path.lineTo(-arrowSize, arrowSize * 0.7); path.close();

    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle); 
    
    final fillPaint = Paint()..color = paint.color..style = PaintingStyle.fill;
    canvas.drawPath(path, glow); canvas.drawPath(path, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EnergyFlowPainter old) => true; // Завжди перемальовуємо при зміні даних
}

class ChartPainter extends CustomPainter {
  final Color color;
  ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.75, size.height * -0.1, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.close();

    final gradient = ui.Gradient.linear(
      const Offset(0, 0), Offset(0, size.height),
      [color.withOpacity(0.35), color.withOpacity(0.0)],
    );

    canvas.drawPath(path, Paint()..shader = gradient);

    final linePath = Path();
    linePath.moveTo(0, size.height);
    linePath.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.3);
    linePath.quadraticBezierTo(size.width * 0.75, size.height * -0.1, size.width, size.height * 0.4);

    canvas.drawPath(linePath, Paint()..color = color..strokeWidth = 2.0..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}