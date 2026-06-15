/// The Lists module's public, module-agnostic API. This is ALL another module
/// (e.g. the daily brief) is allowed to know about Lists — never its tables,
/// DAO, or widgets. Implemented internally by the Lists repository.
abstract interface class ListsApi {
  Stream<int> watchOpenItemCount();
  Stream<int> watchListCount();
}
