enum Category { bremsen, reifen, eBike, zubehoer, pflege }

extension CategoryLabel on Category {
  String get label => switch (this) {
    Category.bremsen => 'Bremsen',
    Category.reifen => 'Reifen',
    Category.eBike => 'E-Bike',
    Category.zubehoer => 'Zubehör',
    Category.pflege => 'Pflege',
  };
}
