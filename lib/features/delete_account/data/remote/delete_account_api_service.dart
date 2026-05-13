import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'delete_account_api_service.g.dart';

@RestApi()
abstract class DeleteAccountApiService {
  static const String deleteAccountApi = 'worker/delete-account';
  factory DeleteAccountApiService(Dio dio, {String baseUrl}) =
      _DeleteAccountApiService;

  @DELETE(deleteAccountApi)
  Future<void> deleteAccount();
}
