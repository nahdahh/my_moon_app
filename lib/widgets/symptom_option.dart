import 'package:flutter/material.dart';

class SymptomOption extends StatefulWidget {
  final String? imageUrl;
  final String label;
  final Color color;
  final bool small;
  final bool isSelected;
  final Function(bool) onToggle;

  const SymptomOption({
    Key? key,
    this.imageUrl,
    required this.label,
    required this.color,
    this.small = false,
    required this.isSelected,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<SymptomOption> createState() => _SymptomOptionState();
}

class _SymptomOptionState extends State<SymptomOption> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onToggle(!widget.isSelected);
      },
      child: Column(
        children: [
          Container(
            width: 60, // Ukuran seragam untuk semua
            height: 60, // Ukuran seragam untuk semua
            decoration: BoxDecoration(
              color: widget.isSelected ? widget.color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color,
                width: 2,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: _buildContent(),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 60, // Lebar label sama dengan lingkaran
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.small ? 10 : 12,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    // If we have an image URL, try to load it
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.imageUrl!,
          width: 40, // Ukuran gambar seragam
          height: 40, // Ukuran gambar seragam
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator(
              color: widget.isSelected ? Colors.white : widget.color,
              strokeWidth: 2,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print("Error loading image: ${widget.imageUrl} - $error");
            return Icon(
              Icons.image_not_supported_outlined,
              color: widget.isSelected ? Colors.white : widget.color,
              size: 24,
            );
          },
        ),
      );
    }
    
    // Default: empty circle with icon
    return Icon(
      Icons.circle_outlined,
      color: widget.isSelected ? Colors.white : widget.color,
      size: 30,
    );
  }
}
