import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  Map<String, dynamic>? _courseData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final data = await CourseService.getCourseDetails(widget.courseId);
    if (mounted) {
      setState(() {
        _courseData = data;
        _isLoading = false;
      });
    }
  }

  void _buyCourse() async {
    final success = await CourseService.buyCourse(widget.courseId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Course purchased successfully!' : 'Failed to purchase course.')),
      );
    }
  }

  void _showRatingDialog() {
    double _rating = 5.0;
    final _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<double>(
              value: _rating,
              items: [1.0, 2.0, 3.0, 4.0, 5.0].map((e) => DropdownMenuItem(value: e, child: Text('$e Stars'))).toList(),
              onChanged: (v) {
                if (v != null) _rating = v;
              },
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: 'Add a review (optional)'),
              maxLines: 3,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await CourseService.rateCourse(widget.courseId, _rating, _commentController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Rating submitted!' : 'Failed to submit rating.')),
                );
              }
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_courseData == null) {
      return const Scaffold(body: Center(child: Text('Failed to load course details.')));
    }

    final data = _courseData!;
    final price = data['giaGoc'] ?? 0;
    final imageUrl = data['anhUrl'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Course Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () async {
              final success = await CourseService.toggleBookmark(widget.courseId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Bookmark updated!' : 'Failed to update bookmark.')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null)
              Image.network(imageUrl, height: 200, fit: BoxFit.cover)
            else
              Container(height: 200, color: Colors.grey.shade200, child: const Icon(Icons.image, size: 80, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['tieuDe'] ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rating: ${data['tbdanhGia'] ?? 'N/A'} ⭐',
                    style: const TextStyle(fontSize: 16, color: Colors.amber),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['moTa'] ?? 'No description provided.',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _buyCourse,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                child: const Text('Buy Course', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showRatingDialog,
              icon: const Icon(Icons.star_rate, color: Colors.amber),
              tooltip: 'Rate Course',
            ),
          ],
        ),
      ),
    );
  }
}
