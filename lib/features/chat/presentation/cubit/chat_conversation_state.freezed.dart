// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatConversationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationState()';
}


}

/// @nodoc
class $ChatConversationStateCopyWith<$Res>  {
$ChatConversationStateCopyWith(ChatConversationState _, $Res Function(ChatConversationState) __);
}


/// Adds pattern-matching-related methods to [ChatConversationState].
extension ChatConversationStatePatterns on ChatConversationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( Loading value)?  loading,TResult Function( Success value)?  success,TResult Function( Error value)?  error,TResult Function( EndChatSuccess value)?  endChatSuccess,TResult Function( ActionError value)?  actionError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Success() when success != null:
return success(_that);case Error() when error != null:
return error(_that);case EndChatSuccess() when endChatSuccess != null:
return endChatSuccess(_that);case ActionError() when actionError != null:
return actionError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( Loading value)  loading,required TResult Function( Success value)  success,required TResult Function( Error value)  error,required TResult Function( EndChatSuccess value)  endChatSuccess,required TResult Function( ActionError value)  actionError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case Success():
return success(_that);case Error():
return error(_that);case EndChatSuccess():
return endChatSuccess(_that);case ActionError():
return actionError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( Loading value)?  loading,TResult? Function( Success value)?  success,TResult? Function( Error value)?  error,TResult? Function( EndChatSuccess value)?  endChatSuccess,TResult? Function( ActionError value)?  actionError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Success() when success != null:
return success(_that);case Error() when error != null:
return error(_that);case EndChatSuccess() when endChatSuccess != null:
return endChatSuccess(_that);case ActionError() when actionError != null:
return actionError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ChatWithMessagesModel chat,  bool isSending,  bool isEnding)?  success,TResult Function( List<String> messages)?  error,TResult Function()?  endChatSuccess,TResult Function( List<String> messages)?  actionError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Success() when success != null:
return success(_that.chat,_that.isSending,_that.isEnding);case Error() when error != null:
return error(_that.messages);case EndChatSuccess() when endChatSuccess != null:
return endChatSuccess();case ActionError() when actionError != null:
return actionError(_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ChatWithMessagesModel chat,  bool isSending,  bool isEnding)  success,required TResult Function( List<String> messages)  error,required TResult Function()  endChatSuccess,required TResult Function( List<String> messages)  actionError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case Success():
return success(_that.chat,_that.isSending,_that.isEnding);case Error():
return error(_that.messages);case EndChatSuccess():
return endChatSuccess();case ActionError():
return actionError(_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ChatWithMessagesModel chat,  bool isSending,  bool isEnding)?  success,TResult? Function( List<String> messages)?  error,TResult? Function()?  endChatSuccess,TResult? Function( List<String> messages)?  actionError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Success() when success != null:
return success(_that.chat,_that.isSending,_that.isEnding);case Error() when error != null:
return error(_that.messages);case EndChatSuccess() when endChatSuccess != null:
return endChatSuccess();case ActionError() when actionError != null:
return actionError(_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ChatConversationState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationState.initial()';
}


}




/// @nodoc


class Loading implements ChatConversationState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationState.loading()';
}


}




/// @nodoc


class Success implements ChatConversationState {
  const Success({required this.chat, this.isSending = false, this.isEnding = false});
  

 final  ChatWithMessagesModel chat;
@JsonKey() final  bool isSending;
@JsonKey() final  bool isEnding;

/// Create a copy of ChatConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<Success> get copyWith => _$SuccessCopyWithImpl<Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success&&(identical(other.chat, chat) || other.chat == chat)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isEnding, isEnding) || other.isEnding == isEnding));
}


@override
int get hashCode => Object.hash(runtimeType,chat,isSending,isEnding);

@override
String toString() {
  return 'ChatConversationState.success(chat: $chat, isSending: $isSending, isEnding: $isEnding)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<$Res> implements $ChatConversationStateCopyWith<$Res> {
  factory $SuccessCopyWith(Success value, $Res Function(Success) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 ChatWithMessagesModel chat, bool isSending, bool isEnding
});




}
/// @nodoc
class _$SuccessCopyWithImpl<$Res>
    implements $SuccessCopyWith<$Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success _self;
  final $Res Function(Success) _then;

/// Create a copy of ChatConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chat = null,Object? isSending = null,Object? isEnding = null,}) {
  return _then(Success(
chat: null == chat ? _self.chat : chat // ignore: cast_nullable_to_non_nullable
as ChatWithMessagesModel,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isEnding: null == isEnding ? _self.isEnding : isEnding // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class Error implements ChatConversationState {
  const Error({required final  List<String> messages}): _messages = messages;
  

 final  List<String> _messages;
 List<String> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ChatConversationState
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
  return 'ChatConversationState.error(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $ChatConversationStateCopyWith<$Res> {
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

/// Create a copy of ChatConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(Error(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class EndChatSuccess implements ChatConversationState {
  const EndChatSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EndChatSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationState.endChatSuccess()';
}


}




/// @nodoc


class ActionError implements ChatConversationState {
  const ActionError({required final  List<String> messages}): _messages = messages;
  

 final  List<String> _messages;
 List<String> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ChatConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionErrorCopyWith<ActionError> get copyWith => _$ActionErrorCopyWithImpl<ActionError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionError&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ChatConversationState.actionError(messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ActionErrorCopyWith<$Res> implements $ChatConversationStateCopyWith<$Res> {
  factory $ActionErrorCopyWith(ActionError value, $Res Function(ActionError) _then) = _$ActionErrorCopyWithImpl;
@useResult
$Res call({
 List<String> messages
});




}
/// @nodoc
class _$ActionErrorCopyWithImpl<$Res>
    implements $ActionErrorCopyWith<$Res> {
  _$ActionErrorCopyWithImpl(this._self, this._then);

  final ActionError _self;
  final $Res Function(ActionError) _then;

/// Create a copy of ChatConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,}) {
  return _then(ActionError(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
