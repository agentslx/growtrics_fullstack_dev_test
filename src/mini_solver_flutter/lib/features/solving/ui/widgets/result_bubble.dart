import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mini_solver_flutter/generated/colors.gen.dart';
import 'package:mini_solver_flutter/widgets/buttons/app_buttons.dart';

import '../../../../entities/solve_request/solve_result.dart' as entity;

class SolveResultBubble extends StatefulWidget {
  const SolveResultBubble({
    super.key,
    required this.result,
    required this.index,
    required this.length,
    required this.onRetry,
    this.shouldExpandByDefault = true,
  });

  final entity.SolveResult result;
  final int index, length;
  final VoidCallback onRetry;
  final bool shouldExpandByDefault;

  @override
  State<SolveResultBubble> createState() => _SolveResultBubbleState();
}

class _SolveResultBubbleState extends State<SolveResultBubble> {
  bool _showFinal = false;
  late bool _isCollapse = !widget.shouldExpandByDefault;

  List<Widget> _buildLatexBody(String solution, TextStyle textStyle) {
    final widgets = <Widget>[];
    final paragraphs = solution.split(RegExp(r'\n\n+'));
    for (var pIndex = 0; pIndex < paragraphs.length; pIndex++) {
      final para = paragraphs[pIndex];
      final children = <Widget>[];
      int i = 0;
      while (i < para.length) {
        if (i + 1 < para.length && para[i] == r'$' && para[i + 1] == r'$') {
          int j = i + 2;
          while (j + 1 < para.length && !(para[j] == r'$' && para[j + 1] == r'$')) {
            j++;
          }
          if (j + 1 < para.length) {
            final content = para.substring(i + 2, j);
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(content, mathStyle: MathStyle.display, textStyle: textStyle),
                ),
              ),
            );
            i = j + 2;
            continue;
          } else {
            children.add(Text(para.substring(i), style: textStyle));
            i = para.length;
            break;
          }
        }
        if (para[i] == r'$') {
          int j = i + 1;
          bool found = false;
          while (j < para.length) {
            if (para[j] == r'$' && (j == 0 || para[j - 1] != r'\\')) {
              found = true;
              break;
            }
            j++;
          }
          if (found) {
            final content = para.substring(i + 1, j);
            children.add(
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(content, mathStyle: MathStyle.text, textStyle: textStyle),
              ),
            );
            i = j + 1;
            continue;
          } else {
            children.add(Text(para.substring(i), style: textStyle));
            i = para.length;
            break;
          }
        }
        int j = i;
        while (j < para.length) {
          if (para[j] == r'$') break;
          j++;
        }
        if (j > i) {
          final textSeg = para.substring(i, j).replaceAll(r'\$', r'$');
          children.add(Text(textSeg, style: textStyle));
        }
        i = j;
      }
      if (children.isEmpty) {
        children.add(Text(para, style: textStyle));
      }
      widgets.add(
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: children,
        ),
      );
      if (pIndex < paragraphs.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((widget.result.solution ?? '').isNotEmpty) ...[
            GestureDetector(
              onTap: () => setState(() => _isCollapse = !_isCollapse),
              child: Container(
                color: ColorName.brandTeal.withAlpha((0.2 * 255).toInt()),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      _isCollapse ? Icons.keyboard_arrow_right_outlined : Icons.keyboard_arrow_down_outlined,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "solving.problem".tr(args: ['${widget.index + 1}/${widget.length}']),
                      style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            if (!_isCollapse)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _buildLatexBody(widget.result.solution!, theme.textTheme.bodyMedium!),
                ),
              ),
            const SizedBox(height: 8),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).copyWith(bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('solving.no_solution'.tr(), style: theme.textTheme.bodyMedium),
                  AppPrimaryButton(onPressed: widget.onRetry, label: 'solving.retry'.tr()),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if ((widget.result.finalResult ?? '').isNotEmpty) ...[
            if (_showFinal)
              Center(
                child: SizedBox(
                  height: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: _buildLatexBody(
                      'solving.answer'.tr(args: [widget.result.finalResult!]),
                      theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: ColorName.brandGreen),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: SizedBox(
                  height: 64,
                  child: AppBorderButton(
                    onPressed: () => setState(() => _showFinal = true),
                    label: 'solving.show_result'.tr(),
                    labelStyle: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorName.brandGreen,
                    ),
                    icon: Icon(Icons.visibility),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16,)
        ],
      ),
    );
  }
}
