import 'package:flutter/widgets.dart';

int mainLayoutIntitalScreenIndex = 0;
final navigatorKey = GlobalKey<NavigatorState>();
const Duration timeOutDeration = Duration(seconds: 15);
bool isLoggedInUser = false;
bool isLoggedInBefore = true;
const String forgetPasswardUrl = 'https://app.habibyclinics.com/';
const String publishesStripeKey =
    "pk_live_51Mo0ozAN7QMubibp4WNz8OlHNlOVym0PLUTZbrJc2P8wTYS8vuHDTROkVOffLjBCmMmD4pYMt9ZgHGl5KcVo5oRj00qTSMAxOl";
const String apiKeyPayMob =
    "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBM01UTTJOaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5NYjJDNll4SkxsdG1vTXUtRnZTQjQwUzZ5MXRHQzRtVHlFbEI4ZldPUVcyX1ctM3RCSFdqNW41U3BtdGxwLS01UXdTYjVxSnl3LXNOWlM2QURMc1UzQQ==";
const String integrationIdPayMob = "5252232";
