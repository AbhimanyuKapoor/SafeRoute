// import 'package:flutter/material.dart';

// typedef DialogOptionBuilder<T> = Map<String, T?> Function();

// Future<T?> showGenericDialog<T>({
//   required BuildContext context,
//   required String title,
//   required String content,
//   required DialogOptionBuilder optionsBuilder,
// }) {
//   final options = optionsBuilder();
//   return showDialog<T>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: options.keys.map((optionTitle) {
//           final value = options[optionTitle];
//           return TextButton(
//             onPressed: () {
//               if (value != null) {
//                 Navigator.of(context).pop(value);
//               } else {
//                 Navigator.of(context).pop();
//               }
//             },
//             child: Text(optionTitle),
//           );
//         }).toList(),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();

  return showDialog<T>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white.withValues(alpha: 0.97),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 12),

              // Content
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF7F8C8D),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: options.keys.map((optionTitle) {
                  final value = options[optionTitle];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        if (value != null) {
                          Navigator.of(context).pop(value);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        optionTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
