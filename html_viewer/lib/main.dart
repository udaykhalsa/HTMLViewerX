import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:file_saver/file_saver.dart';

// ============================================================================
// 1. CONFIGURATION & CONSTANTS
// ============================================================================

class AppConfig {
  static const String apiBaseUrl = ''; //Enter local API or dedicated server URL
  static const String telegramEndpoint = '/api/v1/telegram-updates/send-to-telegram/';
  static const String iframeViewType = 'html-preview-iframe';
}

class AppColors {
  static const Color primaryAccent = Color(0xFFED2B0C);
  static const Color bgLight = Color(0xFFF4F6F8);
  static const Color editorBg = Color(0xFF18181B);
  static const Color editorHeaderBg = Color(0xFF0F0F11);
  static const Color panelBorderLight = Color(0xFFE5E7EB);
  static const Color panelBorderDark = Color(0xFF27272A);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color editorText = Color(0xFFD4D4D8);
  static const Color divider = Color(0xFFD1D5DB);
}

enum ExportType { html, png, pdf }

// ============================================================================
// 2. TEMPLATES & SCRIPTS
// ============================================================================

class AppTemplates {
  static const String defaultHtml = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OneTrade Ultimate Template</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #ED2B0C;
            --text-dark: #1A1A1A;
            --text-grey: #5A5A5A;
            --glass-border: rgba(255, 255, 255, 0.8);
            --glass-bg: rgba(255, 255, 255, 0.75);
        }

        body {
            background-color: #1a1a1a;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            font-family: 'Montserrat', sans-serif;
            margin: 0;
            padding: 40px;
        }

        /* 1080x1350 CONTAINER */
        .post-container {
            width: 540px; 
            height: 675px; 
            background: #F2F4F8;
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: center; 
            align-items: center;
            box-shadow: 0 40px 80px rgba(0,0,0,0.4);
            transform: scale(1.5); 
            transform-origin: top center;
            margin-bottom: 300px;
        }

        /* --- BACKGROUND LAYERS --- */
        
        /* 1. The "Bullish" Glow */
        .glow-spot {
            position: absolute;
            top: -100px;
            right: -100px;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(237, 43, 12, 0.15) 0%, transparent 70%);
            filter: blur(50px);
            z-index: 1;
        }

        /* 2. The Candlestick Chart Pattern (SVG) */
        .chart-pattern {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0.6;
            z-index: 1;
            background-image: url("data:image/svg+xml,%3Csvg width='100' height='200' viewBox='0 0 100 200' xmlns='http://www.w3.org/2000/svg'%3E%3C!-- Candle 1 (Green/Hollow) --%3E%3Crect x='20' y='50' width='8' height='40' fill='none' stroke='%23D1D5DB' stroke-width='2'/%3E%3Cline x1='24' y1='30' x2='24' y2='50' stroke='%23D1D5DB' stroke-width='2'/%3E%3Cline x1='24' y1='90' x2='24' y2='110' stroke='%23D1D5DB' stroke-width='2'/%3E%3C!-- Candle 2 (Red/Filled) --%3E%3Crect x='60' y='80' width='8' height='30' fill='%23E5E7EB'/%3E%3Cline x1='64' y1='70' x2='64' y2='80' stroke='%23E5E7EB' stroke-width='2'/%3E%3Cline x1='64' y1='110' x2='64' y2='130' stroke='%23E5E7EB' stroke-width='2'/%3E%3C/svg%3E");
        }

        /* --- THE GLASS CARD --- */
        .glass-card {
            z-index: 10;
            width: 86%;
            height: 84%;
            background: var(--glass-bg);
            backdrop-filter: blur(30px) saturate(140%);
            -webkit-backdrop-filter: blur(30px) saturate(140%);
            
            border: 2px solid transparent;
            background-clip: padding-box;
            box-shadow: 0 20px 40px rgba(0,0,0,0.08);
            border-radius: 32px;
            
            padding: 40px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        .glass-card::after {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            border-radius: 32px;
            border: 1px solid rgba(255,255,255,0.8);
            pointer-events: none;
        }

        /* HEADER */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .brand-pill {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.8);
            padding: 6px 14px 6px 10px;
            border-radius: 100px;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .logo-mark { width: 20px; height: 20px; }
        .logo-mark path { stroke: var(--primary); } 
        
        .brand-text {
            font-weight: 800;
            font-size: 14px;
            color: var(--text-dark);
            letter-spacing: -0.5px;
            text-transform: uppercase;
        }

        .date-badge {
            font-size: 10px;
            font-weight: 700;
            color: #999;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        /* CONTENT */
        .fact-content {
            margin-top: 30px;
            margin-bottom: auto;
        }
        
        .fact-label {
            font-size: 11px;
            font-weight: 700;
            color: var(--primary);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 16px;
            display: block;
        }

        .headline {
            font-size: 40px; 
            font-weight: 900; 
            color: var(--text-dark);
            line-height: 1.1;
            margin-bottom: 24px;
            letter-spacing: -1.5px;
            outline: none;
        }

        .description {
            font-size: 16px;
            font-weight: 500;
            color: var(--text-grey);
            line-height: 1.7;
            outline: none;
            border-left: 3px solid rgba(0,0,0,0.1);
            padding-left: 20px;
        }

        /* FOOTER */
        .footer-row {
            padding-top: 30px;
            border-top: 1px solid rgba(0,0,0,0.06);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .footer-text {
            font-size: 11px;
            font-weight: 600;
            color: #888;
        }

        /* STORE BUTTONS */
        .store-buttons {
            display: flex;
            gap: 10px;
        }
        
        .store-btn {
            background: #111;
            height: 32px;
            padding: 0 14px;
            border-radius: 100px;
            display: flex;
            align-items: center;
            gap: 6px;
            color: white;
            text-decoration: none;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .store-btn:hover {
            transform: translateY(-2px);
            background: var(--primary); 
        }
        
        .store-btn svg {
            fill: white;
            width: 14px;
            height: 14px;
        }
        
        .store-btn span {
            font-size: 10px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <div class="post-container">
        <div class="glow-spot"></div>
        <div class="chart-pattern"></div>

        <div class="glass-card">
            
            <div class="header">
                <div class="brand-pill">
                    <div class="logo-mark">
                       <svg viewBox="0 0 100 100" fill="none">
                           <path d="M10 20 H40 V80" stroke="#ED2B0C" stroke-width="16" stroke-linecap="square"/>
                           <path d="M60 20 H90" stroke="#ED2B0C" stroke-width="16" stroke-linecap="square"/>
                           <path d="M40 80 L60 50 L80 80" stroke="#ED2B0C" stroke-width="12" stroke-linejoin="round"/> 
                           <path d="M50 40 L90 10" stroke="#ED2B0C" stroke-width="12" marker-end="url(#arrow)"/>
                       </svg>
                    </div>
                    <div class="brand-text">OneTrade</div>
                </div>
                <div class="date-badge" contenteditable="true">FACT #044</div>
            </div>

            <div class="fact-content">
                <span class="fact-label">Market History</span>
                <div class="headline" contenteditable="true">
                    The BSE is the<br>
                    oldest exchange<br>
                    in all of Asia.
                </div>
                <div class="description" contenteditable="true">
                    Established in 1875 as "The Native Share & Stock Brokers' Association," the Bombay Stock Exchange predates the Tokyo Stock Exchange by 3 years.
                </div>
            </div>

            <div class="footer-row">
                <div class="footer-text">
                    Coming Soon to
                </div>
                <div class="store-buttons">
                    <div class="store-btn">
                        <svg viewBox="0 0 384 512"><path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 75.6c13.5 35.6 52.1 123 94.5 121.7 18.2-.3 39-16 59.5-16.2 19.3-.2 41.3 16.7 66.9 16.2 38.6-.8 70-52.5 90.7-88.1 12.8-21.6 17.8-37.4 18.2-38.3l-.2-.3c-41.5-18.1-68.9-57.8-69.3-95.5zm-53-157.9c16.3-17.6 28.5-44.1 24.3-71.8-25.2 1.4-53.1 15.6-70.1 34-15 15.4-28.7 41.5-24.6 69.1 27.2 2.6 55-12.7 70.4-31.3z"/></svg>
                        <span>App Store</span>
                    </div>
                    <div class="store-btn">
                        <svg viewBox="0 0 512 512"><path d="M325.3 234.3L104.6 13l280.8 161.2-60.1 60.1zM47 0C34 6.8 25.3 19.2 25.3 35.3v441.3c0 16.1 8.7 28.5 21.7 35.3l256.6-256L47 0zm425.2 225.6l-58.9-34.1-65.7 64.5 65.7 64.5 60.1-34.1c18-14.3 18-46.5-1.2-60.8zM104.6 499l280.8-161.2-60.1-60.1L104.6 499z"/></svg>
                        <span>Google Play</span>
                    </div>
                </div>
            </div>
        
        </div>
    </div>

</body>
</html>
''';
}

class AppScripts {
  static const String html2CanvasInjection = r'''
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script>
  var currentScale = 1.0;
  
  function getZoomableElements() {
     var elements = [];
     var children = document.body.children;
     for (var i = 0; i < children.length; i++) {
         if (children[i].tagName !== 'SCRIPT' && children[i].tagName !== 'STYLE' && !children[i].id.includes('html2canvas')) {
             elements.push(children[i]);
         }
     }
     return elements;
  }

  function applyZoom(scale) {
    currentScale = scale;
    var elements = getZoomableElements();
    for (var i = 0; i < elements.length; i++) {
        elements[i].style.zoom = scale;
    }
  }

  function fitToWidth() {
    applyZoom(1.0);
    setTimeout(function() {
      var elements = getZoomableElements();
      var maxWidth = 0;
      for (var i = 0; i < elements.length; i++) {
         var rect = elements[i].getBoundingClientRect();
         if (rect.width > maxWidth) maxWidth = rect.width;
      }
      if (maxWidth === 0) maxWidth = Math.max(document.body.scrollWidth, document.documentElement.scrollWidth);
      var viewWidth = window.innerWidth;
      var padding = 40; 
      var scale = (maxWidth > 0) ? Math.min(1.0, (viewWidth - padding) / maxWidth) : 1.0;
      applyZoom(scale);
      window.parent.postMessage(JSON.stringify({ type: 'zoom_info', scale: scale }), '*');
    }, 50);
  }

  window.addEventListener('load', function () {
    if (document.fonts) { document.fonts.ready.then(function() { setTimeout(fitToWidth, 100); }); } 
    else { setTimeout(fitToWidth, 150); }
  });

  window.addEventListener('resize', function() {
      clearTimeout(window.resizeTimer);
      window.resizeTimer = setTimeout(fitToWidth, 200);
  });

  window.addEventListener('message', function (event) {
    var raw  = event.data;
    var data = raw;
    if (typeof raw === 'string') { try { data = JSON.parse(raw); } catch (e) { data = raw; } }

    if (data === 'request_export') {
      var savedScale = currentScale;
      applyZoom(1); 
      
      var targetElement = document.querySelector('.container, .post-container') || document.body;
      
      var fixStyle = document.createElement('style');
      fixStyle.id = 'export-transform-fix';
      fixStyle.innerHTML = `
        body > * { transform: none !important; }
        .container, .post-container { 
            transform: none !important; 
            margin: 0 !important; 
            box-shadow: none !important; 
        } 
        body, html { 
            margin: 0 !important; 
            padding: 0 !important; 
            align-items: flex-start !important; 
            justify-content: flex-start !important; 
            overflow: visible !important;
        }
      `;
      document.head.appendChild(fixStyle);

      setTimeout(function () {
        html2canvas(targetElement, {
          useCORS: true,
          allowTaint: true,
          backgroundColor: targetElement === document.body ? null : window.getComputedStyle(targetElement).backgroundColor,
          scale: 2, 
          scrollX: 0,
          scrollY: 0,
          logging: false
        }).then(function (canvas) {
          window.parent.postMessage(JSON.stringify({ type: 'export_result', dataUrl: canvas.toDataURL('image/png') }), '*');
          restoreStyles();
        }).catch(function (err) {
          window.parent.postMessage(JSON.stringify({ type: 'export_error', error: err.toString() }), '*');
          restoreStyles();
        });
        
        function restoreStyles() {
            var fixEl = document.getElementById('export-transform-fix');
            if (fixEl) fixEl.remove();
            applyZoom(savedScale);
        }
      }, 350); 

    } else if (data && data.type === 'set_zoom') {
      applyZoom(data.scale);
      window.parent.postMessage(JSON.stringify({ type: 'zoom_info', scale: data.scale }), '*');
    } else if (data && data.type === 'fit_width') {
      fitToWidth();
    }
  });
</script>
''';
}

// ============================================================================
// 3. UTILITIES & SERVICES
// ============================================================================

class HtmlCompiler {
  static String wrapHtml(String rawUserContent) {
    if (RegExp(r'</body>', caseSensitive: false).hasMatch(rawUserContent)) {
      return rawUserContent.replaceFirst(
        RegExp(r'</body>', caseSensitive: false),
        '\n${AppScripts.html2CanvasInjection}\n</body>',
      );
    } else if (RegExp(
      r'</head>',
      caseSensitive: false,
    ).hasMatch(rawUserContent)) {
      return rawUserContent.replaceFirst(
        RegExp(r'</head>', caseSensitive: false),
        '\n${AppScripts.html2CanvasInjection}\n</head>',
      );
    } else {
      return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  ${AppScripts.html2CanvasInjection}
</head>
<body style="margin: 0; padding: 24px; background-color: #ffffff; overflow: auto; font-family: system-ui, sans-serif;">
  <div id="export-wrapper">
    $rawUserContent
  </div>
</body>
</html>
''';
    }
  }
}

class PdfService {
  static Future<Uint8List> generateDynamicPdf(Uint8List imageBytes) async {
    final ui.Image decodedImage = await decodeImageFromList(imageBytes);
    final double imgWidth = decodedImage.width.toDouble();
    final double imgHeight = decodedImage.height.toDouble();
    decodedImage.dispose();

    final pdf = pw.Document(compress: false);
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(imgWidth, imgHeight),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context ctx) => pw.Image(image, fit: pw.BoxFit.fill),
      ),
    );

    await Future.delayed(Duration.zero);
    return await pdf.save();
  }
}

// ============================================================================
// 4. GLOBALS & ENTRY POINT
// ============================================================================

final web.HTMLIFrameElement _iframeElement = web.HTMLIFrameElement()
  ..style.width = '100%'
  ..style.height = '100%'
  ..style.border = 'none'
  ..style.borderRadius = '0 0 12px 12px';

bool _iframeRegistered = false;

void _ensureIframeRegistered() {
  if (_iframeRegistered) return;
  _iframeRegistered = true;
  ui_web.platformViewRegistry.registerViewFactory(
    AppConfig.iframeViewType,
    (int viewId) => _iframeElement,
  );
}

void main() {
  runApp(const WebHtmlEditorApp());
}

class WebHtmlEditorApp extends StatelessWidget {
  const WebHtmlEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryAccent,
          primary: AppColors.primaryAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.bgLight,
        fontFamily: 'Inter',
      ),
      home: const WebHtmlEditorScreen(),
    );
  }
}

// ============================================================================
// 5. MAIN SCREEN (STATE MANAGEMENT)
// ============================================================================

class WebHtmlEditorScreen extends StatefulWidget {
  const WebHtmlEditorScreen({super.key});

  @override
  State<WebHtmlEditorScreen> createState() => _WebHtmlEditorScreenState();
}

class _WebHtmlEditorScreenState extends State<WebHtmlEditorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _htmlContent = AppTemplates.defaultHtml;
  double _previewZoomLevel = 1.0;
  bool _isExporting = false;
  bool _isSendingToTelegram = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Completer<Uint8List>? _exportCompleter;
  late StreamSubscription<web.MessageEvent> _messageSubscription;
  Timer? _debounceTimer;

  bool get _isProcessing => _isExporting || _isSendingToTelegram;

  @override
  void initState() {
    super.initState();
    _ensureIframeRegistered();
    _textController.text = _htmlContent;
    _setupIframeCommunication();

    _iframeElement.setAttribute('srcdoc', HtmlCompiler.wrapHtml(_htmlContent));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupIframeCommunication() {
    _messageSubscription = web.window.onMessage.listen((
      web.MessageEvent event,
    ) {
      // Convert the incoming JavaScript data to a Dart object
      final dartData = event.data.dartify();

      if (dartData is String) {
        try {
          final Map<String, dynamic> data = jsonDecode(dartData);
          if (data['type'] == 'export_result') {
            final String dataUrl = data['dataUrl'];
            final Uint8List bytes = base64Decode(dataUrl.split(',').last);
            _exportCompleter?.complete(bytes);
          } else if (data['type'] == 'export_error') {
            _exportCompleter?.completeError(data['error']);
          } else if (data['type'] == 'zoom_info' && mounted) {
            setState(
              () => _previewZoomLevel = (data['scale'] as num).toDouble(),
            );
          }
        } catch (_) {}
      }
    });
  }

  void _postIframeMessage(Map<String, dynamic> message) {
    // Convert Dart strings to JS strings using .toJS
    _iframeElement.contentWindow?.postMessage(
      jsonEncode(message).toJS,
      '*'.toJS,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _messageSubscription.cancel();
    super.dispose();
  }

  void _zoomIn() => _postIframeMessage({
    'type': 'set_zoom',
    'scale': (_previewZoomLevel * 1.25).clamp(0.05, 5.0),
  });
  void _zoomOut() => _postIframeMessage({
    'type': 'set_zoom',
    'scale': (_previewZoomLevel / 1.25).clamp(0.05, 5.0),
  });
  void _fitToWidth() => _postIframeMessage({'type': 'fit_width'});

  void _updatePreview(String value) {
    setState(() => _htmlContent = value);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _iframeElement.setAttribute(
        'srcdoc',
        HtmlCompiler.wrapHtml(_htmlContent),
      );
    });
  }

  Future<void> _exportFile(ExportType type) async {
    setState(() => _isExporting = true);
    try {
      if (type == ExportType.html) {
        final bytes = Uint8List.fromList(utf8.encode(_htmlContent));
        await FileSaver.instance.saveFile(
          name: 'Studio_Export',
          bytes: bytes,
          fileExtension: 'html',
          mimeType: MimeType.other,
        );
        _showSnackBar('HTML file downloaded!');
      } else {
        _exportCompleter = Completer<Uint8List>();
        _iframeElement.contentWindow?.postMessage('request_export'.toJS, '*'.toJS);
        final Uint8List imageBytes = await _exportCompleter!.future;

        if (type == ExportType.png) {
          await FileSaver.instance.saveFile(
            name: 'Studio_Export',
            bytes: imageBytes,
            fileExtension: 'png',
            mimeType: MimeType.png,
          );
          _showSnackBar('PNG Image downloaded!');
        } else if (type == ExportType.pdf) {
          final Uint8List pdfBytes = await PdfService.generateDynamicPdf(
            imageBytes,
          );
          await FileSaver.instance.saveFile(
            name: 'Studio_Export',
            bytes: pdfBytes,
            fileExtension: 'pdf',
            mimeType: MimeType.pdf,
          );
          _showSnackBar('Rendered PDF downloaded!');
        }
      }
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    } finally {
      _exportCompleter = null;
      setState(() => _isExporting = false);
    }
  }

  Future<void> _sendToTelegram(ExportType type) async {
    if (type == ExportType.html) return;
    setState(() => _isSendingToTelegram = true);

    try {
      _exportCompleter = Completer<Uint8List>();
      _iframeElement.contentWindow?.postMessage('request_export'.toJS, '*'.toJS);
      final Uint8List imageBytes = await _exportCompleter!.future;

      final bool isPdf = type == ExportType.pdf;
      final Uint8List uploadBytes = isPdf
          ? await PdfService.generateDynamicPdf(imageBytes)
          : imageBytes;
      final String filename = isPdf ? 'studio_export.pdf' : 'studio_export.png';

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(uploadBytes, filename: filename),
      });

      final response = await Dio().post(
        '${AppConfig.apiBaseUrl}${AppConfig.telegramEndpoint}',
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        _showSnackBar(
          '🚀 ${response.data['message'] ?? 'Successfully forwarded to Telegram!'}',
        );
      } else {
        _showSnackBar(
          '⚠️ Unexpected response format from server.',
          isError: true,
        );
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData != null) {
        _showSnackBar(
          '❌ ${errorData['error'] ?? 'Server Error'}: ${errorData['message'] ?? 'Something went wrong.'}',
          isError: true,
        );
      } else {
        _showSnackBar(
          '🔌 Network Error: Could not connect to the server.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('⚠️ Processing Error: $e', isError: true);
    } finally {
      _exportCompleter = null;
      setState(() => _isSendingToTelegram = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(24),
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isProcessing: _isProcessing,
        pulseAnimation: _pulseAnimation,
        onExport: _exportFile,
        onSendTelegram: _sendToTelegram,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final children = [
                Expanded(
                  flex: 1,
                  child: EditorPanel(
                    textController: _textController,
                    scrollController: _scrollController,
                    onChanged: _updatePreview,
                  ),
                ),
                SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 24),
                Expanded(
                  flex: 1,
                  child: PreviewPanel(
                    zoomLevel: _previewZoomLevel,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onFitWidth: _fitToWidth,
                  ),
                ),
              ];
              return isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. REUSABLE UI COMPONENTS
// ============================================================================

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isProcessing;
  final Animation<double> pulseAnimation;
  final Function(ExportType) onExport;
  final Function(ExportType) onSendTelegram;

  const CustomAppBar({
    super.key,
    required this.isProcessing,
    required this.pulseAnimation,
    required this.onExport,
    required this.onSendTelegram,
  });

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(color: AppColors.panelBorderLight, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAppIcon(),
          const SizedBox(width: 16),
          const Text(
            'HTML Studio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _buildLoader(),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LocalActionsGroup(
                    isProcessing: isProcessing,
                    onExport: onExport,
                  ),
                  const SizedBox(width: 20),
                  _CloudActionsGroup(
                    isProcessing: isProcessing,
                    pulseAnimation: pulseAnimation,
                    onSendTelegram: onSendTelegram,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAccent,
            AppColors.primaryAccent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.code_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _buildLoader() {
    return AnimatedOpacity(
      opacity: isProcessing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: const Padding(
        padding: EdgeInsets.only(right: 24),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.primaryAccent,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}

class _LocalActionsGroup extends StatelessWidget {
  final bool isProcessing;
  final Function(ExportType) onExport;

  const _LocalActionsGroup({
    required this.isProcessing,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'text': 'HTML', 'icon': Icons.code, 'type': ExportType.html},
      {'text': 'PNG', 'icon': Icons.image_outlined, 'type': ExportType.png},
      {
        'text': 'PDF',
        'icon': Icons.picture_as_pdf_rounded,
        'type': ExportType.pdf,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.panelBorderLight),
      ),
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final isLast = entry.key == actions.length - 1;
          final action = entry.value;
          return Row(
            children: [
              Opacity(
                opacity: isProcessing ? 0.6 : 1.0,
                child: AnimatedModernButton(
                  text: action['text'] as String,
                  icon: action['icon'] as IconData,
                  isPrimary: false,
                  onTap: isProcessing
                      ? null
                      : () => onExport(action['type'] as ExportType),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 20,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CloudActionsGroup extends StatelessWidget {
  final bool isProcessing;
  final Animation<double> pulseAnimation;
  final Function(ExportType) onSendTelegram;

  const _CloudActionsGroup({
    required this.isProcessing,
    required this.pulseAnimation,
    required this.onSendTelegram,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (!isProcessing)
              BoxShadow(
                color: AppColors.primaryAccent.withValues(alpha: 0.15),
                blurRadius: pulseAnimation.value * 2,
                spreadRadius: pulseAnimation.value / 3,
              ),
          ],
        ),
        child: child,
      ),
      child: Opacity(
        opacity: isProcessing ? 0.6 : 1.0,
        child: Row(
          children: [
            AnimatedModernButton(
              text: 'Send PNG',
              icon: Icons.telegram,
              isPrimary: true,
              onTap: isProcessing ? null : () => onSendTelegram(ExportType.png),
            ),
            const SizedBox(width: 10),
            AnimatedModernButton(
              text: 'Send PDF',
              icon: Icons.telegram,
              isPrimary: true,
              onTap: isProcessing ? null : () => onSendTelegram(ExportType.pdf),
            ),
          ],
        ),
      ),
    );
  }
}

class EditorPanel extends StatelessWidget {
  final TextEditingController textController;
  final ScrollController scrollController;
  final ValueChanged<String> onChanged;

  const EditorPanel({
    super.key,
    required this.textController,
    required this.scrollController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PanelContainer(
      title: 'index.html',
      icon: Icons.code_rounded,
      isDark: true,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: TextField(
          controller: textController,
          scrollController: scrollController,
          maxLines: null,
          expands: true,
          style: const TextStyle(
            color: AppColors.editorText,
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.6,
            letterSpacing: 0.2,
          ),
          cursorColor: AppColors.primaryAccent,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Type your HTML...',
            hintStyle: TextStyle(color: Colors.white38),
            contentPadding: EdgeInsets.only(right: 16),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class PreviewPanel extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitWidth;

  const PreviewPanel({
    super.key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitWidth,
  });

  @override
  Widget build(BuildContext context) {
    return PanelContainer(
      title: 'Live Render',
      icon: Icons.monitor_rounded,
      isDark: false,
      isBrowser: true,
      trailing: _ZoomControls(
        zoomLevel: zoomLevel,
        onZoomIn: onZoomIn,
        onZoomOut: onZoomOut,
        onFitWidth: onFitWidth,
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: HtmlElementView(viewType: AppConfig.iframeViewType),
      ),
    );
  }
}

class PanelContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final bool isDark;
  final bool isBrowser;

  const PanelContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.isDark = false,
    this.isBrowser = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.editorBg : Colors.white;
    final headerColor = isDark
        ? AppColors.editorHeaderBg
        : const Color(0xFFFAFAFA);
    final titleColor = isDark ? const Color(0xFFA1A1AA) : AppColors.textMuted;
    final borderColor = isDark
        ? AppColors.panelBorderDark
        : AppColors.panelBorderLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                if (isBrowser) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 5.5,
                        backgroundColor: Colors.red.shade400,
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 5.5,
                        backgroundColor: Colors.amber.shade400,
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 5.5,
                        backgroundColor: Colors.green.shade400,
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ] else ...[
                  Icon(
                    icon,
                    color: isDark
                        ? const Color(0xFF71717A)
                        : AppColors.primaryAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
                if (trailing != null) ...[const Spacer(), trailing!],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: isDark ? const EdgeInsets.all(16.0) : EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitWidth;

  const _ZoomControls({
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.panelBorderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZoomIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Zoom out',
            onTap: onZoomOut,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${(zoomLevel * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          ZoomIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Zoom in',
            onTap: onZoomIn,
          ),
          Container(
            width: 1,
            height: 14,
            color: AppColors.divider,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          ZoomIconButton(
            icon: Icons.fit_screen_rounded,
            tooltip: 'Fit to width',
            onTap: onFitWidth,
          ),
        ],
      ),
    );
  }
}

class ZoomIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const ZoomIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<ZoomIconButton> createState() => _ZoomIconButtonState();
}

class _ZoomIconButtonState extends State<ZoomIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _hovered
                  ? Colors.black.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedModernButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  const AnimatedModernButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isPrimary,
    this.onTap,
  });

  @override
  State<AnimatedModernButton> createState() => _AnimatedModernButtonState();
}

class _AnimatedModernButtonState extends State<AnimatedModernButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isPrimary
        ? AppColors.primaryAccent
        : Colors.transparent;
    final Color textColor = widget.isPrimary
        ? Colors.white
        : const Color(0xFF374151);
    final Color hoverBgColor = widget.isPrimary
        ? AppColors.primaryAccent.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.03);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered && widget.onTap != null ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered && widget.onTap != null
                  ? hoverBgColor
                  : bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: textColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
