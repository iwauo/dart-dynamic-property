import 'dart:convert';
import 'package:test/test.dart';

import '../lib/dynamic_properties.dart';

class Bean extends BaseBean with DynamicProperties {}

class BaseBean {
  String inheritedMethod() {
    return "from BaseBean";
  }
}


abstract class SingleValuedReadOnlyProps {
  String get strValue;
  int get intValue;
}

class SingleValuedReadOnlyPropsBean
  with DynamicProperties
  implements SingleValuedReadOnlyProps {

  SingleValuedReadOnlyPropsBean() {
    defineProperties({
      "strValue": "hoge",
      "intValue": 42,
    });
  }
}

void main() {
  group("An Object with DynamicProperties", () {
    test("can be added a new properties at runtime.", () {
      dynamic bean = Bean()..defineProperties({
        "strValue": "hoge",
        "intValue": 42,
      });
      expect(bean.strValue, "hoge");
      expect(bean.intValue, 42);
    });

    test("allows to update its properties.",  () {
      dynamic bean = Bean()..defineProperties({
        "strValue": "hoge",
        "intValue": 42,
      });
      bean
      ..strValue = "fuga"
      ..intValue = null;

      expect(bean.strValue, "fuga");
      expect(bean.intValue, isNull);
    });

    test("can be added a new method at runtime.", () {
      dynamic bean = Bean()
      ..defineProperties({
        "strValue": "hoge",
        "intValue": 42,
      })
      ..defineMethods({
        "asCsv": (self, _) => [self.strValue, self.intValue].join(',')
      });
      expect(bean.asCsv(), "hoge,42");
    });

    test("can be interpreted in a serializable form with toJson().", () {
      dynamic bean = Bean()..defineProperties({
        "strValue": "hoge",
        "intValue": 42,
        "timestamp": DateTime.parse("2019-11-29T20:00:00"),
      });
      expect(jsonEncode(bean), "{" +
        "\"strValue\":\"hoge\"," +
        "\"intValue\":42," +
        "\"timestamp\":\"2019-11-29T20:00:00.000\"" +
        "}"
      );
    });

    test("#toJson() does not include an entry with null value.", () {
      dynamic bean = Bean()..defineProperties({
        "strValue": null,
        "intValue": 42,
        "timestamp": null
      });
      expect(jsonEncode(bean), "{" +
        "\"intValue\":42" +
        "}"
      );
    });

    test("can track changes in its property values.", () {
      dynamic bean = Bean()..defineProperties({
        "strValue": "hoge",
        "intValue": 42,
      });
      Map<String, dynamic> diff = bean.pushLayer();
      expect(diff.isEmpty, true);

      bean.strValue = "fuga";
      expect(diff.length, 1);
      expect(diff["strValue"], "fuga");

      bean.intValue = 8080;
      expect(diff.length, 2);
      expect(diff["intValue"], 8080);
    });

    test("can create a its clone with #toMap()", () {
      dynamic bean = Bean()..defineProperties({
        "strValue": "hoge",
        "intValue": 42,
      });
      dynamic clone = Bean()..defineProperties(bean.toMap());
      expect(clone.strValue, "hoge");
      expect(clone.intValue, 42);
    });

    test("can be used with class inheritance.", () {
      final bean = Bean();
      expect(bean.inheritedMethod(), "from BaseBean");
    });
  });
}
