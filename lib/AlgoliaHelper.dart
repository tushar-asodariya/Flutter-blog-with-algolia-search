import 'dart:convert';

class SimpleObject {
  const SimpleObject({
    this.title,
    this.desc
  });

  final String title;
  final String desc;


  factory SimpleObject.fromJson(Map<String, dynamic> jsonStr) {
    if (jsonStr == null) {
      throw FormatException("Null JSON provided to SimpleObject");
    }

    SimpleObject2 temp = SimpleObject2.fromJson(json.decode(jsonStr.toString()) );
    return SimpleObject(
      title: temp.title,
      desc: temp.desc,

    );
  }
}

class SimpleObject2 {
  const SimpleObject2({
    this.title,
    this.desc
  });

  final String title;
  final String desc;


  factory SimpleObject2.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to SimpleObject");
    }

    return SimpleObject2(
      title: json['title'],
      desc: json['desc'],

    );
  }
}
