import 'package:flutter/material.dart';

void showPopUp(BuildContext context,
    {Widget popUpTitle = const SizedBox(),
    required Function function,
    String doFunctionText = "Ok",
    Widget popUpContent = const SizedBox(),
    bool dismissible = false}) {
  bool isLoading = false;
  bool functionIsAsync = function.runtimeType.toString().contains('Future<');
  showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, setState) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: popUpTitle,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLoading) popUpContent,
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            if (!isLoading)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            if (!isLoading)
              TextButton(
                onPressed: () async {
                  if (functionIsAsync) {
                    setState(() => isLoading = true);
                    await function();
                    if (context.mounted) Navigator.pop(context);
                    setState(() => isLoading = false);
                  } else {
                    setState(() => isLoading = true);
                    function();
                    if (context.mounted) Navigator.pop(context);
                    setState(() => isLoading = false);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black26,
                ),
                child: Text(
                  doFunctionText,
                ),
              ),
          ],
        );
      });
    },
  );
}
