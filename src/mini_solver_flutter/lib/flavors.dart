enum Flavor {
  dev,
  production,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Mini Solver';
      case Flavor.production:
        return 'Mini Solver';
    }
  }

}
