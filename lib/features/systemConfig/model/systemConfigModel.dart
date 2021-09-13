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

  SystemConfigModel(
      {this.systemTimezone,
      this.systemTimezoneGmt,
      this.appLink,
      this.moreApps,
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
      this.battleGroupCategoryMode});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['system_timezone'] = this.systemTimezone;
    data['system_timezone_gmt'] = this.systemTimezoneGmt;
    data['app_link'] = this.appLink;
    data['more_apps'] = this.moreApps;
    data['ios_app_link'] = this.iosAppLink;
    data['ios_more_apps'] = this.iosMoreApps;
    data['refer_coin'] = this.referCoin;
    data['earn_coin'] = this.earnCoin;
    data['reward_coin'] = this.rewardCoin;
    data['app_version'] = this.appVersion;
    data['true_value'] = this.trueValue;
    data['false_value'] = this.falseValue;
    data['answer_mode'] = this.answerMode;
    data['language_mode'] = this.languageMode;
    data['option_e_mode'] = this.optionEMode;
    data['force_update'] = this.forceUpdate;
    data['daily_quiz_mode'] = this.dailyQuizMode;
    data['contest_mode'] = this.contestMode;
    data['fix_question'] = this.fixQuestion;
    data['total_question'] = this.totalQuestion;
    data['shareapp_text'] = this.shareappText;
    data['battle_random_category_mode'] = this.battleRandomCategoryMode;
    data['battle_group_category_mode'] = this.battleGroupCategoryMode;
    return data;
  }
}
