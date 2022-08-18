import 'package:flutter/material.dart';
import 'package:hopsta_demo/shared/ui_helpers.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Key? key;
  final ButtonStyle? style;
  final Function()? onPressed;
  final bool isBusy;
  final BuildContext rootContext;
  CustomButton(this.label, this.rootContext,
      {this.key, this.style, this.onPressed, this.isBusy = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(300),
        child: Stack(children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            style: style ??
                TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.white,
                  textStyle: const TextStyle(fontSize: 20),
                  minimumSize: Size(twoThirdsScreenWidth(context), 80),
                ),
            onPressed: onPressed,
            child: (isBusy)
                ? ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 21.0, maxWidth: 21.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          )
        ]));
  }
}
