// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'silver_buy_sell_link_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SilverBuySellLinkState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SilverBuySellLinkState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SilverBuySellLinkState()';
}


}

/// @nodoc
class $SilverBuySellLinkStateCopyWith<$Res>  {
$SilverBuySellLinkStateCopyWith(SilverBuySellLinkState _, $Res Function(SilverBuySellLinkState) __);
}


/// Adds pattern-matching-related methods to [SilverBuySellLinkState].
extension SilverBuySellLinkStatePatterns on SilverBuySellLinkState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( Loading value)?  loading,TResult Function( FoundSingle value)?  foundSingle,TResult Function( FoundClientSells value)?  foundClientSells,TResult Function( NotFound value)?  notFound,TResult Function( Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case FoundSingle() when foundSingle != null:
return foundSingle(_that);case FoundClientSells() when foundClientSells != null:
return foundClientSells(_that);case NotFound() when notFound != null:
return notFound(_that);case Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( Loading value)  loading,required TResult Function( FoundSingle value)  foundSingle,required TResult Function( FoundClientSells value)  foundClientSells,required TResult Function( NotFound value)  notFound,required TResult Function( Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case FoundSingle():
return foundSingle(_that);case FoundClientSells():
return foundClientSells(_that);case NotFound():
return notFound(_that);case Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( Loading value)?  loading,TResult? Function( FoundSingle value)?  foundSingle,TResult? Function( FoundClientSells value)?  foundClientSells,TResult? Function( NotFound value)?  notFound,TResult? Function( Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case FoundSingle() when foundSingle != null:
return foundSingle(_that);case FoundClientSells() when foundClientSells != null:
return foundClientSells(_that);case NotFound() when notFound != null:
return notFound(_that);case Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( SilverSellFindModel sell)?  foundSingle,TResult Function( SilverClientSellsModel clientSells)?  foundClientSells,TResult Function()?  notFound,TResult Function( List<String> messages)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case FoundSingle() when foundSingle != null:
return foundSingle(_that.sell);case FoundClientSells() when foundClientSells != null:
return foundClientSells(_that.clientSells);case NotFound() when notFound != null:
return notFound();case Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( SilverSellFindModel sell)  foundSingle,required TResult Function( SilverClientSellsModel clientSells)  foundClientSells,required TResult Function()  notFound,required TResult Function( List<String> messages)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case FoundSingle():
return foundSingle(_that.sell);case FoundClientSells():
return foundClientSells(_that.clientSells);case NotFound():
return notFound();case Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( SilverSellFindModel sell)?  foundSingle,TResult? Function( SilverClientSellsModel clientSells)?  foundClientSells,TResult? Function()?  notFound,TResult? Function( List<String> messages)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case FoundSingle() when foundSingle != null:
return foundSingle(_that.sell);case FoundClientSells() when foundClientSells != null:
return foundClientSells(_that.clientSells);case NotFound() when notFound != null:
return notFound();case Error() when error != null:
return error(_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements SilverBuySellLinkState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SilverBuySellLinkState.initial()';
}


}




/// @nodoc


class Loading implements SilverBuySellLinkState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SilverBuySellLinkState.loading()';
}


}




/// @nodoc


class FoundSingle implements SilverBuySellLinkState {
  const FoundSingle(this.sell);
  

 final  SilverSellFindModel sell;

/// Create a copy of SilverBuySellLinkState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundSingleCopyWith<FoundSingle> get copyWith => _$FoundSingleCopyWithImpl<FoundSingle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoundSingle&&(identical(other.sell, sell) || other.sell == sell));
}


@override
int get hashCode => Object.hash(runtimeType,sell);

@override
String toString() {
  return 'SilverBuySellLinkState.foundSingle(sell: $sell)';
}


}

/// @nodoc
abstract mixin class $FoundSingleCopyWith<$Res> implements $SilverBuySellLinkStateCopyWith<$Res> {
  factory $FoundSingleCopyWith(FoundSingle value, $Res Function(FoundSingle) _then) = _$FoundSingleCopyWithImpl;
@useResult
$Res call({
 SilverSellFindModel sell
});




}
/// @nodoc
class _$FoundSingleCopyWithImpl<$Res>
    implements $FoundSingleCopyWith<$Res> {
  _$FoundSingleCopyWithImpl(this._self, this._then);

  final FoundSingle _self;
  final $Res Function(FoundSingle) _then;

/// Create a copy of SilverBuySellLinkState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sell = null,}) {
  return _then(FoundSingle(
null == sell ? _self.sell : sell // ignore: cast_nullable_to_non_nullable
as SilverSellFindModel,
  ));
}


}

/// @nodoc


class FoundClientSells implements SilverBuySellLinkState {
  const FoundClientSells(this.clientSells);
  

 final  SilverClientSellsModel clientSells;

/// Create a copy of SilverBuySellLinkState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundClientSellsCopyWith<FoundClientSells> get copyWith => _$FoundClientSellsCopyWithImpl<FoundClientSells>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoundClientSells&&(identical(other.clientSells, clientSells) || other.clientSells == clientSells));
}


@override
int get hashCode => Object.hash(runtimeType,clientSells);

@override
String toString() {
  return 'SilverBuySellLinkState.foundClientSells(clientSells: $clientSells)';
}


}

/// @nodoc
abstract mixin class $FoundClientSellsCopyWith<$Res> implements $SilverBuySellLinkStateCopyWith<$Res> {
  factory $FoundClientSellsCopyWith(FoundClientSells value, $Res Function(FoundClientSells) _then) = _$FoundClientSellsCopyWithImpl;
@useResult
$Res call({
 SilverClientSellsModel clientSells
});




}
/// @nodoc
class _$FoundClientSellsCopyWithImpl<$Res>
    implements $FoundClientSellsCopyWith<$Res> {
  _$FoundClientSellsCopyWithImpl(this._self, this._then);

  final FoundClientSells _self;
  final $Res Function(FoundClientSells) _then;

/// Create a copy of SilverBuySellLinkState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientSells = null,}) {
  return _then(FoundClientSells(
null == clientSells ? _self.clientSells : clientSells // ignore: cast_nullable_to_non_nullable
as SilverClientSellsModel,
  ));
}


}

/// @nodoc


class NotFound implements SilverBuySellLinkState {
  const NotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SilverBuySellLinkState.notFound()';
}


}




/// @nodoc


class Error implements SilverBuySellLinkState {
  const Error({required final  List<String> messages}): _messages = messages;
  

 final  List<String> _messages;
 List<String> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of SilverBuySellLinkState
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
  return 'SilverBuySellLinkState.error(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $SilverBuySellLinkStateCopyWith<$Res> {
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

/// Create a copy of SilverBuySellLinkState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(Error(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
