// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gold_buy_client_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoldBuyClientSearchState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldBuyClientSearchState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GoldBuyClientSearchState()';
}


}

/// @nodoc
class $GoldBuyClientSearchStateCopyWith<$Res>  {
$GoldBuyClientSearchStateCopyWith(GoldBuyClientSearchState _, $Res Function(GoldBuyClientSearchState) __);
}


/// Adds pattern-matching-related methods to [GoldBuyClientSearchState].
extension GoldBuyClientSearchStatePatterns on GoldBuyClientSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( Loading value)?  loading,TResult Function( Found value)?  found,TResult Function( NotFound value)?  notFound,TResult Function( Created value)?  created,TResult Function( Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Found() when found != null:
return found(_that);case NotFound() when notFound != null:
return notFound(_that);case Created() when created != null:
return created(_that);case Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( Loading value)  loading,required TResult Function( Found value)  found,required TResult Function( NotFound value)  notFound,required TResult Function( Created value)  created,required TResult Function( Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case Found():
return found(_that);case NotFound():
return notFound(_that);case Created():
return created(_that);case Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( Loading value)?  loading,TResult? Function( Found value)?  found,TResult? Function( NotFound value)?  notFound,TResult? Function( Created value)?  created,TResult? Function( Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Found() when found != null:
return found(_that);case NotFound() when notFound != null:
return notFound(_that);case Created() when created != null:
return created(_that);case Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ClientModel client)?  found,TResult Function()?  notFound,TResult Function( ClientModel client)?  created,TResult Function( List<String> messages)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Found() when found != null:
return found(_that.client);case NotFound() when notFound != null:
return notFound();case Created() when created != null:
return created(_that.client);case Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ClientModel client)  found,required TResult Function()  notFound,required TResult Function( ClientModel client)  created,required TResult Function( List<String> messages)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case Found():
return found(_that.client);case NotFound():
return notFound();case Created():
return created(_that.client);case Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ClientModel client)?  found,TResult? Function()?  notFound,TResult? Function( ClientModel client)?  created,TResult? Function( List<String> messages)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Found() when found != null:
return found(_that.client);case NotFound() when notFound != null:
return notFound();case Created() when created != null:
return created(_that.client);case Error() when error != null:
return error(_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements GoldBuyClientSearchState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GoldBuyClientSearchState.initial()';
}


}




/// @nodoc


class Loading implements GoldBuyClientSearchState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GoldBuyClientSearchState.loading()';
}


}




/// @nodoc


class Found implements GoldBuyClientSearchState {
  const Found(this.client);
  

 final  ClientModel client;

/// Create a copy of GoldBuyClientSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundCopyWith<Found> get copyWith => _$FoundCopyWithImpl<Found>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Found&&(identical(other.client, client) || other.client == client));
}


@override
int get hashCode => Object.hash(runtimeType,client);

@override
String toString() {
  return 'GoldBuyClientSearchState.found(client: $client)';
}


}

/// @nodoc
abstract mixin class $FoundCopyWith<$Res> implements $GoldBuyClientSearchStateCopyWith<$Res> {
  factory $FoundCopyWith(Found value, $Res Function(Found) _then) = _$FoundCopyWithImpl;
@useResult
$Res call({
 ClientModel client
});




}
/// @nodoc
class _$FoundCopyWithImpl<$Res>
    implements $FoundCopyWith<$Res> {
  _$FoundCopyWithImpl(this._self, this._then);

  final Found _self;
  final $Res Function(Found) _then;

/// Create a copy of GoldBuyClientSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? client = null,}) {
  return _then(Found(
null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as ClientModel,
  ));
}


}

/// @nodoc


class NotFound implements GoldBuyClientSearchState {
  const NotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GoldBuyClientSearchState.notFound()';
}


}




/// @nodoc


class Created implements GoldBuyClientSearchState {
  const Created(this.client);
  

 final  ClientModel client;

/// Create a copy of GoldBuyClientSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatedCopyWith<Created> get copyWith => _$CreatedCopyWithImpl<Created>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Created&&(identical(other.client, client) || other.client == client));
}


@override
int get hashCode => Object.hash(runtimeType,client);

@override
String toString() {
  return 'GoldBuyClientSearchState.created(client: $client)';
}


}

/// @nodoc
abstract mixin class $CreatedCopyWith<$Res> implements $GoldBuyClientSearchStateCopyWith<$Res> {
  factory $CreatedCopyWith(Created value, $Res Function(Created) _then) = _$CreatedCopyWithImpl;
@useResult
$Res call({
 ClientModel client
});




}
/// @nodoc
class _$CreatedCopyWithImpl<$Res>
    implements $CreatedCopyWith<$Res> {
  _$CreatedCopyWithImpl(this._self, this._then);

  final Created _self;
  final $Res Function(Created) _then;

/// Create a copy of GoldBuyClientSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? client = null,}) {
  return _then(Created(
null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as ClientModel,
  ));
}


}

/// @nodoc


class Error implements GoldBuyClientSearchState {
  const Error({required final  List<String> messages}): _messages = messages;
  

 final  List<String> _messages;
 List<String> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of GoldBuyClientSearchState
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
  return 'GoldBuyClientSearchState.error(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $GoldBuyClientSearchStateCopyWith<$Res> {
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

/// Create a copy of GoldBuyClientSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(Error(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
