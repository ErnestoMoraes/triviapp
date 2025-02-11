import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  AdMobBannerWidgetState createState() => AdMobBannerWidgetState();
}

class AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741', //ID de teste da Admob
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
          log('Ad carregado!');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          log('Falha ao carregar o banner: $error');
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
