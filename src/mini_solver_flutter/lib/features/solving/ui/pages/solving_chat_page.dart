import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../cubits/solving_chat_cubit/solving_chat_cubit.dart';
import '../../cubits/solving_chat_cubit/solving_chat_state.dart';
import '../../../../entities/solve_request/solve_result.dart' as entity;

class SolvingChatPage extends StatelessWidget {
  const SolvingChatPage({super.key, this.initialImage});

  final File? initialImage;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SolvingChatCubit(initialImage: initialImage),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendText(BuildContext context) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<SolvingChatCubit>().addUserText(text);
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solve Chat'),
      ),
      body: BlocConsumer<SolvingChatCubit, SolvingChatState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          final msg = state.errorMessage;
          if (msg != null && msg.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (state.isSubmitting) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    if (item.hasResults) {
                      // Render multiple result bubbles (left)
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final r in item.results!)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: _ResultBubble(result: r),
                            ),
                        ],
                      );
                    }

                    final align = item.isMe ? Alignment.centerRight : Alignment.centerLeft;
                    final color = item.isMe ? Colors.blueAccent : Colors.grey.shade300;
                    final textColor = item.isMe ? Colors.white : Colors.black87;
                    final radius = BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(item.isMe ? 16 : 4),
                      bottomRight: Radius.circular(item.isMe ? 4 : 16),
                    );

                    Widget bubble;
                    if (item.image != null) {
                      bubble = ClipRRect(
                        borderRadius: radius,
                        child: Image.file(
                          item.image!,
                          width: 220,
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      bubble = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: color, borderRadius: radius),
                        child: Text(item.text ?? '', style: TextStyle(color: textColor)),
                      );
                    }

                    return Align(
                      alignment: align,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: bubble,
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendText(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _sendText(context),
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultBubble extends StatefulWidget {
  const _ResultBubble({required this.result});

  final entity.SolveResult result;

  @override
  State<_ResultBubble> createState() => _ResultBubbleState();
}

class _ResultBubbleState extends State<_ResultBubble> {
  bool _showFinal = false;

  List<Widget> _buildSolution(String solution, TextTheme textTheme) {
    final widgets = <Widget>[];
    // Normalize line breaks
    final paragraphs = solution.split(RegExp(r'\n\n+'));
    for (var pIndex = 0; pIndex < paragraphs.length; pIndex++) {
      final para = paragraphs[pIndex];
      // Parse inline ($...$) and display ($$...$$) math
      final children = <Widget>[];
      int i = 0;
      while (i < para.length) {
        // Detect $$ display math
        if (i + 1 < para.length && para[i] == r'$' && para[i + 1] == r'$') {
          // Find closing $$
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
            // Unmatched $$, treat as text
            children.add(Text(para.substring(i), style: textTheme.bodyMedium));
            i = para.length;
            break;
          }
        }
        // Detect inline $ math (ignore escaped \$)
        if (para[i] == r'$') {
          // Find closing unescaped $
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
            // Unmatched $, treat rest as text
            children.add(Text(para.substring(i), style: textTheme.bodyMedium));
            i = para.length;
            break;
          }
        }
        // Accumulate normal text until next $ or end
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
      // Wrap inline pieces and allow wrapping to next line
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
