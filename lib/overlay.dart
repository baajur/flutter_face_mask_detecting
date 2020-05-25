import 'package:flutter/material.dart';

class Overlay extends StatelessWidget {
  const Overlay({
    @required List<dynamic> results,
    @required int previewH,
    @required int previewW,
    @required double screenH,
    @required double screenW,
  })  : _results = results,
        _previewH = previewH,
        _previewW = previewW,
        _screenH = screenH,
        _screenW = screenW;
  final List<dynamic> _results;
  final int _previewH;
  final int _previewW;
  final double _screenH;
  final double _screenW;

  Color _updateBorderColor(List<dynamic> bits) {
    String label;

    if (bits.length > 1) {
      final String firstLabel = bits.first["label"] as String;
      final double firstConfidence = bits.first["confidence"] as double;

      final String secondLabel = bits.last["label"] as String;
      final double secondConfidence = bits.last["confidence"] as double;

      if (firstConfidence > secondConfidence) {
        label = firstLabel;
      } else {
        label = secondLabel;
      }
    }
    if (bits.length == 1) {
      label = bits.first["label"] as String;
    }

    if (label == "without_mask") {
      return Colors.red;
    }

    if (label == "with_mask") {
      return Colors.greenAccent;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
          color: _updateBorderColor(_results),
          width: 15,
        )),
      ),
    );
  }
}
