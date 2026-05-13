// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_lookup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductLookupState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductLookupState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductLookupState()';
}


}

/// @nodoc
class $ProductLookupStateCopyWith<$Res>  {
$ProductLookupStateCopyWith(ProductLookupState _, $Res Function(ProductLookupState) __);
}


/// Adds pattern-matching-related methods to [ProductLookupState].
extension ProductLookupStatePatterns on ProductLookupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( Loading value)?  loading,TResult Function( Found value)?  found,TResult Function( NotFound value)?  notFound,TResult Function( AlreadySold value)?  alreadySold,TResult Function( Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Found() when found != null:
return found(_that);case NotFound() when notFound != null:
return notFound(_that);case AlreadySold() when alreadySold != null:
return alreadySold(_that);case Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( Loading value)  loading,required TResult Function( Found value)  found,required TResult Function( NotFound value)  notFound,required TResult Function( AlreadySold value)  alreadySold,required TResult Function( Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case Found():
return found(_that);case NotFound():
return notFound(_that);case AlreadySold():
return alreadySold(_that);case Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( Loading value)?  loading,TResult? Function( Found value)?  found,TResult? Function( NotFound value)?  notFound,TResult? Function( AlreadySold value)?  alreadySold,TResult? Function( Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Found() when found != null:
return found(_that);case NotFound() when notFound != null:
return notFound(_that);case AlreadySold() when alreadySold != null:
return alreadySold(_that);case Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( GoldProductModel product)?  found,TResult Function()?  notFound,TResult Function()?  alreadySold,TResult Function( List<String> messages)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Found() when found != null:
return found(_that.product);case NotFound() when notFound != null:
return notFound();case AlreadySold() when alreadySold != null:
return alreadySold();case Error() when error != null:
return error(_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( GoldProductModel product)  found,required TResult Function()  notFound,required TResult Function()  alreadySold,required TResult Function( List<String> messages)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case Found():
return found(_that.product);case NotFound():
return notFound();case AlreadySold():
return alreadySold();case Error():
return error(_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( GoldProductModel product)?  found,TResult? Function()?  notFound,TResult? Function()?  alreadySold,TResult? Function( List<String> messages)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Found() when found != null:
return found(_that.product);case NotFound() when notFound != null:
return notFound();case AlreadySold() when alreadySold != null:
return alreadySold();case Error() when error != null:
return error(_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ProductLookupState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductLookupState.initial()';
}


}




/// @nodoc


class Loading implements ProductLookupState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductLookupState.loading()';
}


}




/// @nodoc


class Found implements ProductLookupState {
  const Found(this.product);
  

 final  GoldProductModel product;

/// Create a copy of ProductLookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundCopyWith<Found> get copyWith => _$FoundCopyWithImpl<Found>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Found&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,product);

@override
String toString() {
  return 'ProductLookupState.found(product: $product)';
}


}

/// @nodoc
abstract mixin class $FoundCopyWith<$Res> implements $ProductLookupStateCopyWith<$Res> {
  factory $FoundCopyWith(Found value, $Res Function(Found) _then) = _$FoundCopyWithImpl;
@useResult
$Res call({
 GoldProductModel product
});




}
/// @nodoc
class _$FoundCopyWithImpl<$Res>
    implements $FoundCopyWith<$Res> {
  _$FoundCopyWithImpl(this._self, this._then);

  final Found _self;
  final $Res Function(Found) _then;

/// Create a copy of ProductLookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(Found(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as GoldProductModel,
  ));
}


}

/// @nodoc


class NotFound implements ProductLookupState {
  const NotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductLookupState.notFound()';
}


}




/// @nodoc


class AlreadySold implements ProductLookupState {
  const AlreadySold();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlreadySold);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductLookupState.alreadySold()';
}


}




/// @nodoc


class Error implements ProductLookupState {
  const Error({required final  List<String> messages}): _messages = messages;
  

 final  List<String> _messages;
 List<String> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ProductLookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorCopyWith<Error> get copyWith => _$ErrorCopyWithImpl<Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Error&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ProductLookupState.error(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $ProductLookupStateCopyWith<$Res> {
  factory $ErrorCopyWith(Error value, $Res Function(Error) _then) = _$ErrorCopyWithImpl;
@useResult
$Res call({
 List<String> messages
});




}
/// @nodoc
class _$ErrorCopyWithImpl<$Res>
    implements $ErrorCopyWith<$Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error _self;
  final $Res Function(Error) _then;

/// Create a copy of ProductLookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(Error(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
