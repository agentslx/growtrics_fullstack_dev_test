
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../entities/solve_request/solve_result.dart' as entity;

class ResultBubble extends StatefulWidget {
  const ResultBubble({super.key, required this.result});

  final entity.SolveResult result;

  @override
  State<ResultBubble> createState() => _ResultBubbleState();
}

class _ResultBubbleState extends State<ResultBubble> {
  bool _showFinal = false;

  List<Widget> _buildSolution(String solution, TextTheme textTheme) {
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
                  child: Math.tex(
                    content,
                    mathStyle: MathStyle.display,
                    textStyle: textTheme.bodyMedium,
                  ),
                ),
              ),
            );
            i = j + 2;
            continue;
          } else {
            children.add(Text(para.substring(i), style: textTheme.bodyMedium));
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
                child: Math.tex(
                  content,
                  mathStyle: MathStyle.text,
                  textStyle: textTheme.bodyMedium,
                ),
              ),
            );
            i = j + 1;
            continue;
          } else {
            children.add(Text(para.substring(i), style: textTheme.bodyMedium));
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
          children.add(Text(textSeg, style: textTheme.bodyMedium));
        }
        i = j;
      }
      if (children.isEmpty) {
        children.add(Text(para, style: textTheme.bodyMedium));
      }
      widgets.add(Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: children,
      ));
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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.result.solution ?? '').isNotEmpty) ...[
              ..._buildSolution(widget.result.solution!, theme.textTheme),
              const SizedBox(height: 8),
            ] else ...[
              Text('No solution', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
            ],
            if ((widget.result.finalResult ?? '').isNotEmpty) ...[
              if (_showFinal)
                Text(
                  'Answer: ${widget.result.finalResult!}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _showFinal = true),
                  child: const Text('Show result'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

