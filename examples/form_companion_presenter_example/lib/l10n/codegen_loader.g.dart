// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en = {
  "titleTemplate": "Example of form_companion_presenter: {screenName}",
  "home": {
    "title": "Home",
    "accountHeader": "Your last input Account model:",
    "bookingHeader": "Your last input Booking model:"
  },
  "manual": {
    "vanilla": {
      "title": "Manual validation, vanilla Form for Account"
    },
    "flutterFormBuilderAccount": {
      "title": "Manual validation, Flutter Form Builder for Account"
    },
    "flutterFormBuilderBooking": {
      "title": "Manual validation, Flutter Form Builder for Booking"
    }
  },
  "auto": {
    "vanilla": {
      "title": "Auto validation, vanilla Form for Account"
    },
    "flutterFormBuilderAccount": {
      "title": "Auto validation, Flutter Form Builder for Account"
    },
    "flutterFormBuilderBooking": {
      "title": "Auto validation, Flutter Form Builder for Booking"
    }
  },
  "id": {
    "label": "User ID *",
    "hint": "Enter your user ID which should be unique."
  },
  "name": {
    "label": "Nick name *",
    "hint": "Enter your nick name."
  },
  "gender": {
    "label": "Sex *",
    "hint": "Select your sex.",
    "enumNotKnown": "Not known",
    "enumMale": "Male",
    "enumFemale": "Female",
    "enumNotApplicable": "N/A"
  },
  "age": {
    "label": "Age *",
    "hint": "Enter your age in number."
  },
  "preferredRegions": {
    "label": "Preferred regions",
    "hint": "Select your preferred regions."
  },
  "region": {
    "afurika": "Afurika",
    "asia": "Asia",
    "australia": "Australia",
    "europe": "Europe",
    "northAmelica": "North Amelica",
    "southAmelica": "South Amelica"
  },
  "booking": {
    "captionTemplate": {
      "existing": "Welcome back {userName}! Do you want to modify booking {bookingId}?",
      "new": "Welcome {userName}! Input following to book now!"
    }
  },
  "stay": {
    "label": "Stay *",
    "hint": "Specify stay period."
  },
  "specialOffer": {
    "description": "You can get special offer! When do you want to receive?",
    "label": "When will you receive special offer? *",
    "hint": "Specify the day in your stay."
  },
  "roomType": {
    "label": "Room type *",
    "hint": "Specify room type.",
    "standard": "Standard",
    "delux": "Delux",
    "suite": "Suite"
  },
  "mealOffers": {
    "label": "Special meal offers",
    "hint": "For other offers, tell us with note on end of this input form."
  },
  "mealType": {
    "halal": "Halal",
    "vegan": "Vegan"
  },
  "smoking": {
    "title": "I want to do smoking in my room",
    "label": "Smoking *",
    "hint": "Specify you want do smoking or not. Note that you cannot do smoking in any space outside of the room."
  },
  "persons": {
    "label": "Persons *",
    "hint": "Cound children under 12 years old as 0.5, and round up in total."
  },
  "babyBeds": {
    "label": "Baby beds *",
    "hint": "Specify baby beds. If you want to more than 2 beds, tell us with note on end of this input form."
  },
  "preferredPrice": {
    "label": "Preferred price range *",
    "hint": "Specify preferred price range you want to pay."
  },
  "note": {
    "label": "Note",
    "hint": "Enter note of this booking including special meal offers."
  },
  "acceptsTermsOfUse": {
    "title": "I read terms of use (*) and accept it.",
    "message": "Accepting the terms of use is required."
  },
  "submit": "Submit"
};
static const Map<String,dynamic> ja = {
  "titleTemplate": "form_companion_presenter の例：{screenName}",
  "home": {
    "title": "ホーム",
    "accountHeader": "最後に入力した Account モデル:",
    "bookingHeader": "最後に入力した Booking モデル:"
  },
  "manual": {
    "vanilla": {
      "title": "手動バリデーション、Account 用の素の Form"
    },
    "flutterFormBuilderAccount": {
      "title": "手動バリデーション、Account 用の Flutter Form Builder"
    },
    "flutterFormBuilderBooking": {
      "title": "手動バリデーション、Booking 用の Flutter Form Builder"
    }
  },
  "auto": {
    "vanilla": {
      "title": "自動バリデーション、Account 用の素の Form"
    },
    "flutterFormBuilderAccount": {
      "title": "自動バリデーション、Account 用の Flutter Form Builder"
    },
    "flutterFormBuilderBooking": {
      "title": "自動バリデーション、Booking 用の Flutter Form Builder"
    }
  },
  "id": {
    "label": "ユーザーID *",
    "hint": "他の人とは異なるであろうユーザーIDを入力してください。"
  },
  "name": {
    "label": "ニックネーム *",
    "hint": "ニックネームを入力してください。"
  },
  "gender": {
    "label": "性別 *",
    "hint": "性別を選択してください。",
    "enumNotKnown": "不明",
    "enumMale": "男性",
    "enumFemale": "女性",
    "enumNotApplicable": "N/A"
  },
  "age": {
    "label": "年齢 *",
    "hint": "年齢を数字で入力してください。"
  },
  "preferredRegions": {
    "label": "お好みの地域",
    "hint": "お好みの地域を選択してください。"
  },
  "region": {
    "afurika": "アフリカ",
    "asia": "アジア",
    "australia": "オーストラリア",
    "europe": "ヨーロッパ",
    "northAmelica": "北アメリカ",
    "southAmelica": "南アメリカ"
  },
  "booking": {
    "captionTemplate": {
      "existing": "{userName} 様、いつもお世話になっております。ご予約 {bookingId} の変更でよろしいでしょうか？",
      "new": "{userName} 様の新規ご予約"
    }
  },
  "stay": {
    "label": "滞在期間 *",
    "hint": "滞在期間を指定してください。"
  },
  "specialOffer": {
    "description": "現在特別なプレゼントをご用意しております。受け取り日を指定してください。",
    "label": "特別プレゼントの受取日 *",
    "hint": "滞在期間中の日にちを指定してください。"
  },
  "roomType": {
    "label": "お部屋のタイプ *",
    "hint": "お部屋のタイプを指定してください。",
    "standard": "標準",
    "delux": "デラックス",
    "suite": "スイート"
  },
  "mealOffers": {
    "label": "特別なお食事のご注文",
    "hint": "ここにないご注文については、メモにご記入ください。"
  },
  "mealType": {
    "halal": "ハラール",
    "vegan": "ビーガン"
  },
  "smoking": {
    "title": "部屋での喫煙を希望します",
    "label": "喫煙 *",
    "hint": "喫煙の有無を指定してください。館内は喫煙可能な部屋を除き禁煙ですのでご了承ください。"
  },
  "persons": {
    "label": "人数 *",
    "hint": "12 歳未満のお子様は 0.5 人として数え、合計の人数は切り上げてください。"
  },
  "babyBeds": {
    "label": "ベビーベッド *",
    "hint": "ベビーベッドの数を指定してください。2 つよりも多く必要な場合はメモにご記入ください。"
  },
  "preferredPrice": {
    "label": "希望価格帯 *",
    "hint": "支払い金額の希望価格帯を入力してください。"
  },
  "note": {
    "label": "メモ",
    "hint": "特別なお食事へのご注文含め、この予約に関するメモを入力してください。"
  },
  "acceptsTermsOfUse": {
    "title": "ご利用に関する注意事項(*)を読んだ上で同意します。",
    "message": "ご利用に関する注意事項に同意していただく必要があります。"
  },
  "submit": "送信"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ja": ja};
}
