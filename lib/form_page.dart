import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'l10n/app_localizations.dart';

class FormPage extends StatefulWidget {
  final String formUrl;

  const FormPage({super.key, required this.formUrl});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late final WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Only initialize the WebView controller if we are NOT on the web
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.formUrl));
    } else {
      _controller = null;
    }
  }

  Future<void> _launchInBrowser() async {
    final Uri uri = Uri.parse(widget.formUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If running on Web, show a clean button to open the form in a new tab
    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_document, size: 64, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.intakeTopMessage,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.clickOpenNewTab,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _launchInBrowser,
                icon: const Icon(Icons.open_in_new),
                label: Text(AppLocalizations.of(context)!.openFormNewTab),
              ),
            ],
          ),
        ),
      );
    }

    // If running on Android, iOS, or Windows, embed the WebView natively
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.intakeTopMessage),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}