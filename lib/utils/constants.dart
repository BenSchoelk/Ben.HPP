final String appName = "Elite Quiz";
final String packageName = "com.wrteam.flutterquiz";

//supporated language codes
//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
final List<String> supporatedLocales = ['en', 'hi', 'ur'];
//
final String defaultLanguageCode = 'en';

//Enter 2 Letter ISO Code of country
//It will be use for phone auth.
final String initialSelectedCountryCode = 'IN';

//Hive all boxes name
final String authBox = "auth";
final String settingsBox = "settings";
final String bookmarkBox = "bookmark";
final String userdetailsBox = "userdetails";

//authBox keys
final String isLoginKey = "isLogin";
final String jwtTokenKey = "jwtToken";
final String firebaseIdBoxKey = "firebaseId";
final String authTypeKey = "authType";
final String isNewUserKey = "isNewUser";

//userBox keys
final String nameBoxKey = "name";
final String userUIdBoxKey = "userUID";
final String emailBoxKey = "email";
final String mobileNumberBoxKey = "mobile";
final String rankBoxKey = "rank";
final String coinsBoxKey = "coins";
final String scoreBoxKey = "score";
final String profileUrlBoxKey = "profileUrl";
final String statusBoxKey = "status";
final String referCodeBoxKey = "referCode";

//settings box keys
final String showIntroSliderKey = "showIntroSlider";
final String vibrationKey = "vibration";
final String backgroundMusicKey = "backgroundMusic";
final String soundKey = "sound";
final String languageCodeKey = "language";
final String fontSizeKey = "fontSize";
final String rewardEarnedKey = "rewardEarned";
final String fcmTokenBoxKey = "fcmToken";
final String settingsThemeKey = "theme";

//Database related constants

//Add your database url
//make sure do not add '/' at the end of url

final String databaseUrl = "http://flutterquiz.thewrteam.in"; //"https://elitequiz.wrteam.in";
final String baseUrl = databaseUrl + '/Api/';
//
final String jwtKey = 'set_your_strong_jwt_secret_key';
final String accessValue = "8525";

//lifelines
final String fiftyFifty = "fiftyFifty";
final String audiencePoll = "audiencePoll";
final String skip = "skip";
final String resetTime = "resetTime";

//firestore collection names
final String battleRoomCollection = "battleRoom"; //  testBattleRoom
final String multiUserBattleRoomCollection = "multiUserBattleRoom"; // "testMultiUserBattleRoom";
final String messagesCollection = "messages"; //"testMessages";

//api end points
final String addUserUrl = "${baseUrl}user_signup";

final String getQuestionForOneToOneBattle = "${baseUrl}get_random_questions";
final String getQuestionForMultiUserBattle = "${baseUrl}get_question_by_room_id";
final String createMultiUserBattleRoom = "${baseUrl}create_room";
final String deleteMultiUserBattleRoom = "${baseUrl}destroy_room_by_room_id";

final String getBookmarkUrl = "${baseUrl}get_bookmark";
final String updateBookmarkUrl = "${baseUrl}set_bookmark";

final String getNotificationUrl = "${baseUrl}get_notifications";

final String getUserDetailsByIdUrl = "${baseUrl}get_user_by_id";

final String uploadProfileUrl = "${baseUrl}upload_profile_image";
final String updateUserCoinsAndScoreUrl = "${baseUrl}set_user_coin_score";
final String updateProfileUrl = "${baseUrl}update_profile";

final String getCategoryUrl = "${baseUrl}get_categories";
final String getQuestionsByLevelUrl = "${baseUrl}get_questions_by_level";
final String getQuestionForDailyQuizUrl = "${baseUrl}get_daily_quiz";
final String getLevelUrl = "${baseUrl}get_level_data";
final String getSubCategoryUrl = "${baseUrl}get_subcategory_by_maincategory";
final String getQuestionForSelfChallengeUrl = "${baseUrl}get_questions_for_self_challenge";
final String updateLevelUrl = "${baseUrl}set_level_data";
final String getMonthlyLeaderboardUrl = "${baseUrl}get_monthly_leaderboard";
final String getDailyLeaderboardUrl = "${baseUrl}get_daily_leaderboard";
final String getAllTimeLeaderboardUrl = "${baseUrl}get_globle_leaderboard";
final String getQuestionByTypeUrl = "${baseUrl}get_questions_by_type";
final String getQuestionContestUrl = "${baseUrl}get_questions_by_contest";
final String setContestLeaderboardUrl = "${baseUrl}set_contest_leaderboard";
final String getContestLeaderboardUrl = "${baseUrl}get_contest_leaderboard";

final String getFunAndLearnUrl = "${baseUrl}get_fun_n_learn";
final String getFunAndLearnQuestionsUrl = "${baseUrl}get_fun_n_learn_questions";

final String getStatisticUrl = "${baseUrl}get_users_statistics";
final String updateStatisticUrl = "${baseUrl}set_users_statistics";

final String getContestUrl = "${baseUrl}get_contest";
final String getSystemConfigUrl = "${baseUrl}get_system_configurations";

final String getSupportedQuestionLanguageUrl = "${baseUrl}get_languages";
final String getGuessTheWordQuestionUrl = "${baseUrl}get_guess_the_word";
final String getAppSettingsUrl = "${baseUrl}get_settings";
final String reportQuestionUrl = "${baseUrl}report_question";
final String getQuestionsByCategoryOrSubcategory = "${baseUrl}get_questions";
final String updateFcmIdUrl = "${baseUrl}update_fcm_id";
final String getAudioQuestionUrl = "${baseUrl}get_audio_questions"; //
final String getUserBadgesUrl = "${baseUrl}get_user_badges";
final String setUserBadgesUrl = "${baseUrl}set_badges";
final String setBattleStatisticsUrl = "${baseUrl}set_battle_statistics";

//quesiton or quiz time duration
final int questionDurationInSeconds = 15;
final int selfChallengeMaxMinutes = 30;
final int guessTheWordQuestionDurationInSeconds = 45;
final int inBetweenQuestionTimeInSeconds = 1;
//
//it is the waiting time for finding opponent. Once user has waited for
//given seconds it will show opponent not found
final int waitForOpponentDurationInSeconds = 10;
//time to read paragraph
final int comprehensionParagraphReadingTimeInSeconds = 60;

//answer correctness track name
final String correctAnswerSoundTrack = "assets/sounds/right.mp3";
final String wrongAnswerSoundTrack = "assets/sounds/wrong.mp3";
//this will be in use while playing self challengle
final String clickEventSoundTrack = "assets/sounds/click.mp3";

//coins and answer points and win percentage
final int lifeLineDeductCoins = 5;
final int numberOfHintsPerGuessTheWordQuestion = 2;
final int correctAnswerPoints = 4;
final int wrongAnswerDeductPoints = 2;
//points for correct answer in battle
final int correctAnswerPointsForBattle = 4;

final int guessTheWordCorrectAnswerPoints = 6;
final int guessTheWordWrongAnswerDeductPoints = 3;
final double winPercentageBreakPoint = 30.0; // more than 30% declare winner
final double maxCoinsWinningPercentage = 80.0; //it is highest percentage to earn maxCoins
final int maxWinningCoins = 4;
final int guessTheWordMaxWinningCoins = 6;
//Coins to give winner of battle (1 vs 1)
final int battleWinnerCoins = 5;
final int randomBattleEntryCoins = 5;

//if user give the answer of battle with in 1 or 2 seconds
final int extraPointForQuickestAnswer = 2;
//if user give the answer of battle with in 3 or 4 seconds
final int extraPointForSecondQuickestAnswer = 1;
//minimum coins for creating group battle
final int minCoinsForGroupBattleCreation = 5;
final int maxCoinsForGroupBattleCreation = 50;
//other constants
final String defaultQuestionLanguageId = "";

//Group battle invite message
final String groupBattleInviteMessage = "Hello, Join a group battle in $appName app. Go to group battle in the app and join using the code : ";

// Fb Ads placementId
final String fbBannerAndInterstitialAdPrefix = "IMG_16_9_APP_INSTALL#";
final String fbRewardedAdPrefix = "VID_HD_16_9_15S_LINK#";
final String placementId = "2312433698835503_2964944860251047";
final String initialCountryCode = "IN"; // change your initialCountry Code

//predefined messages for battle
final List<String> predefinedMessages = [
  "Hello..!!",
  "How are you..?",
  "Fine..!!",
  "Have a nice day..",
  "Well played",
  "What a performance..!!",
  "Thanks..",
  "Welcome..",
];

//constants for badges and rewards
final int minimumQuestionsForBadges = 5;

//
final List<String> badgeTypes = [
  "dashing_debut",
  "combat_winner",
  "clash_winner",
  "most_wanted_winner",
  "ultimate_player",
  "quiz_warrior",
  "super_sonic",
  "flashback",
  "brainiac",
  "big_thing",
  "elite",
  "thirsty",
  "power_elite",
  "sharing_caring",
  "streak"
];

//
const String roomCodeGenerateCharacters = "1234567890"; //Numeric
//to make roomCode alpha numeric use below string in roomCodeGenerateCharacters
//AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890

///
///Add your exam rules here
///
const List<String> examRules = [
  "Aee Safed Kapda Aeee Safed Kapda Idhar Idhar Dekhle Aeeeyyy Photo wale",
  "Aee Safed Kapda Aeee Safed Kapda Idhar Idhar Dekhle Aeeeyyy Photo wale",
  "Aee Safed Kapda Aeee Safed Kapda Idhar Idhar Dekhle Aeeeyyy Photo wale",
  "Aee Safed Kapda Aeee Safed Kapda Idhar Idhar Dekhle Aeeeyyy Photo wale",
  "Aee Safed Kapda Aeee Safed Kapda Idhar Idhar Dekhle Aeeeyyy Photo wale",
  "Aee Safed Kapda Aeee Safed Kapda Idhar Idhar Dekhle Aeeeyyy Photo wale",
];
