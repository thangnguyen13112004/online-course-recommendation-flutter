import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/course_service.dart';
import '../utils/Toast.dart';
import 'pdf_viewer_screen.dart';

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

  // Video Controllers
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController = null;
    _videoPlayerController = null;
    _chewieController = null;
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
              _onLessonSelected(firstChapter['baiHocs'][0]);
            }
          }
        }
      });
    }
  }

  void _onLessonSelected(Map<String, dynamic> lesson) {
    if (_selectedLesson?['maBaiHoc'] == lesson['maBaiHoc']) return;

    setState(() {
      _selectedLesson = lesson;
      _disposeVideoControllers();
    });

    final String? videoUrl = lesson['linkVideo'];
    if (videoUrl != null && videoUrl.isNotEmpty) {
      if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
        final videoId = YoutubePlayer.convertUrlToId(videoUrl);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        }
      } else {
        // Direct video link (Cloudinary, MP4, etc.)
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        _videoPlayerController!.initialize().then((_) {
          if (mounted) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController!,
                autoPlay: false,
                looping: false,
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                placeholder: Container(color: Colors.black),
                errorBuilder: (context, errorMessage) {
                  return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
                },
              );
            });
          }
        });
      }
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

  Future<void> _openDocument(String? url, String title) async {
    if (url == null || url.isEmpty) return;

    if (url.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfUrl: url, title: title),
        ),
      );
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở tài liệu này.')),
          );
        }
      }
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
        title: Text(_learningData!['tieuDe'] ?? 'Đang học', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildPlayerArea(),
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

  Widget _buildPlayerArea() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _youtubeController != null
            ? YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blue,
              )
            : (_chewieController != null
                ? Chewie(controller: _chewieController!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.video_library, size: 50, color: Colors.white24),
                        const SizedBox(height: 8),
                        Text(
                          _selectedLesson?['linkVideo'] == null ? 'Không có video' : 'Đang tải video...',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tiến độ học tập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
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
    final String? theory = _selectedLesson!['lyThuyet'];
    final String? exercise = _selectedLesson!['baiTap'];
    final String? documentUrl = _selectedLesson!['linkTaiLieu'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(theory ?? 'Bài học', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (documentUrl != null && documentUrl.isNotEmpty) ...[
            const Text('Tài liệu học tập:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openDocument(documentUrl, theory ?? 'Tài liệu'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  children: [
                    Icon(documentUrl.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.file_present, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Nhấn để xem tài liệu chi tiết', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w500))),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (exercise != null && exercise.isNotEmpty) ...[
            const Text('Bài tập / Yêu cầu:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(exercise, style: const TextStyle(height: 1.5)),
            ),
            const SizedBox(height: 24),
          ],

          const Text('Nội dung lý thuyết:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Vui lòng theo dõi video và tài liệu đính kèm để nắm rõ kiến thức bài học.', style: TextStyle(color: Colors.grey, height: 1.5)),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isCompleted ? null : () => _completeLesson(_selectedLesson!['maBaiHoc']),
              icon: Icon(isCompleted ? Icons.check_circle : Icons.check_circle_outline),
              label: Text(isCompleted ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Text('Chương ${index + 1}: ${chapter['tieuDe']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            ...lessons.map((lesson) {
              final isSelected = _selectedLesson?['maBaiHoc'] == lesson['maBaiHoc'];
              final isCompleted = lesson['daHoanThanh'] ?? false;
              return ListTile(
                dense: true,
                selected: isSelected,
                selectedTileColor: Colors.blue.shade50.withOpacity(0.5),
                leading: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                  color: isCompleted ? Colors.green : (isSelected ? Colors.blue : Colors.grey),
                  size: 18,
                ),
                title: Text(
                  lesson['lyThuyet'] ?? 'Bài học', 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black87
                  )
                ),
                onTap: () => _onLessonSelected(lesson),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
