# App Store提出用：Webページ作成手順と「iroiro」専用メタデータ完全ガイド

日本からiOSアプリ「iroiro」をApp Store（日本及びグローバル）に配信するために必要な「Webページの設定方法」と、「App Store Connectに入力する最適なメタデータ（アプリ情報）」を詳細にまとめました。

---

## 第1部：必須Webページ（プライバシーポリシー＆サポート）の作り方

App Storeの審査では、**①プライバシーポリシー** と **②サポートページ** の2つのURL（リンク）が**必須**になります。独自のサーバーを借りる必要はありません。無料で簡単に作れる以下の方法がおすすめです。

### 無料でWebページを公開するおすすめの方法

最も簡単で、開発者によく使われている3つの無料サービスです。

#### 方法1：Notionを使う（最も簡単・おすすめ）
Notionでページを書き、「Webで公開」ボタンを押すだけでURLが発行されます。
1. Notion（無料）に登録・ログイン。
2. 新規ページを2つ作成する（「iroiro プライバシーポリシー」「iroiro サポート」）。
3. ページ右上の「共有（Share）」>「Webで公開（Publish to web）」をオンにする。
4. 発行されたURLをコピーして、App Store Connectに貼り付ける。

#### 方法2：Google サイトを使う
Googleアカウントがあれば誰でも無料でWebサイトを作れます。
1. [Google サイト](https://sites.google.com/)にアクセス。
2. 「空白」から新しいサイトを作成。
3. ページ内にテキストボックスを配置し、内容を記述。
4. 右上の「公開」ボタンを押し、任意のウェブアドレス（例：`iroiro-pomodoro`）を指定して公開。

#### 方法3：GitHub Pagesを使う（開発者向け）
このプロジェクトはVS Codeで管理されているため、GitHubリポジトリがあるならGitHub Pagesが使えます。
1. リポジトリに `docs` フォルダを作成し、その中に `privacy.html` と `support.html` を作成（またはMarkdownでも可）。
2. GitHubのリポジトリ設定（Settings）>「Pages」から、Sourceをメインブランチ（または`docs`フォルダ）に設定して保存。
3. `https://<あなたのユーザー名>.github.io/<リポジトリ名>/privacy.html` のようなURLが発行されます。

### 各ページに書くべき内容（コピペ用テンプレート）

#### ① プライバシーポリシー (Privacy Policy)
「iroiro」は通信やユーザーデータの収集を一切行わないため、それを明記するだけで審査に通ります。

**【日本語版テンプレート】**
```text
# 「iroiro」プライバシーポリシー

本アプリ「iroiro」は、ユーザーのデバイス内で完結するツールであり、個人情報や利用状況などの一切のデータを収集、保存、または第三者へ送信することはありません。
インターネット通信も行いません。

（必要であれば連絡先メールアドレスなどを記載）
2026年3月〇〇日 制定
```

#### ② サポートページ (Support Page)
ユーザーが使い方に迷ったり、不具合を見つけた場合の連絡先を記載します。

**【日本語版テンプレート】**
```text
# 「iroiro」サポート窓口

本アプリは、数字や文字を使わず「色」だけで時間を表現するZenなポモドーロタイマーです。
タップ：スタート / 停止
長押し：タイマーリセット

ご意見・不具合のご報告は、以下のメールアドレス、またはX（旧Twitter）アカウントまでご連絡ください。
・Email: [あなたのメールアドレス]
・X (Twitter): [@あなたのアカウント]
```

※Notionなどで作成する場合、1つのページ内に「プライバシーポリシー」と「サポート」のセクションを分けて書き、App Store Connectには2ヶ所とも**同じページのURL**を入力しても（内容が網羅されていれば）審査は通過します。

---

## 第2部：「iroiro」専用 メタデータ（App Store入力情報）

App Store Connectに入力する項目です。数字や文字を排除した「ミニマル・Zen」というコンセプトを際立たせる構成にしました。
日本以外のユーザーにもコンセプトが刺さりやすいアプリなので、**英語（US）の翻訳も設定しておくことを強く推奨**します。

### 1. アプリ情報（App Information）

| 項目 | 日本語 (Japanese) | 英語 (English - US) | 文字数制限 |
| :--- | :--- | :--- | :--- |
| **名前 (Name)** | iroiro : Zen Focus Timer | iroiro : Zen Focus Timer | 30文字以内 |
| **サブタイトル (Subtitle)** | 数字のない、色で感じるポモドーロ | Color-based pomodoro timer. | 30文字以内 |

*解説: アプリ名は世界共通で「iroiro」とし、どんなアプリか分かるように「Zen Focus Timer」を後ろに付けています。*

### 2. 価格と配信状況 (Pricing and Availability)
* **価格**: 0円（無料）
* **配信状況**: すべての国と地域（テキストレスなので世界中で使えます）

### 3. バージョン情報 (1.0 Prepare for Submission)

#### プロモーションテキスト (Promotional Text)
*※アプリページの最上部に表示され、審査なしでいつでも変更可能なテキストです（最大170文字）。*

* **日本語**: 「数字も、文字もない。12色のうつろいだけで時間を計る、究極にミニマルなポモドーロタイマー。」
* **英語**: "No numbers. No text. Just colors. The ultimate minimalist pomodoro timer for deep focus."

#### 概要 / 説明文 (Description)
*※アプリの魅力を伝えるメインの文章です（最大4000文字）。*

**【日本語版】**
```text
「iroiro」は、画面から一切の数字とテキストを排除した、Zen（禅）の精神を感じるポモドーロタイマーです。

時間は「数字」で追うものではなく、「色」で感じるもの。
12色の美しいカラーグリッドのうつろいが、あなたの集中を静かにサポートします。

■ 特徴
・究極のミニマリズム: 画面にあるのは色と形だけ。気を散らす要素は一切ありません。
・直感的なジェスチャー操作: 
　- 画面を「タップ」でスタート / 一時停止
　- 画面を「長押し」でタイマーリセット
・集中（25分）と休憩（5分）のサイクルを、色の変化でお知らせします。
・心地よいハプティック（振動）フィードバック。

ただ、ひたすらに、目の前のタスクと向き合うために。
```

**【英語版】**
```text
"iroiro" is a Zen-inspired pomodoro timer that completely eliminates numbers and text from the screen.

Don't track time with numbers; feel it through colors. 
The shifting sequence of a beautiful 12-color grid silently supports your deep focus.

■ Features
- Ultimate Minimalism: Only colors and shapes. Zero distractions.
- Intuitive Gesture Controls:
  - Tap anywhere to Start / Pause.
  - Long press to Reset the timer.
- Visual cues for Focus (25 min) and Break (5 min) cycles through color transitions.
- Subtle and satisfying haptic feedback.

Designed for one purpose: helping you focus purely on the task in front of you.
```

#### キーワード (Keywords)
*※検索に使われるカンマ区切りの単語リストです（合計100バイト以内）。スペースは不要です。*

* **日本語**: `ポモドーロ,タイマー,集中,勉強,仕事,ミニマル,禅,zen,pomodoro,timer,色,カラー,無音,シンプル`
* **英語**: `pomodoro,timer,focus,study,work,minimalist,zen,color,simple,productivity,time,block`

#### サポートURL / プライバシーポリシーURL
* 第1部で作成したNotionやGoogleサイトのURLを貼り付けます。

#### 著作権 (Copyright)
* 例: `© 2026 Kazuki` （あなたの名前や屋号）

### 4. Appのプライバシー (App Privacy / Nutrition Labels)
App Store Connectの「Appのプライバシー」タブでの回答設定です。
1. 「使用するデータの収集について」 -> **「いいえ、このAppからはデータを収集していません」** を選択。
2. そのまま保存して公開（公開ボタンを押すまでストアに反映されません）。このアプリは完全にオフラインで動作するため、審査で引っかかることはありません。
