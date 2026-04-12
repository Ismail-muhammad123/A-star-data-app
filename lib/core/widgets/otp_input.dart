import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final TextEditingController controller;
  final bool autofocus;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    required this.controller,
    this.autofocus = true,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );

    // Initialize controllers with any existing value from the main controller
    if (widget.controller.text.isNotEmpty) {
      for (
        int i = 0;
        i < widget.controller.text.length && i < widget.length;
        i++
      ) {
        _controllers[i].text = widget.controller.text[i];
      }
    }

    widget.controller.addListener(_updateFromMainController);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      });
    }
  }

  void _updateFromMainController() {
    String text = widget.controller.text;
    for (int i = 0; i < widget.length; i++) {
      if (i < text.length) {
        if (_controllers[i].text != text[i]) {
          _controllers[i].text = text[i];
        }
      } else {
        if (_controllers[i].text.isNotEmpty) {
          _controllers[i].clear();
        }
      }
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    widget.controller.removeListener(_updateFromMainController);
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _updateMainController();
  }

  void _onKeyPress(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  void _updateMainController() {
    String otp = _controllers.map((c) => c.text).join();
    if (widget.controller.text != otp) {
      widget.controller.text = otp;
    }
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 35,
          height: 45,
          child: RawKeyboardListener(
            focusNode: FocusNode(), // Dummy node for listener
            onKey: (event) => _onKeyPress(event, index),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => _onChanged(value, index),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}
