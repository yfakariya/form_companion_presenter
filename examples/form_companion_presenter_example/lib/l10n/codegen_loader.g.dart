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
  "manual": {
    "vanilla": {
      "title": "Manual validation, vanilla Form"
    },
    "flutterFormBuilder": {
      "title": "Manual validation, Flutter Form Builder"
    }
  },
  "auto": {
    "vanilla": {
      "title": "Auto validation, vanilla Form"
    },
    "flutterFormBuilder": {
      "title": "Auto validation, Flutter Form Builder"
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
  "sex": {
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
  "note": {
    "label": "Note",
    "hint": "Enter note for you."
  },
  "submit": "Submit"
};
static const Map<String,dynamic> ja = {
  "titleTemplate": "form_companion_presenter の例：{screenName}",
  "manual": {
    "vanilla": {
      "title": "手動バリデーション、素の Form"
    },
    "flutterFormBuilder": {
      "title": "手動バリデーション、Flutter Form Builder"
    }
  },
  "auto": {
    "vanilla": {
      "title": "自動バリデーション、素の Form"
    },
    "flutterFormBuilder": {
      "title": "自動バリデーション、Flutter Form Builder"
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
  "sex": {
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
  "note": {
    "label": "メモ",
    "hint": "自由にメモを入力してください。"
  },
  "submit": "送信"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ja": ja};
}
