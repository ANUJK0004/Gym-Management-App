import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/report_trend.dart';

class ReportTrendCard extends StatefulWidget {
  const ReportTrendCard({
    super.key,
    required this.trends,
  });

  final List<ReportTrend> trends;

  @override
  State<ReportTrendCard> createState() => _ReportTrendCardState();
}

class _ReportTrendCardState extends State<ReportTrendCard> {
  ReportTrendType _selected = ReportTrendType.members;

  ReportTrend? get _trend {
    for (final trend in widget.trends) {
      if (trend.type == _selected) {
        return trend;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final trend = _trend;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Trends',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _Tab(
                selected: _selected == ReportTrendType.members,
                label: 'Members',
                onTap: () {
                  setState(() {
                    _selected = ReportTrendType.members;
                  });
                },
              ),
              const SizedBox(width: 6),
              _Tab(
                selected: _selected == ReportTrendType.retention,
                label: 'Retention',
                onTap: () {
                  setState(() {
                    _selected = ReportTrendType.retention;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: trend == null || trend.points.isEmpty
                ? const Center(
                    child: Text(
                      'No trend data yet.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  )
                : _TrendChart(trend: trend),
          ),
          if (trend != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Current',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCurrent(trend),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(
                  'vs ${trend.points.first.month}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatChange(trend),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.owner,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrent(ReportTrend trend) {
    if (trend.type == ReportTrendType.retention) {
      return '${trend.currentValue.toStringAsFixed(0)}%';
    }
    return trend.currentValue.toStringAsFixed(0);
  }

  String _formatChange(ReportTrend trend) {
    final value = trend.changeFromStart;
    final prefix = value >= 0 ? '+' : '';

    if (trend.type == ReportTrendType.retention) {
      return '$prefix${value.toStringAsFixed(0)}%';
    }

    return '$prefix${value.toStringAsFixed(0)}';
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.owner
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.black
                : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.trend,
  });

  final ReportTrend trend;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendPainter(trend),
      child: const SizedBox.expand(),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.trend);

  final ReportTrend trend;

  @override
  void paint(Canvas canvas, Size size) {
    final values = trend.points.map((point) => point.value).toList();
    if (values.isEmpty) {
      return;
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1
        ? 1
        : (maxValue - minValue);

    final chartRect = Rect.fromLTWH(
      4,
      8,
      size.width - 8,
      size.height - 30,
    );

    final linePaint = Paint()
      ..color = AppColors.owner
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.owner.withValues(alpha: .24),
          AppColors.owner.withValues(alpha: .02),
        ],
      ).createShader(chartRect);

    final path = Path();

    for (var index = 0; index < values.length; index++) {
      final dx = values.length == 1
          ? chartRect.center.dx
          : chartRect.left +
              (chartRect.width * index / (values.length - 1));

      final normalized =
          (values[index] - minValue) / range;

      final dy = chartRect.bottom -
          (chartRect.height * normalized);

      final point = Offset(dx, dy);

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(chartRect.right, chartRect.bottom)
      ..lineTo(chartRect.left, chartRect.bottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final pointRadius = 3.5;
    final lastIndex = values.length - 1;
    final lastX = values.length == 1
        ? chartRect.center.dx
        : chartRect.left +
            (chartRect.width * lastIndex / (values.length - 1));
    final lastNormalized =
        (values[lastIndex] - minValue) / range;
    final lastY = chartRect.bottom -
        chartRect.height * lastNormalized;

    canvas.drawCircle(
      Offset(lastX, lastY),
      pointRadius,
      Paint()..color = AppColors.owner,
    );

    final textStyle = const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 7,
    );

    for (var index = 0; index < trend.points.length; index++) {
      final point = trend.points[index];
      final textPainter = TextPainter(
        text: TextSpan(
          text: point.month.substring(0, 1),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final dx = trend.points.length == 1
          ? chartRect.center.dx
          : chartRect.left +
              (chartRect.width * index /
                  (trend.points.length - 1));

      textPainter.paint(
        canvas,
        Offset(
          dx - textPainter.width / 2,
          size.height - 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.trend != trend;
  }
}
