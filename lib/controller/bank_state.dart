import '../models/bank_model.dart';

abstract class BankState {}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BankLoaded extends BankState {
  final BankModel? bank;
  BankLoaded(this.bank);
}

class BankSaving extends BankState {}

class BankSaved extends BankState {
  final BankModel bank;
  BankSaved(this.bank);
}

class BankError extends BankState {
  final String message;
  BankError(this.message);
}

class BankSaveError extends BankState {
  final String message;
  BankSaveError(this.message);
}
