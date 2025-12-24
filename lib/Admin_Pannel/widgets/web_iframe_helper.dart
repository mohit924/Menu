// Only for web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

void registerDriveIframe(String viewId, String fileId) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) => html.IFrameElement()
      ..src = "https://drive.google.com/file/d/$fileId/preview"
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%',
  );
}
