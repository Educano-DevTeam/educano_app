import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LegalDocumentPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  late final Future<String> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture = rootBundle.loadString(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: _documentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Não foi possível carregar o documento.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    );
                  }

                  final paragraphs = snapshot.data!.trim().split('\n\n');
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < paragraphs.length; i++) ...[
                              Text(
                                paragraphs[i],
                                style: TextStyle(
                                  fontSize: i == 0 ? 16 : 15,
                                  height: 1.6,
                                  fontWeight: i == 0
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                              if (i < paragraphs.length - 1)
                                const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
