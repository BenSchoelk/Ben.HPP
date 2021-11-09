class SystemConfigModel {
  String? systemTimezone;
  String? systemTimezoneGmt;
  String? appLink;
  String? moreApps;
  String? iosAppLink;
  String? iosMoreApps;
  String? referCoin;
  String? earnCoin;
  String? rewardCoin;
  String? appVersion;
  String? trueValue;
  String? falseValue;
  String? answerMode;
  String? languageMode;
  String? optionEMode;
  String? forceUpdate;
  String? dailyQuizMode;
  String? contestMode;
  String? fixQuestion;
  String? totalQuestion;
  String? shareappText;
  String? battleRandomCategoryMode;
  String? battleGroupCategoryMode;
  String? funNLearnMode;
  String? audioQuestionMode;
  String? guessTheWordMode;
  String? appVersionIos;
  String? adsEnabled;
  String? adsType;
  String? androidBannerId;
  String? androidInterstitialId;
  String? androidRewardedId;
  String? iosBannerId;
  String? iosInterstitialId;
  String? iosRewardedId;
  String? androidFbBannerId;
  String? androidFbInterstitialId;
  String? androidFbRewardedId;
  String? iosFbBannerId;
  String? iosFbInterstitialId;
  String? iosFbRewardedId;

  SystemConfigModel({
    this.adsEnabled,
    this.adsType,
    this.androidBannerId,
    this.androidInterstitialId,
    this.androidRewardedId,
    this.iosBannerId,
    this.iosInterstitialId,
    this.iosRewardedId,
    this.systemTimezone,
    this.systemTimezoneGmt,
    this.appLink,
    this.moreApps,
    this.appVersionIos,
    this.iosAppLink,
    this.iosMoreApps,
    this.referCoin,
    this.earnCoin,
    this.rewardCoin,
    this.appVersion,
    this.trueValue,
    this.falseValue,
    this.answerMode,
    this.languageMode,
    this.optionEMode,
    this.forceUpdate,
    this.dailyQuizMode,
    this.contestMode,
    this.fixQuestion,
    this.totalQuestion,
    this.shareappText,
    this.battleRandomCategoryMode,
    this.battleGroupCategoryMode,
    this.audioQuestionMode,
    this.funNLearnMode,
    this.guessTheWordMode,
    this.androidFbBannerId,
    this.androidFbInterstitialId,
    this.androidFbRewardedId,
    this.iosFbBannerId,
    this.iosFbInterstitialId,
    this.iosFbRewardedId,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    systemTimezone = json['system_timezone'];
    systemTimezoneGmt = json['system_timezone_gmt'];
    appLink = json['app_link'];
    moreApps = json['more_apps'];
    iosAppLink = json['ios_app_link'];
    iosMoreApps = json['ios_more_apps'];
    referCoin = json['refer_coin'];
    earnCoin = json['earn_coin'];
    rewardCoin = json['reward_coin'];
    appVersion = json['app_version'];
    trueValue = json['true_value'];
    falseValue = json['false_value'];
    answerMode = json['answer_mode'];
    languageMode = json['language_mode'];
    optionEMode = json['option_e_mode'];
    forceUpdate = json['force_update'];
    dailyQuizMode = json['daily_quiz_mode'];
    contestMode = json['contest_mode'];
    fixQuestion = json['fix_question'];
    totalQuestion = json['total_question'];
    shareappText = json['shareapp_text'];
    battleRandomCategoryMode = json['battle_random_category_mode'];
    battleGroupCategoryMode = json['battle_group_category_mode'];
    funNLearnMode = json['fun_n_learn_question'];
    guessTheWordMode = json['guess_the_word_question'];
    audioQuestionMode = json['audio_mode_question'];
    appVersionIos = json['app_version_ios'];
    adsEnabled = json['in_app_ads_mode'];
    adsType = json['ads_type'];
    androidBannerId = json['android_banner_id'];
    androidInterstitialId = json['android_interstitial_id'];
    androidRewardedId = json['android_rewarded_id'];
    iosBannerId = json['ios_banner_id'];
    iosInterstitialId = json['ios_interstitial_id'];
    iosRewardedId = json['ios_rewarded_id'];
    //
    androidFbBannerId = json['android_fb_banner_id'];
    androidFbInterstitialId = json['android_fb_interstitial_id'];
    androidFbRewardedId = json['android_fb_rewarded_id'];
    iosFbBannerId = json['ios_fb_banner_id'];
    iosFbInterstitialId = json['ios_fb_interstitial_id'];
    iosFbRewardedId = json['ios_fb_rewarded_id'];
  }
}
