# GET Method Implementation Guide — Kenooz Worker App

> This document describes the **exact structure, flow, naming conventions, and code templates** for implementing any GET API endpoint in this Flutter project. Give any AI agent this file + the endpoint details and it will produce clean, consistent code that matches the existing codebase.

---

## Architecture Overview

```
lib/
└── features/
    └── {feature_name}/
        ├── data/
        │   ├── models/
        │   │   ├── {feature}_response_model.dart        ← API response model
        │   │   └── {feature}_response_model.g.dart       ← Auto-generated
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
                ├── {feature}_screen.dart                 ← Screen entry (triggers fetch in initState)
                └── widgets/
                    └── {feature}_bloc_builder.dart        ← BlocBuilder (renders loading/success/error)
```

**Key difference from POST:** No request model needed. No form controllers. No BlocListener (side effects). Uses BlocBuilder instead. Screen is StatefulWidget (triggers fetch in `initState`).

---

## Step 1: Response Model

**File:** `lib/features/{feature}/data/models/{feature}_response_model.dart`

**Rules:**
- Use `@JsonSerializable()` annotation
- Use `@JsonKey(name: 'snake_case')` when Dart field name differs from API field name
- All fields are `final`
- Constructor uses `required` for non-nullable fields
- Nullable fields use `?` type notation
- Include `factory fromJson()` and `toJson()` methods
- `part '{feature}_response_model.g.dart';` at top

**Template:**

```dart
import 'package:json_annotation/json_annotation.dart';

part '{feature}_response_model.g.dart';

@JsonSerializable()
class {Feature}ResponseModel {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'shop_id')
  final int shopId;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'is_active')
  final int isActive;
  @JsonKey(name: 'optional_field')
  final String? optionalField;

  {Feature}ResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.optionalField,
  });

  factory {Feature}ResponseModel.fromJson(Map<String, dynamic> json) =>
      _${Feature}ResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _${Feature}ResponseModelToJson(this);
}
```

**Real example — ProfileResponseModel:**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel {
  final int id;
  @JsonKey(name: 'shop_id')
  final int shopId;
  final String name;
  final String phone;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'device_token')
  final String? deviceToken;
  @JsonKey(name: 'is_online')
  final int isOnline;
  @JsonKey(name: 'is_admin')
  final int isAdmin;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final String role;
  @JsonKey(name: 'no_of_success_shipments')
  final int noOfSuccessShipments;
  @JsonKey(name: 'no_of_failed_shipments')
  final int noOfFailedShipments;
  @JsonKey(name: 'no_of_pending_shipments')
  final int noOfPendingShipments;

  ProfileResponseModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.email,
    this.emailVerifiedAt,
    this.deviceToken,
    required this.isOnline,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    required this.noOfSuccessShipments,
    required this.noOfFailedShipments,
    required this.noOfPendingShipments,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);
}
```

### For List Responses

If the API returns a JSON array, create a wrapper model:

```dart
@JsonSerializable()
class {Feature}ListResponseModel {
  final List<{Feature}ItemModel> data;
  final int? total;

  {Feature}ListResponseModel({
    required this.data,
    this.total,
  });

  factory {Feature}ListResponseModel.fromJson(Map<String, dynamic> json) =>
      _${Feature}ListResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _${Feature}ListResponseModelToJson(this);
}
```

Or if the API returns a raw list (not wrapped in object), use `List<{Feature}ItemModel>` directly in the service.

---

## Step 2: API Service (Retrofit)

**File:** `lib/features/{feature}/data/remote/{feature}_api_service.dart`

**Rules:**
- Import `dio`, `retrofit`, `constant.dart`, and response model
- `@RestApi(baseUrl: baseUrl)` — `baseUrl` comes from `core/constant.dart`
- Class is `abstract`
- Endpoint as `static const String {feature}Api = 'your/endpoint';`
- Factory constructor references generated `_{Feature}ApiService`
- `@GET({feature}Api)` annotation
- No `@Body()` annotation (GET has no request body)
- Returns `Future<{Feature}ResponseModel>`
- For endpoints with path params: use `@Path()` annotation
- For endpoints with query params: use `@Query()` annotation

**Template — Simple GET (no params):**

```dart
import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_response_model.dart';
import 'package:retrofit/retrofit.dart';

part '{feature}_api_service.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class {Feature}ApiService {
  static const String {feature}Api = 'your/endpoint/path';
  factory {Feature}ApiService(Dio dio, {String baseUrl}) = _{Feature}ApiService;

  @GET({feature}Api)
  Future<{Feature}ResponseModel> get{Feature}();
}
```

**Template — GET with path parameter:**

```dart
@RestApi(baseUrl: baseUrl)
abstract class {Feature}ApiService {
  static const String {feature}Api = 'your/endpoint/{id}';
  factory {Feature}ApiService(Dio dio, {String baseUrl}) = _{Feature}ApiService;

  @GET({feature}Api)
  Future<{Feature}ResponseModel> get{Feature}(
    @Path('id') int id,
  );
}
```

**Template — GET with query parameters:**

```dart
@RestApi(baseUrl: baseUrl)
abstract class {Feature}ApiService {
  static const String {feature}Api = 'your/endpoint';
  factory {Feature}ApiService(Dio dio, {String baseUrl}) = _{Feature}ApiService;

  @GET({feature}Api)
  Future<{Feature}ResponseModel> get{Feature}(
    @Query('page') int page,
    @Query('per_page') int perPage,
  );
}
```

**Real example — ProfileApiService:**

```dart
import 'package:dio/dio.dart';
import 'package:kenooz_worker_app/core/constant.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_service.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class ProfileApiService {
  static const String profileApi = 'worker/profile';
  factory ProfileApiService(Dio dio, {String baseUrl}) = _ProfileApiService;

  @GET(profileApi)
  Future<ProfileResponseModel> getProfile();
}
```

---

## Step 3: Repository

**File:** `lib/features/{feature}/data/repo/{feature}_repo.dart`

**Rules:**
- Injects the API service via constructor
- Method returns `Future<ApiResult<{Feature}ResponseModel>>`
- Wraps the call in try/catch
- Success → `ApiResult.success(response)`
- Catch → `ApiResult.failure(ErrorHandler.handle(e))`
- For GET without params: method has no parameters
- For GET with params: pass params through

**Template — Simple GET:**

```dart
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_response_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/remote/{feature}_api_service.dart';

class {Feature}Repo {
  final {Feature}ApiService _{feature}ApiService;
  {Feature}Repo(this._{feature}ApiService);

  Future<ApiResult<{Feature}ResponseModel>> get{Feature}() async {
    try {
      final response = await _{feature}ApiService.get{Feature}();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

**Template — GET with parameters:**

```dart
class {Feature}Repo {
  final {Feature}ApiService _{feature}ApiService;
  {Feature}Repo(this._{feature}ApiService);

  Future<ApiResult<{Feature}ResponseModel>> get{Feature}({required int id}) async {
    try {
      final response = await _{feature}ApiService.get{Feature}(id);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

**Real example — ProfileRepo:**

```dart
import 'package:kenooz_worker_app/core/network/api_error_handler.dart';
import 'package:kenooz_worker_app/core/network/api_result.dart';
import 'package:kenooz_worker_app/features/profile/data/models/profile_response_model.dart';
import 'package:kenooz_worker_app/features/profile/data/remote/profile_api_service.dart';

class ProfileRepo {
  final ProfileApiService _profileApiService;
  ProfileRepo(this._profileApiService);

  Future<ApiResult<ProfileResponseModel>> getProfile() async {
    try {
      final response = await _profileApiService.getProfile();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

---

## Step 4: State (Freezed)

**File:** `lib/features/{feature}/presentation/cubit/{feature}_state.dart`

**Rules:**
- Identical to POST state — same exact four states
- Uses `@freezed` annotation, generic type `<T>`
- `part '{feature}_state.freezed.dart';`

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

**Real example — ProfileState:**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState<T> with _$ProfileState<T> {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = Loading;
  const factory ProfileState.success(T data) = Success<T>;
  const factory ProfileState.error({required List<String> messages}) = Error;
}
```

---

## Step 5: Cubit

**File:** `lib/features/{feature}/presentation/cubit/{feature}_cubit.dart`

**Rules:**
- Extends `Cubit<{Feature}State>`
- Injects repo via constructor
- Initial state: `const {Feature}State.initial()`
- **No TextEditingControllers** (GET doesn't have form fields)
- **No formKey** (GET doesn't have forms)
- Main method: `get{Feature}()`
- Flow: emit loading → call repo → handle response.when()
- Error handling block is identical to POST

**Template — Simple GET:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/{feature}/data/repo/{feature}_repo.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_state.dart';

class {Feature}Cubit extends Cubit<{Feature}State> {
  final {Feature}Repo _{feature}Repo;
  {Feature}Cubit(this._{feature}Repo) : super(const {Feature}State.initial());

  Future<void> get{Feature}() async {
    emit(const {Feature}State.loading());
    final response = await _{feature}Repo.get{Feature}();
    response.when(
      success: ({feature}) => emit({Feature}State.success({feature})),
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

**Template — GET with parameters:**

```dart
class {Feature}Cubit extends Cubit<{Feature}State> {
  final {Feature}Repo _{feature}Repo;
  {Feature}Cubit(this._{feature}Repo) : super(const {Feature}State.initial());

  Future<void> get{Feature}({required int id}) async {
    emit(const {Feature}State.loading());
    final response = await _{feature}Repo.get{Feature}(id: id);
    response.when(
      success: ({feature}) => emit({Feature}State.success({feature})),
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

**Real example — ProfileCubit:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/network/base_error_model.dart';
import 'package:kenooz_worker_app/core/network/list_error_model.dart';
import 'package:kenooz_worker_app/features/profile/data/repo/profile_repo.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;
  ProfileCubit(this._profileRepo) : super(const ProfileState.initial());

  Future<void> getProfile() async {
    emit(const ProfileState.loading());
    final response = await _profileRepo.getProfile();
    response.when(
      success: (profile) => emit(ProfileState.success(profile)),
      failure: (error) {
        if (error.errorModel is BaseErrorModel) {
          emit(ProfileState.error(
              messages: [error.errorModel.message ?? 'Unknown error']));
        } else if (error.errorModel is ListErrorModel) {
          emit(ProfileState.error(messages: error.errorModel.messages));
        } else {
          emit(const ProfileState.error(messages: ['Unknown error']));
        }
      },
    );
  }
}
```

---

## Step 6: Dependency Injection

**File:** `lib/core/di/dependency_injection.dart`

**What to add (same pattern as POST):**

```dart
// Add these imports at the top:
import 'package:kenooz_worker_app/features/{feature}/data/remote/{feature}_api_service.dart';
import 'package:kenooz_worker_app/features/{feature}/data/repo/{feature}_repo.dart';

// Add these lines inside setupGetIt():
getIt.registerLazySingleton<{Feature}ApiService>(() => {Feature}ApiService(dio));
getIt.registerLazySingleton<{Feature}Repo>(() => {Feature}Repo(getIt()));
```

---

## Step 7: Route

**File:** `lib/core/routing/routes.dart`

```dart
static const String {feature}Screen = '/{feature}_screen';
```

**File:** `lib/core/routing/app_router.dart`

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

## Step 8: UI — Screen (StatefulWidget)

**File:** `lib/features/{feature}/presentation/ui/{feature}_screen.dart`

**Key difference from POST:** GET screens use `StatefulWidget` because the API call is triggered in `initState()` — the screen fetches data automatically when opened.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_cubit.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/ui/widgets/{feature}_bloc_builder.dart';

class {Feature}Screen extends StatefulWidget {
  const {Feature}Screen({super.key});

  @override
  State<{Feature}Screen> createState() => _{Feature}ScreenState();
}

class _{Feature}ScreenState extends State<{Feature}Screen> {
  @override
  void initState() {
    super.initState();
    context.read<{Feature}Cubit>().get{Feature}();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkThemeBackgroundColor
          : AppColors.backGroundColorLight,
      body: const SafeArea(child: {Feature}BlocBuilder()),
    );
  }
}
```

**Real example — ProfileScreen:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/widgets/profile_bloc_builder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkThemeBackgroundColor
          : AppColors.backGroundColorLight,
      body: const SafeArea(child: ProfileBlocBuilder()),
    );
  }
}
```

---

## Step 9: UI — BlocBuilder

**File:** `lib/features/{feature}/presentation/ui/widgets/{feature}_bloc_builder.dart`

**Key difference from POST:** Uses `BlocBuilder` (renders UI) instead of `BlocListener` (handles side effects). Three visual states: shimmer loading, success content, error with retry.

**Template:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/assets.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/{feature}/data/models/{feature}_response_model.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_cubit.dart';
import 'package:kenooz_worker_app/features/{feature}/presentation/cubit/{feature}_state.dart';

class {Feature}BlocBuilder extends StatelessWidget {
  const {Feature}BlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<{Feature}Cubit, {Feature}State>(
      builder: (context, state) => state.maybeWhen(
        loading: () => const _ShimmerLoadingView(),
        success: (data) => _SuccessView({feature}: data as {Feature}ResponseModel),
        error: (messages) => _ErrorView(
          message: messages.first,
          onRetry: () => context.read<{Feature}Cubit>().get{Feature}(),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Shimmer Loading ─────────────────────────────────────────────────────────

class _ShimmerLoadingView extends StatelessWidget {
  const _ShimmerLoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1C2B24) : const Color(0xFFE8E8E8);
    final highlightColor =
        isDark ? const Color(0xFF243630) : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customize shimmer skeleton to match your success view layout
            Container(
              width: double.infinity,
              height: 200.h,
              color: baseColor,
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 150.w, height: 18.h),
                  SizedBox(height: 16.h),
                  _ShimmerBox(width: double.infinity, height: 120.h, radius: 16.r),
                  SizedBox(height: 24.h),
                  _ShimmerBox(width: 130.w, height: 18.h),
                  SizedBox(height: 12.h),
                  _ShimmerBox(width: double.infinity, height: 200.h, radius: 16.r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Success ─────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final {Feature}ResponseModel {feature};
  const _SuccessView({required this.{feature}});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Build your success UI widgets here
          // Pass {feature} model to child widgets
        ],
      ),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkThemeContainerColor
                : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.errorColor.withOpacity(0.1),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    Assets.assetsImagesProfileErrorIcon,
                    width: 30.sp,
                    height: 30.sp,
                    colorFilter: const ColorFilter.mode(
                      AppColors.errorColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Something went wrong',
                style: AppFonts.heading(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.lightTextColorForDarkMood
                      : AppColors.darkGreyTextColor,
                ),
              ),
              SizedBox(height: 8.h),

              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13.sp,
                  color: AppColors.textGreyColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),

              // Retry button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: AppFonts.body(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Step 10: Code Generation

After creating all files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `{feature}_response_model.g.dart`
- `{feature}_api_service.g.dart`
- `{feature}_state.freezed.dart`

---

## Complete GET Flow Diagram

```
Screen opens (initState)
  ↓
context.read<{Feature}Cubit>().get{Feature}()
  ↓
{Feature}Cubit.get{Feature}()
  ├─ emit({Feature}State.loading())
  │   ↓ BlocBuilder renders → _ShimmerLoadingView()
  ├─ await {Feature}Repo.get{Feature}()
  │   ├─ try: await {Feature}ApiService.get{Feature}()
  │   │   └─ Retrofit sends GET to baseUrl + endpoint
  │   │   └─ Auth token included automatically (DioFactory headers)
  │   │   └─ Response JSON → {Feature}ResponseModel.fromJson()
  │   │   └─ return ApiResult.success(response)
  │   └─ catch: return ApiResult.failure(ErrorHandler.handle(e))
  │       └─ DioException → ErrorParser.parseError()
  │           ├─ String → BaseErrorModel(message)
  │           ├─ List → ListErrorModel(messages)
  │           └─ Map → ListErrorModel(flattened messages)
  └─ response.when(
      ├─ success: emit({Feature}State.success(data))
      │   ↓ BlocBuilder renders → _SuccessView(data)
      └─ failure: extract messages → emit({Feature}State.error(messages))
          ↓ BlocBuilder renders → _ErrorView(message, onRetry)
     )
```

---

## Key Differences: GET vs POST

| Aspect | GET | POST |
|--------|-----|------|
| Request model | None | `{Feature}RequestModel` with `@Body()` |
| API annotation | `@GET(endpoint)` | `@POST(endpoint)` |
| Cubit controllers | None | `TextEditingController` for each field |
| Cubit form key | None | `GlobalKey<FormState>` |
| Screen type | `StatefulWidget` (initState triggers fetch) | `StatelessWidget` (button triggers submit) |
| UI handler | `BlocBuilder` (renders loading/success/error) | `BlocListener` (side effects: snackbar/navigate) |
| Trigger | Automatic on screen open | Manual on button press after form validation |
| Loading UI | Shimmer skeleton | EasyLoading overlay spinner |
| Error UI | Inline error card with retry button | Failure snackbar |
| Success UI | Full screen content | Navigate away or success dialog |

---

## Naming Conventions Summary

| Item | Convention | Example |
|------|-----------|---------|
| Feature folder | snake_case | `profile/` |
| Response model | PascalCase + `ResponseModel` | `ProfileResponseModel` |
| API service class | PascalCase + `ApiService` | `ProfileApiService` |
| API service file | snake_case + `_api_service.dart` | `profile_api_service.dart` |
| Endpoint constant | camelCase + `Api` suffix | `profileApi` |
| Repo class | PascalCase + `Repo` | `ProfileRepo` |
| Cubit class | PascalCase + `Cubit` | `ProfileCubit` |
| Cubit method | `get{Feature}()` | `getProfile()` |
| State class | PascalCase + `State` | `ProfileState` |
| Screen class | PascalCase + `Screen` | `ProfileScreen` |
| BlocBuilder class | PascalCase + `BlocBuilder` | `ProfileBlocBuilder` |
| Private repo field | `_{feature}ApiService` | `_profileApiService` |
| Route constant | camelCase + `Screen` | `profileScreen` |
| JSON keys | `@JsonKey(name: 'snake_case')` | `@JsonKey(name: 'shop_id')` |

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

## Shared Core Infrastructure (already exists — do not recreate)

These files are shared across all features and already exist in the project:

- `lib/core/network/api_result.dart` — `ApiResult<T>` (success/failure union)
- `lib/core/network/api_error_handler.dart` — `ErrorHandler`, `ErrorParser`, `DataSource`
- `lib/core/network/base_error_model.dart` — Single message error
- `lib/core/network/list_error_model.dart` — Multiple messages error
- `lib/core/network/dio_factory.dart` — Dio singleton with auth headers
- `lib/core/constant.dart` — `baseUrl` and app constants
- `lib/core/di/dependency_injection.dart` — GetIt service locator
- `lib/core/routing/app_router.dart` — Route generation
- `lib/core/routing/routes.dart` — Route string constants
- `lib/core/cache_helper/cache_helper.dart` — SharedPreferences + SecureStorage
- `lib/core/cache_helper/cache_values.dart` — Cache key constants

---

## Checklist

When implementing a new GET feature, ensure you:

- [ ] Create `{feature}_response_model.dart` with `@JsonSerializable()` and `@JsonKey` mappings
- [ ] Create `{feature}_api_service.dart` with `@RestApi`, `@GET`
- [ ] Create `{feature}_repo.dart` wrapping service call in `ApiResult<T>` try/catch
- [ ] Create `{feature}_state.dart` with Freezed union (initial/loading/success/error)
- [ ] Create `{feature}_cubit.dart` with get method and error handling
- [ ] Register `ApiService` and `Repo` in `dependency_injection.dart`
- [ ] Add route constant in `routes.dart`
- [ ] Add route case in `app_router.dart` with `BlocProvider`
- [ ] Create screen as `StatefulWidget` with `initState` triggering fetch
- [ ] Create BlocBuilder widget with shimmer/success/error states
- [ ] Create child UI widgets that receive the response model
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
