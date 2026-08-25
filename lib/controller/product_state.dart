import '../models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductAdding extends ProductState {}

class ProductAdded extends ProductState {}

class ProductAddError extends ProductState {
  final String message;
  ProductAddError(this.message);
}
