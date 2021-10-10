import 'package:flutter/material.dart';
import 'package:pets_weight_graph/constants/colors.dart';

class ChartPainter extends CustomPainter {
  final List<String> x;
  final List<double> y;
  final double min, max;

  double scale;
  double xOffset;

  ChartPainter(this.x, this.y, this.min, this.max, this.scale, this.xOffset);
  final linePaint = Paint()
    ..color = AppColors.chartColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  final dotPointFill = Paint()
    ..color = AppColors.backgroundColor
    ..style = PaintingStyle.fill
    ..strokeWidth = 4;
  static const TextStyle textStyle = TextStyle(
      color: AppColors.textColor,
      fontSize: 12,
      fontFamily: "Lato",
      fontWeight: FontWeight.w400,
      height: 1.3);

  static const double margin = 30.0;
  static const double maxLabelWidth = 30.0;
  static const double radius = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(clipRect);
    canvas.drawPaint(Paint()..color = AppColors.backgroundColor);

    final dHeight = size.height - 2.0 * margin;
    final dWidth = size.width - 2.0 * margin;
    final wd = dWidth / x.length.toDouble();

    final height = dHeight;
    final width = dWidth;

    if (height <= 0.0 || width <= 0.0) return;
    if (max - min < 1.0e-6) return;

    final hr = height / (max - min);

    List<double> yLabels = _computeYLables();
    double yPositon = margin;
    double step = height / 3;

    for (var i = 0; i < yLabels.length; i++) {
      _drawTextCentered(canvas, Offset(margin - 12, yPositon),
          yLabels[i].toInt().toString(), textStyle, maxLabelWidth);
      yPositon += step;
    }

    canvas.drawLine(const Offset(margin, margin),
        Offset(margin, margin + height), outlinePiant);

    canvas.clipRect(Rect.fromLTRB(margin, 0, size.width, size.height));

    // _drawOutLine(canvas, wd, height);
    _drawCenterLine(canvas, width, height);

    final points = _computePoints(wd, height, hr);
    final path = _computePath(points);
    canvas.drawPath(path, linePaint);
    for (var i = 0; i < points.length; i++) {
      var dp = points[i];
      dp = Offset(margin + (xOffset + dp.dx) * scale, dp.dy);
      canvas.drawLine(
          Offset(dp.dx, margin), Offset(dp.dx, margin + height), outlinePiant);
      canvas.drawCircle(dp, radius, dotPointFill);
      canvas.drawCircle(dp, radius, linePaint);
      var dp1 = Offset(dp.dx, 25 * hr);
      _drawTextCentered(canvas, dp1, x[i], textStyle, width);
    }

  }

  Path _computePath(List<Offset> points) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      if (i == 0) {
        path.moveTo(margin + (xOffset + p.dx) * scale, p.dy);
      } else {
        path.lineTo(margin + (xOffset + p.dx) * scale, p.dy);
      }
    }
    return path;
  }

  List<Offset> _computePoints(double width, double height, double hr) {
    List<Offset> points = [];
    var dx = width / 2;
    y.forEach((yp) {
      final yy = height - (yp - min) * hr;
      final dp = Offset(dx, margin + yy);
      points.add(dp);
      dx += width;
    });
    return points;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  final Paint outlinePiant = Paint()
    ..strokeWidth = 2.21
    ..style = PaintingStyle.stroke
    ..color = AppColors.chartBorderColor;

  final Paint dashedLinePiant = Paint()
    ..strokeWidth = 2.0
    ..color = AppColors.chartColor;

  _drawOutLine(Canvas canvas, double width, double height) {
    double dx = 0;
    y.forEach((p) {
      canvas.drawLine(
          Offset(margin + (xOffset + dx) * scale, margin),
          Offset(margin + (xOffset + dx) * scale, margin + height),
          outlinePiant);
      dx += width;
    });
  }

  _drawCenterLine(Canvas canvas, double width, double height) {
    var max = width;
    var dashWidth = 5;
    var dashSpace = 5;
    double startX = margin;
    while (max >= 0) {
      canvas.drawLine(Offset(startX, margin + height / 2),
          Offset(startX + dashSpace, margin + height / 2), dashedLinePiant);
      final space = (dashSpace + dashWidth);
      startX += space;
      max -= space;
    }
    // canvas.drawLine(s, Offset(s.dx + width, margin), dashedLinePiant);
  }

  TextPainter measureText(
      String s, TextStyle style, double maxWidth, TextAlign align) {
    final span = TextSpan(text: s, style: style);
    final tp = TextPainter(
        text: span, textAlign: align, textDirection: TextDirection.ltr);
    tp.layout(minWidth: 0, maxWidth: maxWidth);
    return tp;
  }

  _drawTextCentered(
      Canvas canvas, Offset s, String text, TextStyle style, double maxWidth) {
    final tp = measureText(text, style, maxWidth, TextAlign.center);
    final offset = s + Offset(-tp.width / 2.0, -tp.height / 2.0);
    tp.paint(canvas, offset);
    return tp.size;
  }

  List<double> _computeYLables() {
    double diff = max - min;
    double space = diff / 3;
    return [max, min + 2 * space, min + space, min];
  }
}
