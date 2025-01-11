class RollNumbers {
  static List<int> a5 = [
    181,
    182,
    183,
    184,
    185,
    186,
    187,
    188,
    189,
    190,
    191,
    192,
    193,
    194,
    195,
    196,
    197,
    198,
    199,
    200
  ];
  static List<int> a6 = [
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    209,
    210,
    211,
    212,
    213,
    214,
    215,
    216,
    217,
    218,
    219,
    220
  ];
  static List<int> b1 = [
    301,
    302,
    303,
    304,
    305,
    306,
    307,
    308,
    309,
    310,
    311,
    312,
    313,
    314,
    315,
    316,
    317,
    318,
    319,
    320
  ];
  static List<int> b2 = [
    321,
    322,
    323,
    324,
    325,
    326,
    327,
    328,
    329,
    330,
    331,
    332,
    333,
    334,
    335,
    336,
    337,
    338,
    339,
    340,
    341
  ];
  static List<int> b3 = [
    342,
    343,
    344,
    345,
    346,
    347,
    348,
    349,
    350,
    351,
    352,
    353,
    354,
    355,
    356,
    357,
    358,
    359,
    360,
    361,
    362
  ];
  static List<int> c1 = [
    501,
    502,
    503,
    504,
    505,
    506,
    507,
    508,
    509,
    510,
    511,
    512,
    513,
    514,
    515,
    516,
    517,
    518,
    519
  ];

  static Map<String, List<int>> rollNumbers = {
    "a5": a5,
    "a6": a6,
    "b1": b1,
    "b2": b2,
    "b3": b3,
    "c1": c1,
  };

  static String getBatchByRollNumber(int number) {
    String batch = "";
    if (a5.contains(number)) {
      batch = "a1";
    } else if (a6.contains(number)) {
      batch = "a2";
    } else if (b1.contains(number)) {
      batch = "b1";
    } else if (b2.contains(number)) {
      batch = "b2";
    } else if (b3.contains(number)) {
      batch = "b3";
    } else if (c1.contains(number)) {
      batch = "c1";
    } else {
      return "Unknown";
    }

    return batch.trim().toUpperCase();
  }
}
