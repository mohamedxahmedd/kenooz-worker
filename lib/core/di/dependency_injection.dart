import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/token_manager.dart';
import 'package:kenooz_worker_app/features/home/data/remote/home_api_service.dart';
import 'package:kenooz_worker_app/features/home/data/repo/home_repo.dart';
import 'package:kenooz_worker_app/features/login/data/remote/login_api_services.dart';
import 'package:kenooz_worker_app/features/login/data/repo/login_repo.dart';
import 'package:kenooz_worker_app/features/logout/data/remote/logout_api_service.dart';
import 'package:kenooz_worker_app/features/logout/data/repo/logout_repo.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/remote/gold_double_sell_api_service.dart';
import 'package:kenooz_worker_app/features/gold_double_sell/data/repo/gold_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/remote/silver_double_sell_api_service.dart';
import 'package:kenooz_worker_app/features/silver_double_sell/data/repo/silver_double_sell_repo.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/remote/diamond_sell_api_service.dart';
import 'package:kenooz_worker_app/features/diamond_sell/data/repo/diamond_sell_repo.dart';
import 'package:kenooz_worker_app/features/profile/data/remote/profile_api_service.dart';
import 'package:kenooz_worker_app/features/profile/data/repo/profile_repo.dart';
import 'package:kenooz_worker_app/features/refresh_token/data/remote/refresh_token_api_service.dart';
import 'package:kenooz_worker_app/features/refresh_token/data/repo/refresh_token_repo.dart';
import 'package:kenooz_worker_app/features/sign_up/data/remote/signup_api_services.dart';
import 'package:kenooz_worker_app/features/sign_up/data/repo/signup_repo.dart';
import 'package:kenooz_worker_app/features/orders/data/remote/orders_api_service.dart';
import 'package:kenooz_worker_app/features/orders/data/repo/orders_repo.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/remote/gold_buy_api_service.dart';
import 'package:kenooz_worker_app/features/gold_buy/data/repo/gold_buy_repo.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/remote/silver_buy_api_service.dart';
import 'package:kenooz_worker_app/features/silver_buy/data/repo/silver_buy_repo.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/remote/gold_hangings_api_service.dart';
import 'package:kenooz_worker_app/features/gold_hangings/data/repo/gold_hangings_repo.dart';
import 'package:kenooz_worker_app/features/delete_account/data/remote/delete_account_api_service.dart';
import 'package:kenooz_worker_app/features/delete_account/data/repo/delete_account_repo.dart';
import 'package:kenooz_worker_app/features/blogs/data/repo/blogs_repo.dart';
import 'package:kenooz_worker_app/features/chat/data/repo/chat_repo.dart';
import 'package:kenooz_worker_app/features/invoice/data/repo/invoice_repo.dart';

final getIt = GetIt.instance;

/// Initial setup — called once from [main].
Future<void> setupGetIt({required String baseUrl}) async {
  Dio dio = await DioFactory.getDio(baseUrl: baseUrl);

  // ── API Services ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<LoginApiService>(() => LoginApiService(dio));
  getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
  getIt.registerLazySingleton<SignupApiService>(() => SignupApiService(dio));
  getIt.registerLazySingleton<SignupRepo>(() => SignupRepo(getIt()));
  getIt.registerLazySingleton<ProfileApiService>(() => ProfileApiService(dio));
  getIt.registerLazySingleton<ProfileRepo>(() => ProfileRepo(getIt(), dio));
  getIt.registerLazySingleton<LogoutApiService>(() => LogoutApiService(dio));
  getIt.registerLazySingleton<LogoutRepo>(() => LogoutRepo(getIt()));
  getIt.registerLazySingleton<RefreshTokenApiService>(
      () => RefreshTokenApiService(dio));
  getIt.registerLazySingleton<RefreshTokenRepo>(
      () => RefreshTokenRepo(getIt()));
  getIt.registerLazySingleton<HomeApiService>(() => HomeApiService(dio));
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepo(getIt()));
  getIt.registerLazySingleton<OrdersApiService>(() => OrdersApiService(dio));
  getIt.registerLazySingleton<OrdersRepo>(() => OrdersRepo(getIt()));
  getIt.registerLazySingleton<GoldDoubleSellApiService>(
      () => GoldDoubleSellApiService(dio));
  getIt.registerLazySingleton<GoldDoubleSellRepo>(
      () => GoldDoubleSellRepo(getIt()));
  getIt.registerLazySingleton<SilverDoubleSellApiService>(
      () => SilverDoubleSellApiService(dio));
  getIt.registerLazySingleton<SilverDoubleSellRepo>(
      () => SilverDoubleSellRepo(getIt()));
  getIt.registerLazySingleton<DiamondSellApiService>(
      () => DiamondSellApiService(dio));
  getIt.registerLazySingleton<DiamondSellRepo>(
      () => DiamondSellRepo(getIt()));
  getIt.registerLazySingleton<GoldBuyApiService>(
      () => GoldBuyApiService(dio));
  getIt.registerLazySingleton<GoldBuyRepo>(() => GoldBuyRepo(getIt()));
  getIt.registerLazySingleton<SilverBuyApiService>(
      () => SilverBuyApiService(dio));
  getIt.registerLazySingleton<SilverBuyRepo>(() => SilverBuyRepo(getIt()));
  getIt.registerLazySingleton<GoldHangingsApiService>(
      () => GoldHangingsApiService(dio));
  getIt.registerLazySingleton<GoldHangingsRepo>(
      () => GoldHangingsRepo(getIt()));
  getIt.registerLazySingleton<DeleteAccountApiService>(
      () => DeleteAccountApiService(dio));
  getIt.registerLazySingleton<DeleteAccountRepo>(
      () => DeleteAccountRepo(getIt()));
  getIt.registerLazySingleton<BlogsRepo>(() => BlogsRepo(dio));
  getIt.registerLazySingleton<ChatRepo>(() => ChatRepo(dio));
  getIt.registerLazySingleton<InvoiceRepo>(() => InvoiceRepo(dio));
}

/// Tears down all services and re-registers them with a new [baseUrl].
///
/// Call this after the user selects a different branch. The function:
/// 1. Destroys the old Dio instance
/// 2. Creates a fresh one with the new base URL
/// 3. Unregisters every service and repo
/// 4. Re-registers them with the new Dio
/// 5. Resets the TokenManager's dedicated refresh Dio
Future<void> resetServicesForBranch(String baseUrl) async {
  // 1. Reset Dio
  DioFactory.reset();
  Dio dio = await DioFactory.getDio(baseUrl: baseUrl);

  // 2. Unregister all services + repos
  getIt.unregister<LoginApiService>();
  getIt.unregister<LoginRepo>();
  getIt.unregister<SignupApiService>();
  getIt.unregister<SignupRepo>();
  getIt.unregister<ProfileApiService>();
  getIt.unregister<ProfileRepo>();
  getIt.unregister<LogoutApiService>();
  getIt.unregister<LogoutRepo>();
  getIt.unregister<RefreshTokenApiService>();
  getIt.unregister<RefreshTokenRepo>();
  getIt.unregister<HomeApiService>();
  getIt.unregister<HomeRepo>();
  getIt.unregister<OrdersApiService>();
  getIt.unregister<OrdersRepo>();
  getIt.unregister<GoldDoubleSellApiService>();
  getIt.unregister<GoldDoubleSellRepo>();
  getIt.unregister<SilverDoubleSellApiService>();
  getIt.unregister<SilverDoubleSellRepo>();
  getIt.unregister<DiamondSellApiService>();
  getIt.unregister<DiamondSellRepo>();
  getIt.unregister<GoldBuyApiService>();
  getIt.unregister<GoldBuyRepo>();
  getIt.unregister<SilverBuyApiService>();
  getIt.unregister<SilverBuyRepo>();
  getIt.unregister<GoldHangingsApiService>();
  getIt.unregister<GoldHangingsRepo>();
  getIt.unregister<DeleteAccountApiService>();
  getIt.unregister<DeleteAccountRepo>();
  getIt.unregister<BlogsRepo>();
  getIt.unregister<ChatRepo>();
  getIt.unregister<InvoiceRepo>();

  // 3. Re-register with fresh Dio
  getIt.registerLazySingleton<LoginApiService>(() => LoginApiService(dio));
  getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
  getIt.registerLazySingleton<SignupApiService>(() => SignupApiService(dio));
  getIt.registerLazySingleton<SignupRepo>(() => SignupRepo(getIt()));
  getIt.registerLazySingleton<ProfileApiService>(() => ProfileApiService(dio));
  getIt.registerLazySingleton<ProfileRepo>(() => ProfileRepo(getIt(), dio));
  getIt.registerLazySingleton<LogoutApiService>(() => LogoutApiService(dio));
  getIt.registerLazySingleton<LogoutRepo>(() => LogoutRepo(getIt()));
  getIt.registerLazySingleton<RefreshTokenApiService>(
      () => RefreshTokenApiService(dio));
  getIt.registerLazySingleton<RefreshTokenRepo>(
      () => RefreshTokenRepo(getIt()));
  getIt.registerLazySingleton<HomeApiService>(() => HomeApiService(dio));
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepo(getIt()));
  getIt.registerLazySingleton<OrdersApiService>(() => OrdersApiService(dio));
  getIt.registerLazySingleton<OrdersRepo>(() => OrdersRepo(getIt()));
  getIt.registerLazySingleton<GoldDoubleSellApiService>(
      () => GoldDoubleSellApiService(dio));
  getIt.registerLazySingleton<GoldDoubleSellRepo>(
      () => GoldDoubleSellRepo(getIt()));
  getIt.registerLazySingleton<SilverDoubleSellApiService>(
      () => SilverDoubleSellApiService(dio));
  getIt.registerLazySingleton<SilverDoubleSellRepo>(
      () => SilverDoubleSellRepo(getIt()));
  getIt.registerLazySingleton<DiamondSellApiService>(
      () => DiamondSellApiService(dio));
  getIt.registerLazySingleton<DiamondSellRepo>(
      () => DiamondSellRepo(getIt()));
  getIt.registerLazySingleton<GoldBuyApiService>(
      () => GoldBuyApiService(dio));
  getIt.registerLazySingleton<GoldBuyRepo>(() => GoldBuyRepo(getIt()));
  getIt.registerLazySingleton<SilverBuyApiService>(
      () => SilverBuyApiService(dio));
  getIt.registerLazySingleton<SilverBuyRepo>(() => SilverBuyRepo(getIt()));
  getIt.registerLazySingleton<GoldHangingsApiService>(
      () => GoldHangingsApiService(dio));
  getIt.registerLazySingleton<GoldHangingsRepo>(
      () => GoldHangingsRepo(getIt()));
  getIt.registerLazySingleton<DeleteAccountApiService>(
      () => DeleteAccountApiService(dio));
  getIt.registerLazySingleton<DeleteAccountRepo>(
      () => DeleteAccountRepo(getIt()));
  getIt.registerLazySingleton<BlogsRepo>(() => BlogsRepo(dio));
  getIt.registerLazySingleton<ChatRepo>(() => ChatRepo(dio));
  getIt.registerLazySingleton<InvoiceRepo>(() => InvoiceRepo(dio));

  // 4. Reset TokenManager's dedicated refresh Dio
  TokenManager().resetRefreshDio();
}
