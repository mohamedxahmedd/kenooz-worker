// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diamond_product_lookup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiamondProductLookupState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiamondProductLookupState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiamondProductLookupState()';
}


}

/// @nodoc
class $DiamondProductLookupStateCopyWith<$Res>  {
$DiamondProductLookupStateCopyWith(DiamondProductLookupState _, $Res Function(DiamondProductLookupState) __);
}


/// Adds pattern-matching-related methods to [DiamondProductLookupState].
extension DiamondProductLookupStatePatterns on DiamondProductLookupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( Loading value)?  loading,TResult Function( FoundDiamond value)?  foundDiamond,TResult Function( FoundStone value)?  foundStone,TResult Function( NotFound value)?  notFound,TResult Function( AlreadySold value)?  alreadySold,TResult Function( InvalidType value)?  invalidType,TResult Function( Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case FoundDiamond() when foundDiamond != null:
return foundDiamond(_that);case FoundStone() when foundStone != null:
return foundStone(_that);case NotFound() when notFound != null:
return notFound(_that);case AlreadySold() when alreadySold != null:
return alreadySold(_that);case InvalidType() when invalidType != null:
return invalidType(_that);case Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( Loading value)  loading,required TResult Function( FoundDiamond value)  foundDiamond,required TResult Function( FoundStone value)  foundStone,required TResult Function( NotFound value)  notFound,required TResult Function( AlreadySold value)  alreadySold,required TResult Function( InvalidType value)  invalidType,required TResult Function( Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case FoundDiamond():
return foundDiamond(_that);case FoundStone():
return foundStone(_that);case NotFound():
return notFound(_that);case AlreadySold():
return alreadySold(_that);case InvalidType():
return invalidType(_that);case Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( Loading value)?  loading,TResult? Function( FoundDiamond value)?  foundDiamond,TResult? Function( FoundStone value)?  foundStone,TResult? Function( NotFound value)?  notFound,TResult? Function( AlreadySold value)?  alreadySold,TResult? Function( InvalidType value)?  invalidType,TResult? Function( Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case FoundDiamond() when foundDiamond != null:
return foundDiamond(_that);case FoundStone() when foundStone != null:
return foundStone(_that);case NotFound() when notFound != null:
return notFound(_that);case AlreadySold() when alreadySold != null:
return alreadySold(_that);case InvalidType() when invalidType != null:
return invalidType(_that);case Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( DiamondProductModel product)?  foundDiamond,TResult Function( StoneProductModel product)?  foundStone,TResult Function()?  notFound,TResult Function()?  alreadySold,TResult Function()?  invalidType,TResult Function( List<String> messages)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case FoundDiamond() when foundDiamond != null:
return foundDiamond(_that.product);case FoundStone() when foundStone != null:
return foundStone(_that.product);case NotFound() when notFound != null:
return notFound();case AlreadySold() when alreadySold != null:
return alreadySold();case InvalidType() when invalidType != null:
return invalidType();case Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( DiamondProductModel product)  foundDiamond,required TResult Function( StoneProductModel product)  foundStone,required TResult Function()  notFound,required TResult Function()  alreadySold,required TResult Function()  invalidType,required TResult Function( List<String> messages)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case FoundDiamond():
return foundDiamond(_that.product);case FoundStone():
return foundStone(_that.product);case NotFound():
return notFound();case AlreadySold():
return alreadySold();case InvalidType():
return invalidType();case Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( DiamondProductModel product)?  foundDiamond,TResult? Function( StoneProductModel product)?  foundStone,TResult? Function()?  notFound,TResult? Function()?  alreadySold,TResult? Function()?  invalidType,TResult? Function( List<String> messages)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case FoundDiamond() when foundDiamond != null:
return foundDiamond(_that.product);case FoundStone() when foundStone != null:
return foundStone(_that.product);case NotFound() when notFound != null:
return notFound();case AlreadySold() when alreadySold != null:
return alreadySold();case InvalidType() when invalidType != null:
return invalidType();case Error() when error != null:
return error(_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements DiamondProductLookupState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiamondProductLookupState.initial()';
}


}




/// @nodoc


class Loading implements DiamondProductLookupState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiamondProductLookupState.loading()';
}


}




/// @nodoc


class FoundDiamond implements DiamondProductLookupState {
  const FoundDiamond(this.product);
  

 final  DiamondProductModel product;

/// Create a copy of DiamondProductLookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundDiamondCopyWith<FoundDiamond> get copyWith => _$FoundDiamondCopyWithImpl<FoundDiamond>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoundDiamond&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,product);

@override
String toString() {
  return 'DiamondProductLookupState.foundDiamond(product: $product)';
}


}

/// @nodoc
abstract mixin class $FoundDiamondCopyWith<$Res> implements $DiamondProductLookupStateCopyWith<$Res> {
  factory $FoundDiamondCopyWith(FoundDiamond value, $Res Function(FoundDiamond) _then) = _$FoundDiamondCopyWithImpl;
@useResult
$Res call({
 DiamondProductModel product
});




}
/// @nodoc
class _$FoundDiamondCopyWithImpl<$Res>
    implements $FoundDiamondCopyWith<$Res> {
  _$FoundDiamondCopyWithImpl(this._self, this._then);

  final FoundDiamond _self;
  final $Res Function(FoundDiamond) _then;

/// Create a copy of DiamondProductLookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(FoundDiamond(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as DiamondProductModel,
  ));
}


}

/// @nodoc


class FoundStone implements DiamondProductLookupState {
  const FoundStone(this.product);
  

 final  StoneProductModel product;

/// Create a copy of DiamondProductLookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundStoneCopyWith<FoundStone> get copyWith => _$FoundStoneCopyWithImpl<FoundStone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoundStone&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,product);

@override
String toString() {
  return 'DiamondProductLookupState.foundStone(product: $product)';
}


}

/// @nodoc
abstract mixin class $FoundStoneCopyWith<$Res> implements $DiamondProductLookupStateCopyWith<$Res> {
  factory $FoundStoneCopyWith(FoundStone value, $Res Function(FoundStone) _then) = _$FoundStoneCopyWithImpl;
@useResult
$Res call({
 StoneProductModel product
});




}
/// @nodoc
class _$FoundStoneCopyWithImpl<$Res>
    implements $FoundStoneCopyWith<$Res> {
  _$FoundStoneCopyWithImpl(this._self, this._then);

  final FoundStone _self;
  final $Res Function(FoundStone) _then;

/// Create a copy of DiamondProductLookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(FoundStone(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as StoneProductModel,
  ));
}


}

/// @nodoc


class NotFound implements DiamondProductLookupState {
  const NotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiamondProductLookupState.notFound()';
}


}




/// @nodoc


class AlreadySold implements DiamondProductLookupState {
  const AlreadySold();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlreadySold);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiamondProductLookupState.alreadySold()';
}


}




/// @nodoc


class InvalidType implements DiamondProductLookupState {
  const InvalidType();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiamondProductLookupState.invalidType()';
}


}




/// @nodoc


class Error implements DiamondProductLookupState {
  const Error({required final  List<String> messages}): _messages = messages;
  

 final  List<String> _messages;
 List<String> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of DiamondProductLookupState
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
  return 'DiamondProductLookupState.error(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $DiamondProductLookupStateCopyWith<$Res> {
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

/// Create a copy of DiamondProductLookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(Error(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
