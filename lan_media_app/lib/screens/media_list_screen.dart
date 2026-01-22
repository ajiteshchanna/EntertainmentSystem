import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/api_service.dart';
import '../core/config.dart';

import 'audio_player_screen.dart';
import 'video_player_screen.dart';
import 'pdf_viewer_screen.dart';
import 'image_viewer_screen.dart';
import '../services/download_service.dart';

enum MediaFilter { all, audio, video, pdf, images }
enum MediaSort { az, za, type }
enum ViewMode { list, grid }

class MediaListScreen extends StatefulWidget {
  final String baseUrl;

  const MediaListScreen({super.key, required this.baseUrl});

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  late Future<List<MediaModel>> mediaFuture;

  MediaFilter _filter = MediaFilter.all;
  MediaSort _sort = MediaSort.az;
  ViewMode _viewMode = ViewMode.list;

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    AppConfig.baseUrl = widget.baseUrl;
    mediaFuture = ApiService.fetchMediaFiles();
  }

  Future<void> _refresh() async {
    setState(() {
      mediaFuture = ApiService.fetchMediaFiles();
    });
  }

  String _streamUrl(MediaModel media) {
    final encodedName = Uri.encodeComponent(media.name);
    return "${AppConfig.baseUrl}/api/stream/$encodedName";
  }

  bool _isImage(MediaModel media) {
    final lower = media.name.toLowerCase();
    return lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png") ||
        lower.endsWith(".webp");
  }

  bool _isPdf(MediaModel media) => media.name.toLowerCase().endsWith(".pdf");
  bool _isVideo(MediaModel media) => media.type == "video";
  bool _isAudio(MediaModel media) => media.type == "audio";

  IconData _getIcon(MediaModel media) {
    if (_isVideo(media)) return Icons.play_circle_fill_rounded;
    if (_isAudio(media)) return Icons.music_note_rounded;
    if (_isPdf(media)) return Icons.picture_as_pdf_rounded;
    if (_isImage(media)) return Icons.image_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _getAccentColor(MediaModel media) {
    if (_isVideo(media)) return Colors.redAccent;
    if (_isAudio(media)) return Colors.purpleAccent;
    if (_isPdf(media)) return Colors.orangeAccent;
    if (_isImage(media)) return Colors.lightBlueAccent;
    return Colors.grey;
  }

  void _openMedia(MediaModel media) {
    final url = _streamUrl(media);

    if (_isAudio(media)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AudioPlayerScreen(media: media)),
      );
      return;
    }

    if (_isVideo(media)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoUrl: url,
            title: media.name,
          ),
        ),
      );
      return;
    }

    if (_isPdf(media)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            pdfUrl: url,
            title: media.name,
          ),
        ),
      );
      return;
    }

    if (_isImage(media)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(
            imageUrl: url,
            title: media.name,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file: ${media.name}")),
    );
  }

  Future<void> _downloadMedia(MediaModel media) async {
    final url = _streamUrl(media);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloading ${media.name}..."),
          duration: const Duration(seconds: 2),
        ),
      );

      final path = await DownloadService.downloadFile(
        url: url,
        fileName: media.name,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved: $path")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  List<MediaModel> _applyFilter(List<MediaModel> list) {
    switch (_filter) {
      case MediaFilter.all:
        return list;
      case MediaFilter.audio:
        return list.where((m) => _isAudio(m)).toList();
      case MediaFilter.video:
        return list.where((m) => _isVideo(m)).toList();
      case MediaFilter.pdf:
        return list.where((m) => _isPdf(m)).toList();
      case MediaFilter.images:
        return list.where((m) => _isImage(m)).toList();
    }
  }

  List<MediaModel> _applySearch(List<MediaModel> list) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  List<MediaModel> _applySort(List<MediaModel> list) {
    final copied = [...list];

    switch (_sort) {
      case MediaSort.az:
        copied.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case MediaSort.za:
        copied.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;

      case MediaSort.type:
        copied.sort(
          (a, b) => a.type.toLowerCase().compareTo(b.type.toLowerCase()),
        );
        break;
    }

    return copied;
  }

  Widget _chip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: Colors.redAccent.withOpacity(0.20),
      labelStyle: TextStyle(
        color: selected ? Colors.redAccent : const Color.fromARGB(179, 0, 0, 0),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? Colors.redAccent : Colors.white12,
      ),
    );
  }

  // ✅ THUMBNAIL BUILDER (Drive Style)
  Widget _buildThumbnail(MediaModel media) {
    final accent = _getAccentColor(media);
    final url = _streamUrl(media);

    // ✅ IMAGE -> Real thumbnail
    if (_isImage(media)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.white10,
              child: Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: accent,
                  size: 34,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.white10,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    // ✅ VIDEO -> Preview UI
    if (_isVideo(media)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              color: Colors.white10,
              child: Center(
                child: Icon(Icons.movie_rounded, color: accent, size: 42),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "VIDEO",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ PDF / AUDIO / OTHER -> Icon tile
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: accent.withOpacity(0.10),
        child: Center(
          child: Icon(_getIcon(media), color: accent, size: 42),
        ),
      ),
    );
  }

  Widget _buildListItem(MediaModel media) {
    final accent = _getAccentColor(media);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openMedia(media),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIcon(media), color: accent),
            ),
            title: Text(
              media.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              media.type.toUpperCase(),
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: IconButton(
              tooltip: "Download",
              icon: const Icon(Icons.download_rounded),
              onPressed: () => _downloadMedia(media),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 100% OVERFLOW-PROOF GRID ITEM
  Widget _buildGridItem(MediaModel media) {
    final thumb = _buildThumbnail(media);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openMedia(media),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED HEIGHT THUMB (MAIN FIX)
            Stack(
              children: [
                SizedBox(
                  height: 118, // ✅ fixed height prevents overflow fully
                  width: double.infinity,
                  child: thumb,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withOpacity(0.40),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _downloadMedia(media),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ FIXED HEIGHT TEXT
            SizedBox(
              height: 20,
              child: Text(
                media.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 4),

            SizedBox(
              height: 14,
              child: Text(
                media.type.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MediaModel>>(
        future: mediaFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;

          final allMedia = snapshot.data ?? [];
          final filtered = _applySort(_applySearch(_applyFilter(allMedia)));

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                elevation: 0,
                title: const Text(
                  "LAN Media",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _viewMode = _viewMode == ViewMode.list
                            ? ViewMode.grid
                            : ViewMode.list;
                      });
                    },
                    icon: Icon(
                      _viewMode == ViewMode.list
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                    ),
                    tooltip:
                        _viewMode == ViewMode.list ? "Grid View" : "List View",
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  PopupMenuButton<MediaSort>(
                    icon: const Icon(Icons.sort_rounded),
                    onSelected: (val) => setState(() => _sort = val),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: MediaSort.az, child: Text("Sort: A → Z")),
                      PopupMenuItem(value: MediaSort.za, child: Text("Sort: Z → A")),
                      PopupMenuItem(value: MediaSort.type, child: Text("Sort: Type")),
                    ],
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(140),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: "Search files...",
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 42,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _chip(
                                  text: "All",
                                  icon: Icons.apps_rounded,
                                  selected: _filter == MediaFilter.all,
                                  onTap: () =>
                                      setState(() => _filter = MediaFilter.all),
                                ),
                                const SizedBox(width: 10),
                                _chip(
                                  text: "Audio",
                                  icon: Icons.music_note_rounded,
                                  selected: _filter == MediaFilter.audio,
                                  onTap: () =>
                                      setState(() => _filter = MediaFilter.audio),
                                ),
                                const SizedBox(width: 10),
                                _chip(
                                  text: "Video",
                                  icon: Icons.play_circle_rounded,
                                  selected: _filter == MediaFilter.video,
                                  onTap: () =>
                                      setState(() => _filter = MediaFilter.video),
                                ),
                                const SizedBox(width: 10),
                                _chip(
                                  text: "PDF",
                                  icon: Icons.picture_as_pdf_rounded,
                                  selected: _filter == MediaFilter.pdf,
                                  onTap: () =>
                                      setState(() => _filter = MediaFilter.pdf),
                                ),
                                const SizedBox(width: 10),
                                _chip(
                                  text: "Images",
                                  icon: Icons.image_rounded,
                                  selected: _filter == MediaFilter.images,
                                  onTap: () =>
                                      setState(() => _filter = MediaFilter.images),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No files found 🚫",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                )
              else if (_viewMode == ViewMode.list)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: filtered.length,
                    (context, index) => _buildListItem(filtered[index]),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      childCount: filtered.length,
                      (context, index) => _buildGridItem(filtered[index]),
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72, // ✅ perfect ratio
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
