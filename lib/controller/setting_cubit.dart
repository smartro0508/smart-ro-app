import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/setting_service.dart';
import '../models/setting_model.dart';
import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingService _settingService;
  SettingModel? _currentSetting;

  SettingCubit(this._settingService) : super(SettingInitial());

  void getSettings() async {
    emit(SettingLoading());
    try {
      _currentSetting = await _settingService.getSettings();
      emit(SettingLoaded(_currentSetting!));
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(SettingError(errorMessage));
    }
  }

  void updateSettings(SettingModel setting) async {
    emit(SettingUpdating());
    try {
      _currentSetting = await _settingService.updateSettings(setting);
      emit(SettingUpdated(_currentSetting!));
      // Optionally return to loaded state
      emit(SettingLoaded(_currentSetting!));
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(SettingUpdateError(errorMessage));
      if (_currentSetting != null) {
        emit(SettingLoaded(_currentSetting!));
      }
    }
  }
}
