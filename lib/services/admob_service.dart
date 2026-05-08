import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static final AdmobService _instance = AdmobService._internal();
  factory AdmobService() => _instance;
  AdmobService._internal();

  // Test ad unit IDs (replace with real IDs for production)
  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _bannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _rewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _rewardedAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _bannerAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _bannerAdUnitIdIos;
    }
    return _bannerAdUnitIdAndroid;
  }

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _rewardedAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _rewardedAdUnitIdIos;
    }
    return _rewardedAdUnitIdAndroid;
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
        },
      ),
    );
  }

  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
    return rewardedAd;
  }

  Future<bool> showRewardedAd({
    required Function(int points) onRewarded,
  }) async {
    final ad = await loadRewardedAd();
    if (ad == null) return false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        debugPrint('Rewarded ad failed to show: $error');
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(15); // 15 PawPoints for watching ad
      },
    );
    return true;
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = AdmobService().createBannerAd();
    ad.load().then((_) {
      if (mounted) {
        setState(() {
          _bannerAd = ad;
          _isLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
