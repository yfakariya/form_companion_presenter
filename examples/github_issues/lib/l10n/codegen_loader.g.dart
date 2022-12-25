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
  "titleTemplate": "Example app of form_companion_presenter: {screenName}",
  "home": {
    "title": "Home"
  },
  "login": {
    "title": "Login",
    "loginButtonLabel": "Log in"
  },
  "issues": {
    "title": "Issues",
    "search": "Search",
    "next": "Next",
    "previous": "Previous"
  },
  "issue": {
    "title": "Issue {issueNumber} - {issueTitle}"
  },
  "formFields": {
    "clientId": {
      "label": "Client ID",
      "hint": "Client ID configured in your GitHub account setting for this app."
    },
    "clientSecret": {
      "label": "Client Secret",
      "hint": "Client Secret configured in your GitHub account setting for this app."
    },
    "doPersist": {
      "label": "Persists these values",
      "hint": "Check it if you want to persist these inputs."
    },
    "repository": {
      "label": "Repository (optional)",
      "hint": "Target repository name with 'user/repo' format to be searched."
    },
    "sortKey": {
      "label": "Sort key",
      "hint": "Select sort key of issues. Default is 'created'."
    },
    "direction": {
      "label": "List direction",
      "hint": "Select direction of issues list which ordered by sort key. Default is 'desc'."
    },
    "issueState": {
      "label": "Issue state",
      "hint": "Select issue state to be shown. Default is 'all'."
    },
    "since": {
      "label": "Since (optional)",
      "hint": "Specify oldest date and time of issues to be shown."
    },
    "issuesPerPages": {
      "label": "Issues per pages",
      "hint": "Maximum issues shown in a page. Default is 20."
    }
  }
};
static const Map<String,dynamic> ja = {
  "titleTemplate": "form_companion_presenter利用アプリ例: {screenName}",
  "home": {
    "title": "ホーム"
  },
  "login": {
    "title": "ログイン",
    "loginButtonLabel": "ログイン"
  },
  "issues": {
    "title": "課題一覧",
    "search": "検索",
    "next": "次へ",
    "previous": "前へ"
  },
  "issue": {
    "title": "課題 {issueNumber} - {issueTitle}"
  },
  "formFields": {
    "clientId": {
      "label": "クライアントID",
      "hint": "このアプリ用にGitHubのアカウント設定で構成したクライアントID。"
    },
    "clientSecret": {
      "label": "クライアントシークレット",
      "hint": "このアプリ用にGitHubのアカウント設定で構成したクライアントシークレット。"
    },
    "doPersist": {
      "label": "これらの値を保存する",
      "hint": "これらの入力を保存したい場合にはチェックしてください。"
    },
    "repository": {
      "label": "リポジトリ（省略可能）",
      "hint": "検索対象のリポジトリの名前。'user/repo'形式です。"
    },
    "sortKey": {
      "label": "並び替えのキー",
      "hint": "課題の並び替えのキーを選択してください。既定値は'created'です。"
    },
    "direction": {
      "label": "一覧の並び順",
      "hint": "「並び替えのキー」で並び替えられる課題の並び順を選択してください。既定値は'desc'です。"
    },
    "issueState": {
      "label": "課題の状態",
      "hint": "表示する課題の状態。既定値は'all'です。"
    },
    "since": {
      "label": "表示開始日時（省略可能）",
      "hint": "表示される課題の最も古い日時を指定してください。"
    },
    "issuesPerPages": {
      "label": "ページあたり課題数",
      "hint": "1ページに表示される課題の最大数。既定値は20です。"
    }
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ja": ja};
}
