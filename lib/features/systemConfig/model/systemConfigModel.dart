class SystemConfigModel {
  late String systemTimezone;
  late String systemTimezoneGmt;
  late String appLink;
  late String moreApps;
  late String iosAppLink;
  late String iosMoreApps;
  late String referCoin;
  late String earnCoin;
  late String rewardCoin;
  late String appVersion;
  late String trueValue;
  late String falseValue;
  late String answerMode;
  late String languageMode;
  late String optionEMode;
  late String forceUpdate;
  late String dailyQuizMode;
  late String contestMode;
  late String fixQuestion;
  late String totalQuestion;
  late String shareappText;
  late String battleRandomCategoryMode;
  late String battleGroupCategoryMode;
  late String funNLearnMode;
  late String audioQuestionMode;
  late String guessTheWordMode;
  late String appVersionIos;
  late String adsEnabled;
  late String adsType;
  late String androidBannerId;
  late String androidInterstitialId;
  late String androidRewardedId;
  late String iosBannerId;
  late String iosInterstitialId;
  late String iosRewardedId;
  late String androidFbBannerId;
  late String androidFbInterstitialId;
  late String androidFbRewardedId;
  late String iosFbBannerId;
  late String iosFbInterstitialId;
  late String iosFbRewardedId;

  SystemConfigModel({
    required this.adsEnabled,
    required this.adsType,
    required this.androidBannerId,
    required this.androidInterstitialId,
    required this.androidRewardedId,
    required this.iosBannerId,
    required this.iosInterstitialId,
    required this.iosRewardedId,
    required this.systemTimezone,
    required this.systemTimezoneGmt,
    required this.appLink,
    required this.moreApps,
    required this.appVersionIos,
    required this.iosAppLink,
    required this.iosMoreApps,
    required this.referCoin,
    required this.earnCoin,
    required this.rewardCoin,
    required this.appVersion,
    required this.trueValue,
    required this.falseValue,
    required this.answerMode,
    required this.languageMode,
    required this.optionEMode,
    required this.forceUpdate,
    required this.dailyQuizMode,
    required this.contestMode,
    required this.fixQuestion,
    required this.totalQuestion,
    required this.shareappText,
    required this.battleRandomCategoryMode,
    required this.battleGroupCategoryMode,
    required this.audioQuestionMode,
    required this.funNLearnMode,
    required this.guessTheWordMode,
    required this.androidFbBannerId,
    required this.androidFbInterstitialId,
    required this.androidFbRewardedId,
    required this.iosFbBannerId,
    required this.iosFbInterstitialId,
    required this.iosFbRewardedId,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    systemTimezone = json['system_timezone'] ?? "";
    systemTimezoneGmt = json['system_timezone_gmt'] ?? "";
    appLink = json['app_link'] ?? "";
    moreApps = json['more_apps'] ?? "";
    iosAppLink = json['ios_app_link'] ?? "";
    iosMoreApps = json['ios_more_apps'] ?? "";
    referCoin = json['refer_coin'] ?? "";
    earnCoin = json['earn_coin'] ?? "";
    rewardCoin = json['reward_coin'] ?? "";
    appVersion = json['app_version'] ?? "";
    trueValue = json['true_value'] ?? "";
    falseValue = json['false_value'] ?? "";
    answerMode = json['answer_mode'] ?? "";
    languageMode = json['language_mode'] ?? "";
    optionEMode = json['option_e_mode'] ?? "";
    forceUpdate = json['force_update'] ?? "";
    dailyQuizMode = json['daily_quiz_mode'] ?? "";
    contestMode = json['contest_mode'] ?? "";
    fixQuestion = json['fix_question'] ?? "";
    totalQuestion = json['total_question'] ?? "";
    shareappText = json['shareapp_text'] ?? "";
    battleRandomCategoryMode = json['battle_random_category_mode'] ?? "";
    battleGroupCategoryMode = json['battle_group_category_mode'] ?? "";
    funNLearnMode = json['fun_n_learn_question'] ?? "";
    guessTheWordMode = json['guess_the_word_question'] ?? "";
    audioQuestionMode = json['audio_mode_question'] ?? "";
    appVersionIos = json['app_version_ios'] ?? "";
    adsEnabled = json['in_app_ads_mode'] ?? "";
    adsType = json['ads_type'] ?? "";
    androidBannerId = json['android_banner_id'] ?? "";
    androidInterstitialId = json['android_interstitial_id'] ?? "";
    androidRewardedId = json['android_rewarded_id'] ?? "";
    iosBannerId = json['ios_banner_id'] ?? "";
    iosInterstitialId = json['ios_interstitial_id'] ?? "";
    iosRewardedId = json['ios_rewarded_id'] ?? "";
    androidFbBannerId = json['android_fb_banner_id'] ?? "";
    androidFbInterstitialId = json['android_fb_interstitial_id'] ?? "";
    androidFbRewardedId = json['android_fb_rewarded_id'] ?? "";
    iosFbBannerId = json['ios_fb_banner_id'] ?? "";
    iosFbInterstitialId = json['ios_fb_interstitial_id'] ?? "";
    iosFbRewardedId = json['ios_fb_rewarded_id'] ?? "";
  }
}
