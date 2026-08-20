import '../models/setting_model.dart';

abstract class SettingState {}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final SettingModel setting;
  SettingLoaded(this.setting);
}

class SettingError extends SettingState {
  final String message;
  SettingError(this.message);
}

class SettingUpdating extends SettingState {}

class SettingUpdated extends SettingState {
  final SettingModel setting;
  SettingUpdated(this.setting);
}

class SettingUpdateError extends SettingState {
  final String message;
  SettingUpdateError(this.message);
}
