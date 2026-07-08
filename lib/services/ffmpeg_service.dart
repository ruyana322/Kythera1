// lib/services/ffmpeg_service.dart
//
// Semua operasi FFmpeg dikumpulkan di sini.
// UI layer hanya memanggil method ini — zero FFmpeg code di screens.
//
import 'dart:io';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';

// ─── Result type ─────────────────────────────────────────────────────────────
class FfmpegResult {
  final bool success;
  final String outputPath;
  final String? errorMessage;

  const FfmpegResult({
    required this.success,
    this.outputPath = '',
    this.errorMessage,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────
class FfmpegService {
  // Dapatkan path temp output di external files dir
  Future<String> _tempPath(String filename) async {
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    return '${dir.path}/$filename';
  }

  // ─── 1. CONVERTER ────────────────────────────────────────────────────────
  // Konversi format video dengan kontrol bitrate.
  // -ignore_unknown wajib ada sebagai safeguard stream asing.
  Future<FfmpegResult> convertVideo({
    required String inputPath,
    required String targetFormat, // 'mp4', 'mkv', 'avi', dll
    required int bitrateM,        // dalam Mbps
    required String codec,        // 'libx264', 'libx265', 'libvpx-vp9', 'libaom-av1'
    required String resolution,   // 'original', '1920x1080', '1280x720', dll
    void Function(double progress)? onProgress,
  }) async {
    final outputPath = await _tempPath(
        'Kythera_Convert_${DateTime.now().millisecondsSinceEpoch}.$targetFormat');

    // Scale filter jika bukan original
    final scaleFilter = resolution == 'original'
        ? ''
        : '-vf "scale=$resolution:flags=lanczos"';

    final cmd = [
      '-y',
      '-ignore_unknown',        // ← safeguard wajib
      '-i "$inputPath"',
      scaleFilter,
      '-c:v $codec',
      '-b:v ${bitrateM}M',
      '-c:a aac',
      '-b:a 192k',
      '-movflags +faststart',
      '"$outputPath"',
    ].where((e) => e.isNotEmpty).join(' ');

    return _execute(cmd, outputPath, onProgress);
  }

  // ─── 2. COMPRESS ─────────────────────────────────────────────────────────
  // Kompresi dengan target CRF — makin tinggi CRF = makin kecil file.
  // 30% compress → CRF 23, 60% → CRF 28, 85% → CRF 35
  Future<FfmpegResult> compressVideo({
    required String inputPath,
    required int compressPercent, // 30, 60, 85
    required bool compressAudio,
    required bool removeMetadata,
    required bool twoPass,
    void Function(double progress)? onProgress,
  }) async {
    final outputPath = await _tempPath(
        'Kythera_Compress_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final crf = compressPercent == 30
        ? 23
        : compressPercent == 60
            ? 28
            : 35;

    final audioArgs = compressAudio ? '-c:a aac -b:a 128k' : '-c:a copy';
    final metaArgs  = removeMetadata ? '-map_metadata -1' : '';

    if (twoPass) {
      // Pass 1
      final pass1 = '-y -ignore_unknown -i "$inputPath" '
          '-c:v libx264 -crf $crf -b:v 0 -pass 1 -an '
          '$metaArgs -f mp4 /dev/null';

      final res1 = await _execute(pass1, '', onProgress);
      if (!res1.success) return res1;

      // Pass 2
      final pass2 = '-y -ignore_unknown -i "$inputPath" '
          '-c:v libx264 -crf $crf -b:v 0 -pass 2 '
          '$audioArgs $metaArgs -movflags +faststart "$outputPath"';

      return _execute(pass2, outputPath, onProgress);
    } else {
      final cmd = '-y -ignore_unknown -i "$inputPath" '
          '-c:v libx264 -crf $crf $audioArgs $metaArgs '
          '-movflags +faststart "$outputPath"';

      return _execute(cmd, outputPath, onProgress);
    }
  }

  // ─── 3. PATCH METADATA ───────────────────────────────────────────────────
  // Patch metadata container tanpa re-encode (-c copy).
  Future<FfmpegResult> patchMetadata({
    required String inputPath,
    required String title,
    required String description,
    required String author,
    required String year,
    void Function(double progress)? onProgress,
  }) async {
    final outputPath = await _tempPath(
        'Kythera_Patch_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final metaTitle   = title.isNotEmpty       ? '-metadata title="$title"'              : '';
    final metaDesc    = description.isNotEmpty  ? '-metadata description="$description"'  : '';
    final metaAuthor  = author.isNotEmpty       ? '-metadata artist="$author"'            : '';
    final metaYear    = year.isNotEmpty         ? '-metadata date="$year"'                : '';

    final cmd = [
      '-y',
      '-ignore_unknown',
      '-i "$inputPath"',
      '-c copy',
      metaTitle,
      metaDesc,
      metaAuthor,
      metaYear,
      '-movflags +faststart',
      '"$outputPath"',
    ].where((e) => e.isNotEmpty).join(' ');

    return _execute(cmd, outputPath, onProgress);
  }

  // ─── 4. PATCH WATERMARK ──────────────────────────────────────────────────
  Future<FfmpegResult> patchWatermark({
    required String inputPath,
    required String watermarkText,
    void Function(double progress)? onProgress,
  }) async {
    final outputPath = await _tempPath(
        'Kythera_WM_${DateTime.now().millisecondsSinceEpoch}.mp4');

    // drawtext filter — posisi kanan bawah
    final cmd = '-y -ignore_unknown -i "$inputPath" '
        '-vf "drawtext=text=\'$watermarkText\':fontcolor=white@0.6:'
        'fontsize=28:x=w-tw-20:y=h-th-20:shadowcolor=black:shadowx=1:shadowy=1" '
        '-c:a copy -movflags +faststart "$outputPath"';

    return _execute(cmd, outputPath, onProgress);
  }

  // ─── Internal executor ───────────────────────────────────────────────────
  Future<FfmpegResult> _execute(
    String cmd,
    String outputPath,
    void Function(double progress)? onProgress,
  ) async {
    // Enable statistics callback untuk progress (optional)
    FFmpegKitConfig.enableStatisticsCallback((stats) {
      // time dalam milidetik — butuh durasi total untuk % akurat
      // Cukup kirim sebagai sinyal "masih jalan"
      onProgress?.call(-1); // -1 = indeterminate
    });

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    FFmpegKitConfig.disableStatistics();

    if (ReturnCode.isSuccess(returnCode)) {
      return FfmpegResult(success: true, outputPath: outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      final tail = (logs != null && logs.length > 120)
          ? logs.substring(logs.length - 120)
          : logs ?? 'No logs';
      return FfmpegResult(success: false, errorMessage: tail);
    }
  }

  // ─── Util: mime type dari extension ──────────────────────────────────────
  static String mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'mkv':  return 'video/x-matroska';
      case 'avi':  return 'video/x-msvideo';
      case 'gif':  return 'image/gif';
      case 'mov':  return 'video/quicktime';
      case 'webm': return 'video/webm';
      default:     return 'video/mp4';
    }
  }

  // ─── Util: format ukuran file ─────────────────────────────────────────────
  static String formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
