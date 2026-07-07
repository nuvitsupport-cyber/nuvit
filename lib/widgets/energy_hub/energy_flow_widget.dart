// lib/widgets/energy_hub/energy_flow_widget.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../models/energy_flow/energy_flow_state.dart';
import '../../models/energy_flow/energy_connection.dart';

class EnergyFlowWidget extends StatelessWidget {
  final EnergyFlowState? state;

  const EnergyFlowWidget({super.key, this.state});

  static const Color neonGreen = Color(0xFF55FF00); 
  static const Color neonOrange = Color(0xFFFF9900); 
  static const Color cardBg = Color(0xFF0A153A);    
  static const Color innerBg = Color(0xFF020D2D);   

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
          final cy = (height / 2) + 20.0; 

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

          bool useGen = flow.statistics.isGeneratorRunning;
          String rightTitle = useGen ? 'Генератор' : 'Мережа';
          IconData rightIcon = useGen ? Icons.settings_input_component_rounded : Icons.electric_bolt_rounded;
          double rightPower = useGen ? flow.summary.generatorPowerWatts : flow.summary.gridPowerWatts;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Контур будинку (завжди видимий)
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

              // 2. Рендеринг ліній та стрілок строго за наявністю елементів у connections
              Positioned.fill(
                child: CustomPaint(
                  painter: EnergyFlowPainter(
                    cx: cx, cy: cy,
                    wallHalfWidth: wallHalfWidth,
                    wallLeftX: wallLeftX,
                    wallRightX: wallRightX,
                    sideNodesY: sideNodesY,
                    bottomNodeY: bottomNodeY,
                    leftIconEdgeX: leftIconX,
                    rightIconEdgeX: rightIconX,
                    roofHeight: roofHeight,
                    wallHalfHeight: wallHalfHeight,
                    connections: flow.connections,
                  ),
                ),
              ),

              // 3. Центральна точка перетину
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

              // 4. Вузол СЕС
              Positioned(
                left: cx - 60,
                top: topNodeY,
                width: 120,
                child: _buildSideNode('Генерація СЕС', _formatKw(flow.summary.solarGenerationWatts), Icons.solar_power_rounded),
              ),

              // 5. Вузол АКБ
              Positioned(
                left: leftIconX - 60,
                width: 120,
                bottom: height - (sideNodesY + iconRadius) + 8,
                child: _buildSideNode('Акумулятор', _formatKw(flow.summary.batteryPowerWatts), Icons.battery_charging_full_rounded),
              ),

              // 6. Вузол Мережа / Генератор
              Positioned(
                left: rightIconX - 60,
                width: 120,
                bottom: height - (sideNodesY + iconRadius) + 8,
                child: _buildSideNode(rightTitle, _formatKw(rightPower), rightIcon, iconColor: useGen ? neonOrange : neonGreen),
              ),

              // 7. Вузол Споживання Дому
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
                          _formatKw(flow.summary.houseConsumptionWatts),
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
    bool isSurplus = flow.statistics.energyBalanceWatts > 0;
    bool isDeficit = flow.statistics.energyBalanceWatts < 0;
    
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
            '$sign${_formatKw(flow.statistics.energyBalanceWatts.abs())}',
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
  final double sideNodesY, bottomNodeY;
  final double leftIconEdgeX, rightIconEdgeX, roofHeight, wallHalfHeight;
  
  final List<EnergyConnection> connections;

  EnergyFlowPainter({
    required this.cx, required this.cy, required this.wallHalfWidth, required this.wallLeftX, required this.wallRightX,
    required this.sideNodesY, required this.bottomNodeY, required this.leftIconEdgeX, required this.rightIconEdgeX,
    required this.roofHeight, required this.wallHalfHeight,
    required this.connections,
  });

  void _drawBranch(Canvas canvas, String nodeId, Paint paint, Paint glowPaint) {
    final path = Path();
    final double dy = cy - sideNodesY;
    final double dx = dy;

    if (nodeId == 'solar') {
      path.moveTo(cx, cy);
      path.lineTo(cx, (cy - wallHalfHeight) - roofHeight + 5);
    } else if (nodeId == 'house') {
      path.moveTo(cx, cy);
      path.lineTo(cx, bottomNodeY);
    } else if (nodeId == 'battery') {
      path.moveTo(cx, cy);
      path.lineTo(wallLeftX, cy);
      path.lineTo(wallLeftX - dx, sideNodesY);
      path.lineTo(leftIconEdgeX, sideNodesY);
    } else if (nodeId == 'grid' || nodeId == 'generator') {
      path.moveTo(cx, cy);
      path.lineTo(wallRightX, cy);
      path.lineTo(wallRightX + dx, sideNodesY);
      path.lineTo(rightIconEdgeX, sideNodesY);
    } else {
      return;
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  void _drawArrowForBranch(Canvas canvas, String nodeId, bool isSource, Paint paint, Paint glowPaint) {
    final double dy = cy - sideNodesY;
    final double dx = dy;
    Offset tip;
    double angle;

    if (nodeId == 'solar') {
      tip = Offset(cx, (cy - wallHalfHeight) - roofHeight + 15);
      angle = math.pi / 2; 
    } else if (nodeId == 'house') {
      tip = Offset(cx, bottomNodeY - 5);
      angle = math.pi / 2; 
    } else if (nodeId == 'battery') {
      if (isSource) {
        tip = Offset(wallLeftX - dx / 2, sideNodesY + dy / 2);
        angle = 0; 
      } else {
        tip = Offset(leftIconEdgeX + 10, sideNodesY);
        angle = math.pi; 
      }
    } else if (nodeId == 'grid' || nodeId == 'generator') {
      if (isSource) {
        tip = Offset(wallRightX + dx / 2, sideNodesY + dy / 2);
        angle = math.pi; 
      } else {
        tip = Offset(rightIconEdgeX - 10, sideNodesY);
        angle = 0; 
      }
    } else {
      return;
    }

    _drawArrow(canvas, tip, angle, paint, glowPaint);
  }

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

    bool drawLeftDot = false;
    bool drawRightDot = false;

    // Малюємо лінії виключно за наявністю у списку з потужністю > 0
    for (final conn in connections) {
      if (conn.powerWatts.abs() <= 0.1) continue;

      _drawBranch(canvas, conn.from, paint, glowPaint);
      _drawArrowForBranch(canvas, conn.from, true, paint, glowPaint);

      _drawBranch(canvas, conn.to, paint, glowPaint);
      _drawArrowForBranch(canvas, conn.to, false, paint, glowPaint);

      if (conn.from == 'battery' || conn.to == 'battery') drawLeftDot = true;
      if (['grid', 'generator'].contains(conn.from) || ['grid', 'generator'].contains(conn.to)) drawRightDot = true;
    }

    final dotPaint = Paint()..color = EnergyFlowWidget.neonGreen;
    final dotGlow = Paint()..color = EnergyFlowWidget.neonGreen.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    void drawDot(Offset offset) {
      canvas.drawCircle(offset, 3.5, dotGlow); canvas.drawCircle(offset, 3.5, dotPaint);
    }

    if (drawLeftDot) drawDot(Offset(wallLeftX, cy));
    if (drawRightDot) drawDot(Offset(wallRightX, cy));
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
  bool shouldRepaint(covariant EnergyFlowPainter old) => true; 
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