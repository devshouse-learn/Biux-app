import 'dart:async';
import 'dart:convert';
import 'package:biux/config/colors.dart';
import 'package:biux/config/strings.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ConfirmPayment extends StatefulWidget {
  var url;

  ConfirmPayment(this.url);
  @override
  _ConfirmPaymentState createState() => _ConfirmPaymentState();
}

class _ConfirmPaymentState extends State<ConfirmPayment> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.vividPink,
        actions: <Widget>[
          SampleMenu(_controller.future),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            gestureNavigationEnabled: true,
          );
        },
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: AppStrings.toaster,
      onMessageReceived: (JavascriptMessage message) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    );
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController?>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController?> controller) {
        return PopupMenuButton<MenuOptions>(
          // onSelected: (MenuOptions value) {
          //   switch (value) {
          //     case MenuOptions.showUserAgent:
          //       _onShowUserAgent(controller!.data, context);
          //       break;
          //     case MenuOptions.listCookies:
          //       _onListCookies(controller.data, context);
          //       break;
          //     case MenuOptions.clearCookies:
          //       _onClearCookies(context);
          //       break;
          //     case MenuOptions.addToCache:
          //       _onAddToCache(controller.data, context);
          //       break;
          //     case MenuOptions.listCache:
          //       _onListCache(controller.data, context);
          //       break;
          //     case MenuOptions.clearCache:
          //       _onClearCache(controller.data, context);
          //       break;
          //   }
          // },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text(AppStrings.showUserAgent),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text(AppStrings.listCookies),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text(AppStrings.clearCookies),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text(AppStrings.addCache),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text(AppStrings.listCache),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text(AppStrings.clearCache),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        AppStrings.messageToaster);
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.evaluateJavascript(AppStrings.documentCookie);
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(AppStrings.cookies),
            _getCookieList(cookies),
          ],
        ),
      ),
    );
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        AppStrings.messageJavaScript);
    Scaffold.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.messageCache),
      ),
    );
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
      AppStrings.evaluateJavaScript,
    );
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    Scaffold.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.cacheCleared),
      ),
    );
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = AppStrings.message2;
    if (!hadCookies) {
      message = AppStrings.message3;
    }
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 = base64Encode(
      const Utf8Encoder().convert(
        AppStrings.kNavigationExamplePage,
      ),
    );
    await controller.loadUrl(
      AppStrings.loadurl(url: contentBase64),
    );
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets = cookieList.map(
      (String cookie) => Text(cookie),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}
