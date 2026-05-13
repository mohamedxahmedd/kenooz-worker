# POST Method Implementation Guide — Kenooz Worker App

> This document describes the **exact structure, flow, naming conventions, and code templates** for implementing any POST API endpoint in this Flutter project. Give any AI agent this file + the endpoint details and it will produce clean, consistent code that matches the existing codebase.

---

## Architecture Overview

```
lib/
└── features/
    └── {feature_name}/
        ├── data/
        │   ├── models/
        │   │   ├── {feature}_request_model.dart        ← Request body (POST payload)
        │   │   ├── {feature}_request_model.g.dart       ← Auto-generated
        │   │   ├── {feature}_response_model.dart        ← API response
        │   │   └── {feature}_response_model.g.dart      ← Auto-generated
        │   ├── remote/
        │   │   ├── {feature}_api_service.dart            ← Retrofit abstract class
        │   │   └── {feature}_api_service.g.dart          ← Auto-generated
        │   └── repo/
        │       └── {feature}_repo.dart                   ← Repository wrapper
        └── presentation/
            ├── cubit/
            │   ├── {feature}_cubit.dart                  ← State management
            │   ├── {feature}_state.dart                  ← Freezed state union
            │   └── {feature}_state.freezed.dart          ← Auto-generated
            └── ui/
                ├── {feature}_screen.dart                 ← Screen entry
                └── widgets/
                    ├── {feature}_bloc_listener.dart       ← BlocListener (handles side effects)
                    └── {feature}_form_widget.dart         ← Form fields
```

---

## Step 1: Request Model

**File:** `lib/features/{feature}/data/models/{feature}_request_model.dart`

**Rules:**
- Use `@JsonSerializable()` annotation
- Use `@JsonKey(name: 'snake_case')` when Dart field name differs from API field name
- All fields are `final`
- Constructor uses `required` keyword for all fields
- Include `factory fromJson()` and `toJson()` methods
- `part '{feature}_request_model.g.dart';` at top

**Template:**

```dart
import 'package:json_annotation/json_annotation.dart';

part '{feature}_request_model.g.dart';

@JsonSerializable()
class {Feature}RequestModel {
  final String fieldOne;
  @JsonKey(name: 'field_two')
  final String fieldTwo;
  @JsonKey(name: 'optional_field')
  final String? optionalField;

  {Feature}RequestModel({
    required this.fieldOne,
    required this.fieldTwo,
    this.optionalField,
  });

  factory {Feature}RequestModel.fromJson(Map<String, dynamic> json) =>
      _${Feature}RequestModelFromJson(json);
  Map<String, dynamic> toJson() => _${Feature}RequestModelToJson(this);
}
```

**Real example — LoginRequestModel:**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String email;
  final String password;
  @JsonKey(name: 'device_name')
  final String deviceName;
  @JsonKey(name: 'device_token')
  final String deviceToken;
  LoginRequestModel({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.deviceToken,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
```

---

## Step 2: Response Model

**File:** `lib/features/{feature}/data/models/{feature}_response_model.dart`

**Rules:**
- Same pattern as request model: `@JsonSerializable()`, `@JsonKey`, `part`, `fromJson`, `toJson`
- Can contain nested models (import them)
- Nullable fields use `String?` / `int?` etc.
- Numeric fields from API: use `int` or `double` (generated code handles `(json['field'] as num).toInt()`)

**Template:**

```dart
import 'package:json_annotation/json_annotation.dart';

part '{feature}_response_model.g.dart';

@JsonSerializable()
class {Feature}ResponseModel {
  final int id;
  final String message;
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'created_at')
  final String createdAt;

  {Feature}ResponseModel({
    required this.id,
    required this.message,
    required this.accessToken,
    required this.createdAt,
  });

  factory {Feature}ResponseModel.fromJson(Map<String, dynamic> json) =>
      _${Feature}ResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _${Feature}ResponseModelToJson(this);
}
```

---

## Step 3: API Service (Retrofit)

**File:** `lib/features/{feature}/data/remote/{feature}_api_service.dart`

**Rules:**
- Import `dio`, `retrofit`, `constant.dart`, request model, response model
- `@RestApi(baseUrl: baseUrl)` annotation — `baseUrl` comes from `core/constant.dart`
- Class is `abstract`
- Define endpoint as `static const String {feature}Api = 'your/endpoint';`
- Factory constructor references the generated `_{Feature}ApiService`
- `@POST({feature}Api)` annotation on method
- Request body uses `@Body()` annotation
- Returns `Future<{Feature}ResponseModel>`
- `part '{feature}_api_service.g.dart';`

**Template:**

```dart
import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_request_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_response_model.dart';
import 'package:retrofit/retrofit.dart';

part '{feature}_api_service.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class {Feature}ApiService {
  static const String {feature}Api = 'your/endpoint/path';
  factory {Feature}ApiService(Dio dio, {String baseUrl}) = _{Feature}ApiService;

  @POST({feature}Api)
  Future<{Feature}ResponseModel> {methodName}(
    @Body() {Feature}RequestModel body,
  );
}
```

**Real example — LoginApiService:**

```dart
import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_request_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'login_api_services.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class LoginApiService {
  static const String loginApi = 'worker/login';
  factory LoginApiService(Dio dio, {String baseUrl}) = _LoginApiService;
  @POST(loginApi)
  Future<LoginResponseModel> login(
    @Body() LoginRequestModel body,
  );
}
```

---

## Step 4: Repository

**File:** `lib/features/{feature}/data/repo/{feature}_repo.dart`

**Rules:**
- Injects the API service via constructor
- Method returns `Future<ApiResult<{Feature}ResponseModel>>`
- Wraps the call in try/catch
- Success → `ApiResult.success(response)`
- Catch → `ApiResult.failure(ErrorHandler.handle(e))`
- For POST: method accepts the request model as a named parameter

**Template:**

```dart
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_request_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_response_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/remote/{feature}_api_service.dart';

class {Feature}Repo {
  final {Feature}ApiService _{feature}ApiService;
  {Feature}Repo(this._{feature}ApiService);

  Future<ApiResult<{Feature}ResponseModel>> {methodName}(
      {required {Feature}RequestModel {feature}ReqModel}) async {
    try {
      final response = await _{feature}ApiService.{methodName}({feature}ReqModel);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

**Real example — LoginRepo:**

```dart
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_request_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:kenooz_worker_app/features/login/data/remote/login_api_services.dart';

class LoginRepo {
  final LoginApiService _loginApiService;
  LoginRepo(this._loginApiService);
  Future<ApiResult<LoginResponseModel>> login(
      {required LoginRequestModel loginReqModel}) async {
    try {
      final response = await _loginApiService.login(loginReqModel);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

---

## Step 5: State (Freezed)

**File:** `lib/features/{feature}/presentation/cubit/{feature}_state.dart`

**Rules:**
- Uses `@freezed` annotation
- Generic type `<T>` for flexible success data
- Four states: `initial()`, `loading()`, `success(T data)`, `error({required List<String> messages})`
- `part '{feature}_state.freezed.dart';`
- The `.freezed.dart` file is auto-generated — never edit it manually

**Template (exact):**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{feature}_state.freezed.dart';

@freezed
class {Feature}State<T> with _${Feature}State<T> {
  const factory {Feature}State.initial() = _Initial;
  const factory {Feature}State.loading() = Loading;
  const factory {Feature}State.success(T data) = Success<T>;
  const factory {Feature}State.error({required List<String> messages}) = Error;
}
```

**Real example — LoginState:**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState<T> with _$LoginState<T> {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = Loading;
  const factory LoginState.success(T data) = Success<T>;
  const factory LoginState.error({required List<String> messages}) = Error;
}
```

---

## Step 6: Cubit

**File:** `lib/features/{feature}/presentation/cubit/{feature}_cubit.dart`

**Rules:**
- Extends `Cubit<{Feature}State>`
- Injects repo via constructor
- Initial state: `const {Feature}State.initial()`
- Holds `TextEditingController` for each form field
- Holds `GlobalKey<FormState> formKey`
- Main method: `emitStates()` or `emit{Feature}States()`
- Flow: emit loading → build request model from controllers → call repo → handle response.when()
- Error handling: check `error.errorModel` type → `BaseErrorModel` or `ListErrorModel`
- On success: optionally save data to cache, then emit success state
- Import `base_error_model.dart` and `list_error_model.dart` for error type checking

**Template:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_request_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_response_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/repo/{feature}_repo.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_state.dart';

class {Feature}Cubit extends Cubit<{Feature}State> {
  final {Feature}Repo _{feature}Repo;
  {Feature}Cubit(this._{feature}Repo) : super(const {Feature}State.initial());

  // Form controllers
  TextEditingController fieldOneController = TextEditingController();
  TextEditingController fieldTwoController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> emit{Feature}States() async {
    emit(const {Feature}State.loading());
    final response = await _{feature}Repo.{methodName}(
      {feature}ReqModel: {Feature}RequestModel(
        fieldOne: fieldOneController.text,
        fieldTwo: fieldTwoController.text,
      ),
    );
    response.when(
      success: ({feature}Response) async {
        // Optional: save data to cache here
        emit({Feature}State.success({feature}Response));
      },
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit({Feature}State.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit({Feature}State.error(messages: error.errorModel.messages));
        } else {
          emit(const {Feature}State.error(messages: ['Unknown error']));
        }
      },
    );
  }
}
```

**Real example — LoginCubit:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_helper.dart';
import 'package:kenooz_worker_app/core/cache_helper/cache_values.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/dio_factory.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_request_model.dart';
import 'package:kenooz_worker_app/features/login/data/models/login_response_model.dart';
import 'package:kenooz_worker_app/features/login/data/repo/login_repo.dart';
import 'package:kenooz_worker_app/features/login/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  LoginCubit(this._loginRepo) : super(const LoginState.initial());

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  Future<void> emitLoginStates() async {
    emit(const LoginState.loading());
    final response = await _loginRepo.login(
        loginReqModel: LoginRequestModel(
            email: emailController.text,
            password: passwordController.text,
            deviceName: 'apple',
            deviceToken:
                CacheHelper.getData(key: CacheKeys.fcmToken) ?? "test"));
    response.when(
      success: (loginResponse) async {
        await saveUserData(loginResponse);
        emit(LoginState.success(loginResponse));
      },
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(LoginState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(LoginState.error(messages: error.errorModel.messages));
        } else {
          emit(const LoginState.error(messages: ['Unknown error']));
        }
      },
    );
  }

  Future<void> saveUserData(LoginResponseModel loginResponse) async {
    try {
      await CacheHelper.setSecuredString(
          CacheKeys.userToken, loginResponse.accessToken);
      final savedToken =
          await CacheHelper.getSecuredString(CacheKeys.userToken);
      if (savedToken == loginResponse.accessToken) {
        isLoggedInUser = true;
        DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.accessToken);
      }
      await CacheHelper.saveData(
          key: CacheKeys.userId, value: loginResponse.user.id);
      await CacheHelper.saveData(
          key: CacheKeys.shopId, value: loginResponse.user.shopId);
      await CacheHelper.saveData(
          key: CacheKeys.userName, value: loginResponse.user.name);
      await CacheHelper.saveData(
          key: CacheKeys.userRole, value: loginResponse.user.role);
      await CacheHelper.saveData(
          key: CacheKeys.isAdmin, value: loginResponse.user.isAdmin == 1);
    } catch (e) {
      // Handle error
    }
  }
}
```

---

## Step 7: Dependency Injection

**File:** `lib/core/di/dependency_injection.dart`

**Rules:**
- Add two new lazy singletons: ApiService and Repo
- ApiService takes `dio` parameter
- Repo resolves its ApiService dependency via `getIt()`
- Add after existing registrations

**What to add:**

```dart
// Add these imports at the top:
import 'package:kenooz_worker_app/features/{feature}/data/remote/{feature}_api_service.dart';
import 'package:kenooz_worker_app/features/{feature}/data/repo/{feature}_repo.dart';

// Add these lines inside setupGetIt():
getIt.registerLazySingleton<{Feature}ApiService>(() => {Feature}ApiService(dio));
getIt.registerLazySingleton<{Feature}Repo>(() => {Feature}Repo(getIt()));
```

---

## Step 8: Route

**File:** `lib/core/routing/routes.dart`

Add route constant:

```dart
static const String {feature}Screen = '/{feature}_screen';
```

**File:** `lib/core/routing/app_router.dart`

Add route case:

```dart
case Routes.{feature}Screen:
  return CupertinoPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => {Feature}Cubit(getIt()),
      child: const {Feature}Screen(),
    ),
  );
```

---

## Step 9: UI — Screen

**File:** `lib/features/{feature}/presentation/ui/{feature}_screen.dart`

**Rules:**
- StatelessWidget (POST screens don't need initState trigger)
- Scaffold with Form widget wrapping the body
- Form key from cubit: `context.read<{Feature}Cubit>().formKey`
- Button validates form then calls `context.read<{Feature}Cubit>().emit{Feature}States()`
- Include the BlocListener widget for side effects

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/core/widgets/custom_button.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_cubit.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/ui/widgets/{feature}_bloc_listener.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/ui/widgets/{feature}_form_widget.dart';

class {Feature}Screen extends StatelessWidget {
  const {Feature}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                // Form fields widget
                const {Feature}FormWidget(),
                SizedBox(height: 24.h),
                // Submit button
                CustomButton(
                  buttonText: 'Submit',
                  onPressed: () {
                    if (context.read<{Feature}Cubit>().formKey.currentState!.validate()) {
                      context.read<{Feature}Cubit>().emit{Feature}States();
                    }
                  },
                ),
                // Bloc listener for side effects
                const {Feature}BlocListener(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Step 10: UI — BlocListener

**File:** `lib/features/{feature}/presentation/ui/widgets/{feature}_bloc_listener.dart`

**Rules:**
- Pure listener — no UI rendering (returns `const SizedBox.shrink()`)
- `listenWhen` filters to loading/success/error only
- Loading → show `EasyLoading` spinner
- Error → dismiss loading, show failure snackbar
- Success → dismiss loading, navigate (or show success feedback)
- Uses `context.pushNamedAndRemoveUntil()` for auth flows or `context.pushNamed()` for regular navigation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/helpers/extensions.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/utilies/easy_loading.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_cubit.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_state.dart';

class {Feature}BlocListener extends StatelessWidget {
  const {Feature}BlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<{Feature}Cubit, {Feature}State>(
      listenWhen: (previous, current) =>
          current is Loading || current is Error || current is Success,
      listener: (context, state) {
        state.whenOrNull(
          loading: () => showLoading(),
          error: (messages) {
            hideLoading();
            failureSnackBar(context, messages.first);
          },
          success: (data) {
            hideLoading();
            // Navigate or show success
            context.pushNamedAndRemoveUntil(
              Routes.mainlayoutScreen,
              predicate: (route) => false,
            );
          },
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
```

---

## Step 11: Code Generation

After creating all files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `{feature}_request_model.g.dart`
- `{feature}_response_model.g.dart`
- `{feature}_api_service.g.dart`
- `{feature}_state.freezed.dart`

---

## Complete POST Flow Diagram

```
User taps Submit button
  ↓
Form validation (formKey.currentState!.validate())
  ↓
{Feature}Cubit.emit{Feature}States()
  ├─ emit({Feature}State.loading())
  ├─ Build {Feature}RequestModel from TextEditingControllers
  ├─ Call {Feature}Repo.{method}({feature}ReqModel: model)
  │   ├─ try: await {Feature}ApiService.{method}(model)
  │   │   └─ Retrofit sends POST to baseUrl + endpoint
  │   │       └─ model.toJson() → JSON body
  │   │       └─ Response JSON → {Feature}ResponseModel.fromJson()
  │   │   └─ return ApiResult.success(response)
  │   └─ catch: return ApiResult.failure(ErrorHandler.handle(e))
  │       └─ DioException → ErrorParser.parseError()
  │           ├─ String → BaseErrorModel(message)
  │           ├─ List → ListErrorModel(messages)
  │           └─ Map → ListErrorModel(flattened messages)
  └─ response.when(
      ├─ success: save data → emit({Feature}State.success(data))
      └─ failure: extract messages → emit({Feature}State.error(messages))
     )
  ↓
BlocListener reacts:
  ├─ loading → showLoading()
  ├─ error → hideLoading() + failureSnackBar()
  └─ success → hideLoading() + navigate
```

---

## Naming Conventions Summary

| Item | Convention | Example |
|------|-----------|---------|
| Feature folder | snake_case | `sign_up/` |
| Model class | PascalCase + `RequestModel` / `ResponseModel` | `LoginRequestModel` |
| API service class | PascalCase + `ApiService` | `LoginApiService` |
| API service file | snake_case + `_api_service.dart` or `_api_services.dart` | `login_api_services.dart` |
| Endpoint constant | camelCase + `Api` suffix | `loginApi` |
| Repo class | PascalCase + `Repo` | `LoginRepo` |
| Cubit class | PascalCase + `Cubit` | `LoginCubit` |
| State class | PascalCase + `State` | `LoginState` |
| Cubit method | `emit{Feature}States()` | `emitLoginStates()` |
| Controllers | `{field}Controller` | `emailController` |
| Form key | `formKey` or `formkey` | `formkey` |
| Screen class | PascalCase + `Screen` | `LoginScreen` |
| Route constant | camelCase + `Screen` | `loginScreen` |
| Private repo field | `_{feature}ApiService` | `_loginApiService` |
| Request model param | `{feature}ReqModel` | `loginReqModel` |
| JSON keys | `@JsonKey(name: 'snake_case')` | `@JsonKey(name: 'device_name')` |

---

## Imports Pattern

Always use full package imports:

```dart
import 'package:kenooz_worker_app/core/...';
import 'package:kenooz_worker_app/features/{feature}/...';
```

Never use relative imports.

---

## Error Handling Pattern (Cubit)

This exact block is copy-pasted in every cubit:

```dart
failure: (error) {
  if (error.errorModel is BaseErrorModel) {
    emit({Feature}State.error(
        messages: [error.errorModel.message ?? 'Unknown error']));
  } else if (error.errorModel is ListErrorModel) {
    emit({Feature}State.error(messages: error.errorModel.messages));
  } else {
    emit(const {Feature}State.error(messages: ['Unknown error']));
  }
},
```

---

## Checklist

When implementing a new POST feature, ensure you:

- [ ] Create `{feature}_request_model.dart` with `@JsonSerializable()` and `@JsonKey` mappings
- [ ] Create `{feature}_response_model.dart` with all response fields
- [ ] Create `{feature}_api_service.dart` with `@RestApi`, `@POST`, `@Body()`
- [ ] Create `{feature}_repo.dart` wrapping service call in `ApiResult<T>` try/catch
- [ ] Create `{feature}_state.dart` with Freezed union (initial/loading/success/error)
- [ ] Create `{feature}_cubit.dart` with controllers, formKey, emit method, error handling
- [ ] Register `ApiService` and `Repo` in `dependency_injection.dart`
- [ ] Add route constant in `routes.dart`
- [ ] Add route case in `app_router.dart` with `BlocProvider`
- [ ] Create screen widget
- [ ] Create BlocListener widget for side effects
- [ ] Create form widget with TextFormFields
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
