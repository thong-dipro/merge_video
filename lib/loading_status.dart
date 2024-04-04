enum LoadingStatus {
  initialize,
  loading,
  loaded;

  bool get isInitialize => this == LoadingStatus.initialize;

  bool get isLoading => this == LoadingStatus.loading;

  bool get isLoaded => this == LoadingStatus.loaded;
}
