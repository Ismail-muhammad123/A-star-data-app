import 'package:flutter/material.dart';

class NetworkContainerCard extends StatelessWidget {
  const NetworkContainerCard({
    super.key,
    String this.imageUrl = "",
    String this.serviceName = "",
    required this.isSelected,
  });

  final bool isSelected;
  final String imageUrl;
  final String serviceName;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          if (!isSelected && Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color:
                    Colors.primaries[serviceName.length %
                        Colors.primaries.length],
                alignment: Alignment.center,
                child: Text(
                  serviceName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
