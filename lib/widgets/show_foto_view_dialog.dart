import 'dart:io';
import 'package:flutter/material.dart';

Future<void> showPhotoViewerDialog({
  required BuildContext context,
  required List<String> images,
  int initialIndex = 0,
  required String title,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return PhotoViewerDialog(
        images: images,
        initialIndex: initialIndex,
        title: title,
      );
    },
  );
}

class PhotoViewerDialog extends StatefulWidget {
  final List<String> images; // Пути к фото
  final int initialIndex; // С какого фото начать
  final String title;

  const PhotoViewerDialog({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.title,
  });

  @override
  State<PhotoViewerDialog> createState() => _PhotoViewerDialogState();
}

class _PhotoViewerDialogState extends State<PhotoViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Переход к предыдущей фотке
  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Переход к следующей фотке
  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Основная часть (PageView + кнопки влево/вправо)
            Expanded(
              child: Stack(
                children: [
                  // PageView со свайпом
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return _buildImageItem(
                        path: images[index],
                        title: widget.title,
                      );
                    },
                  ),

                  // Кнопка "назад" (если не на первом фото)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _goToPrevious,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF605F5A),
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            size: 35,
                            color:
                                _currentIndex > 0 ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Кнопка "вперёд" (если не на последнем фото)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _goToNext,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF605F5A),
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            size: 35,
                            color:
                                _currentIndex < widget.images.length - 1
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Горизонтальный список миниатюр (если фото больше одного)
            Container(
              height: 90,
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, thumbIndex) {
                  final isSelected = (thumbIndex == _currentIndex);
                  return GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(thumbIndex);
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(images[thumbIndex]),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Затемнение неактивной миниатюры
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.transparent
                                      : Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Кнопка Close
            Container(
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4FC3F7),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Построение одного слайда
  Widget _buildImageItem({required String path, required String title}) {
    return Stack(
      children: [
        // Само изображение
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Image.file(
              File(path),
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Текстовый заголовок вверху
        Positioned(
          top: 12,
          left: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF605F5A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 7.0,
              ),
              child: Text(title, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
