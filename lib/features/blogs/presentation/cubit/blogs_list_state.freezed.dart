// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blogs_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BlogsListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlogsListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BlogsListState()';
}


}

/// @nodoc
class $BlogsListStateCopyWith<$Res>  {
$BlogsListStateCopyWith(BlogsListState _, $Res Function(BlogsListState) __);
}


/// Adds pattern-matching-related methods to [BlogsListState].
extension BlogsListStatePatterns on BlogsListState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BlogsListInitial value)?  initial,TResult Function( BlogsListLoading value)?  loading,TResult Function( BlogsListLoaded value)?  loaded,TResult Function( BlogsListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BlogsListInitial() when initial != null:
return initial(_that);case BlogsListLoading() when loading != null:
return loading(_that);case BlogsListLoaded() when loaded != null:
return loaded(_that);case BlogsListError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BlogsListInitial value)  initial,required TResult Function( BlogsListLoading value)  loading,required TResult Function( BlogsListLoaded value)  loaded,required TResult Function( BlogsListError value)  error,}){
final _that = this;
switch (_that) {
case BlogsListInitial():
return initial(_that);case BlogsListLoading():
return loading(_that);case BlogsListLoaded():
return loaded(_that);case BlogsListError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BlogsListInitial value)?  initial,TResult? Function( BlogsListLoading value)?  loading,TResult? Function( BlogsListLoaded value)?  loaded,TResult? Function( BlogsListError value)?  error,}){
final _that = this;
switch (_that) {
case BlogsListInitial() when initial != null:
return initial(_that);case BlogsListLoading() when loading != null:
return loading(_that);case BlogsListLoaded() when loaded != null:
return loaded(_that);case BlogsListError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<BlogModel> blogs,  bool hasMore,  bool isLoadingMore,  int currentPage)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BlogsListInitial() when initial != null:
return initial();case BlogsListLoading() when loading != null:
return loading();case BlogsListLoaded() when loaded != null:
return loaded(_that.blogs,_that.hasMore,_that.isLoadingMore,_that.currentPage);case BlogsListError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<BlogModel> blogs,  bool hasMore,  bool isLoadingMore,  int currentPage)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case BlogsListInitial():
return initial();case BlogsListLoading():
return loading();case BlogsListLoaded():
return loaded(_that.blogs,_that.hasMore,_that.isLoadingMore,_that.currentPage);case BlogsListError():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<BlogModel> blogs,  bool hasMore,  bool isLoadingMore,  int currentPage)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case BlogsListInitial() when initial != null:
return initial();case BlogsListLoading() when loading != null:
return loading();case BlogsListLoaded() when loaded != null:
return loaded(_that.blogs,_that.hasMore,_that.isLoadingMore,_that.currentPage);case BlogsListError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class BlogsListInitial implements BlogsListState {
  const BlogsListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlogsListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BlogsListState.initial()';
}


}




/// @nodoc


class BlogsListLoading implements BlogsListState {
  const BlogsListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlogsListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BlogsListState.loading()';
}


}




/// @nodoc


class BlogsListLoaded implements BlogsListState {
  const BlogsListLoaded({required final  List<BlogModel> blogs, required this.hasMore, required this.isLoadingMore, required this.currentPage}): _blogs = blogs;
  

 final  List<BlogModel> _blogs;
 List<BlogModel> get blogs {
  if (_blogs is EqualUnmodifiableListView) return _blogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blogs);
}

 final  bool hasMore;
 final  bool isLoadingMore;
 final  int currentPage;

/// Create a copy of BlogsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlogsListLoadedCopyWith<BlogsListLoaded> get copyWith => _$BlogsListLoadedCopyWithImpl<BlogsListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlogsListLoaded&&const DeepCollectionEquality().equals(other._blogs, _blogs)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_blogs),hasMore,isLoadingMore,currentPage);

@override
String toString() {
  return 'BlogsListState.loaded(blogs: $blogs, hasMore: $hasMore, isLoadingMore: $isLoadingMore, currentPage: $currentPage)';
}


}

/// @nodoc
abstract mixin class $BlogsListLoadedCopyWith<$Res> implements $BlogsListStateCopyWith<$Res> {
  factory $BlogsListLoadedCopyWith(BlogsListLoaded value, $Res Function(BlogsListLoaded) _then) = _$BlogsListLoadedCopyWithImpl;
@useResult
$Res call({
 List<BlogModel> blogs, bool hasMore, bool isLoadingMore, int currentPage
});




}
/// @nodoc
class _$BlogsListLoadedCopyWithImpl<$Res>
    implements $BlogsListLoadedCopyWith<$Res> {
  _$BlogsListLoadedCopyWithImpl(this._self, this._then);

  final BlogsListLoaded _self;
  final $Res Function(BlogsListLoaded) _then;

/// Create a copy of BlogsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? blogs = null,Object? hasMore = null,Object? isLoadingMore = null,Object? currentPage = null,}) {
  return _then(BlogsListLoaded(
blogs: null == blogs ? _self._blogs : blogs // ignore: cast_nullable_to_non_nullable
as List<BlogModel>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class BlogsListError implements BlogsListState {
  const BlogsListError(this.message);
  

 final  String message;

/// Create a copy of BlogsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlogsListErrorCopyWith<BlogsListError> get copyWith => _$BlogsListErrorCopyWithImpl<BlogsListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlogsListError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BlogsListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $BlogsListErrorCopyWith<$Res> implements $BlogsListStateCopyWith<$Res> {
  factory $BlogsListErrorCopyWith(BlogsListError value, $Res Function(BlogsListError) _then) = _$BlogsListErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$BlogsListErrorCopyWithImpl<$Res>
    implements $BlogsListErrorCopyWith<$Res> {
  _$BlogsListErrorCopyWithImpl(this._self, this._then);

  final BlogsListError _self;
  final $Res Function(BlogsListError) _then;

/// Create a copy of BlogsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(BlogsListError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
