import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/bank_service.dart';
import '../models/bank_model.dart';
import 'bank_state.dart';

class BankCubit extends Cubit<BankState> {
  final BankService _bankService;

  BankCubit(this._bankService) : super(BankInitial());

  Future<void> fetchBankDetails() async {
    try {
      emit(BankLoading());
      final bank = await _bankService.getBankDetails();
      emit(BankLoaded(bank));
    } catch (e) {
      emit(BankError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> saveBankDetails(BankModel bank) async {
    try {
      emit(BankSaving());
      BankModel savedBank;
      if (bank.id != null && bank.id!.isNotEmpty) {
        savedBank = await _bankService.updateBank(bank);
      } else {
        savedBank = await _bankService.createBank(bank);
      }
      emit(BankSaved(savedBank));
      emit(BankLoaded(savedBank));
    } catch (e) {
      emit(BankSaveError(e.toString().replaceAll('Exception: ', '')));
      // Restore loaded state after showing error
      fetchBankDetails();
    }
  }
}
