import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';
import '../service/product_service.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService _productService;
  List<ProductModel> _allProducts = [];

  ProductCubit(this._productService) : super(ProductInitial());

  Future<void> getProducts({bool refresh = false}) async {
    if (!refresh && state is ProductLoaded) return;
    emit(ProductLoading());
    try {
      _allProducts = await _productService.getProducts();
      emit(ProductLoaded(_allProducts));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(ProductLoaded(_allProducts));
      return;
    }
    final filtered = _allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    emit(ProductLoaded(filtered));
  }

  Future<void> addProduct(ProductModel product) async {
    emit(ProductAdding());
    try {
      await _productService.createProduct(product);
      emit(ProductAdded());
      getProducts(refresh: true);
    } catch (e) {
      emit(ProductAddError(e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    emit(ProductAdding());
    try {
      await _productService.updateProduct(product);
      emit(ProductAdded());
      getProducts(refresh: true);
    } catch (e) {
      emit(ProductAddError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      getProducts(refresh: true);
    } catch (e) {
      // Silently handle error or could emit state
    }
  }
}
