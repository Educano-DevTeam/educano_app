import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget buildRemotePdfFrame(String url, VoidCallback onLoad) =>
    HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final frame = element as web.HTMLIFrameElement;
        frame.title = 'Visualizador de PDF';
        frame.style
          ..setProperty('border', '0')
          ..setProperty('width', '100%')
          ..setProperty('height', '100%');
        frame.addEventListener('load', ((web.Event _) => onLoad()).toJS);
        frame.src = url;
      },
    );
