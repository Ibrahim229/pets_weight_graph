import 'dart:convert';

class Weight {
  Weight({
    this.id,
    this.weight,
    this.date,
  });

  int? id;
  double? weight;
  DateTime? date;

  factory Weight.fromMap(Map<String, dynamic> json) => Weight(
        id: json["id"],
        weight:double.tryParse(json["weight"].toString()),
        date: DateTime.parse(json["date"]),
      );
}
