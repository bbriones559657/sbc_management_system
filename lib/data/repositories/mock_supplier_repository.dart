import '../../domain/repositories/supplier_repository.dart';
import '../../models/supplier_record.dart';
import '../prototype_data_store.dart';

class MockSupplierRepository implements SupplierRepository {
  MockSupplierRepository([PrototypeDataStore? store])
      : _store = store ?? PrototypeDataStore();

  final PrototypeDataStore _store;

  @override
  Future<List<SupplierRecord>> getSuppliers() async {
    return List<SupplierRecord>.unmodifiable(_store.suppliers);
  }

  @override
  Future<SupplierRecord?> getSupplierById(String id) async {
    for (final supplier in _store.suppliers) {
      if (supplier.id == id) return supplier;
    }
    return null;
  }

  @override
  Future<void> createSupplier(SupplierRecord supplier) async {
    _store.suppliers.add(supplier);
    _store.markChanged();
  }

  @override
  Future<void> updateSupplier(SupplierRecord supplier) async {
    final index = _store.suppliers.indexWhere((entry) => entry.id == supplier.id);
    if (index == -1) return;
    _store.suppliers[index] = supplier;
    _store.markChanged();
  }

  @override
  Future<void> deleteSupplier(String id) async {
    final index = _store.suppliers.indexWhere((supplier) => supplier.id == id);
    if (index == -1) return;
    _store.suppliers[index] = _store.suppliers[index].copyWith(status: 'Inactive');
    _store.markChanged();
  }
}
