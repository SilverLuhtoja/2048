import 'package:flutter/material.dart';

class ScoreBox extends StatefulWidget {
  final String text;
  final int value;

  const ScoreBox(this.text, this.value, {super.key});

  @override
  State<ScoreBox> createState() => _ScoreBoxState();
}

class _ScoreBoxState extends State<ScoreBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.text, style: textStyle()),
        Text(widget.value.toString(), style: textStyle())
      ],
    );
  }

  TextStyle textStyle() => const TextStyle(fontSize: 20);
}
