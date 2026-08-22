enum Category { bremsen, antrieb, reifen, eBike, laufraeder, zubehoer, pflege }

extension CategoryLabel on Category {
  String get label => switch (this) {
    Category.bremsen => 'Bremsen',
    Category.antrieb => 'Antrieb',
    Category.reifen => 'Reifen',
    Category.eBike => 'E-Bike',
    Category.laufraeder => 'Laufräder',
    Category.zubehoer => 'Zubehör',
    Category.pflege => 'Pflege',
  };
}
