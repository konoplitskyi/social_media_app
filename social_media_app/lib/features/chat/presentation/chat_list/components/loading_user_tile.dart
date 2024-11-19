import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingUserTile extends StatelessWidget {
  const LoadingUserTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 75,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
