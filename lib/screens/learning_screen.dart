import 'package:flutter/material.dart';
import '../services/course_service.dart';

class LearningScreen extends StatefulWidget {
  final int courseId;
  const LearningScreen({super.key, required this.courseId});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  Map<String, dynamic>? _learningData;
  bool _isLoading = true;
  Map<String, dynamic>? _selectedLesson;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() async {
    final data = await CourseService.getCourseContent(widget.courseId);
    if (mounted) {
      setState(() {
        _learningData = data;
        _isLoading = false;
        if (data != null) {
          _progress = (data['phanTramTienDo'] ?? 0.0).toDouble() / 100;
          if (_selectedLesson == null && data['chuongs'] != null && (data['chuongs'] as List).isNotEmpty) {
            final firstChapter = data['chuongs'][0];
            if (firstChapter['baiHocs'] != null && (firstChapter['baiHocs'] as List).isNotEmpty) {
              _selectedLesson = firstChapter['baiHocs'][0];
            }
          }
        }
      });
    }
  }

  void _completeLesson(int lessonId) async {
    final result = await CourseService.completeLesson(lessonId);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chúc mừng! Bạn đã hoàn thành bài học.')),
      );
      _loadContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_learningData == null) {
      return const Scaffold(body: Center(child: Text('Không thể tải nội dung học tập.')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_learningData!['tieuDe'] ?? 'Đang học', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildVideoPlayer(),
          _buildProgressBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildLessonContent()),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _buildCurriculum()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_selectedLesson != null && _selectedLesson!['linkVideo'] != null)
              const Icon(Icons.play_circle_fill, size: 80, color: Colors.white)
            else
              const Text('Không có video cho bài học này', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tiến độ học tập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent() {
    if (_selectedLesson == null) return const Center(child: Text('Hãy chọn bài học để bắt đầu.'));
    final bool isCompleted = _selectedLesson!['daHoanThanh'] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_selectedLesson!['lyThuyet'] ?? 'Bài học', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Nội dung chi tiết sẽ hiển thị tại đây...', style: TextStyle(height: 1.6)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isCompleted ? null : () => _completeLesson(_selectedLesson!['maBaiHoc']),
              icon: Icon(isCompleted ? Icons.check : Icons.done_all),
              label: Text(isCompleted ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculum() {
    final List chapters = _learningData!['chuongs'] ?? [];
    return ListView.builder(
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final List lessons = chapter['baiHocs'] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Text('Chương ${index + 1}: ${chapter['tieuDe']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            ...lessons.map((lesson) {
              final isSelected = _selectedLesson?['maBaiHoc'] == lesson['maBaiHoc'];
              final isCompleted = lesson['daHoanThanh'] ?? false;
              return ListTile(
                dense: true,
                selected: isSelected,
                leading: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                  color: isCompleted ? Colors.green : (isSelected ? Colors.blue : Colors.grey),
                  size: 20,
                ),
                title: Text(lesson['lyThuyet'] ?? 'Bài học', style: TextStyle(fontSize: 13, color: isSelected ? Colors.blue : Colors.black87)),
                onTap: () => setState(() => _selectedLesson = lesson),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
