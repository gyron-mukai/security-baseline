# security-baseline

株式会社ジャイロンの社員向けに、Mac のセキュリティ最低ラインを各自の Claude Code で点検する仕組み。
Claude Code のプラグイン（`gyron-security`）として配布する。

## 管理・バックアップ

- Git: あり
- リモート: GitHub `gyron-mukai/security-baseline`（public）
- 公開: GitHub 上で public（2026-10-26 承認。メンバーが GitHub の認証・招待なしで導入でき、書き込みを保守担当だけに限れるため）
- 機密: 顧客データ・個人情報・社内システムの情報は含まない。中身は一般的な Mac の安全設定と直し方のみ
- 最終確認: 2026-10-26

---

## メンバー向け: 導入手順（最初の1回だけ）

> [!info] GitHub のアカウントは不要です。

> [!warning] デスクトップアプリでは `/plugin` コマンドが使えません（「/plugin isn't available in this environment.」と出ます）。下のように Claude にコマンドの実行を頼んで入れます。

### デスクトップアプリの場合
1. 上のタブを「Cowork」ではなく **Code** にする（Cowork は Mac 本体ではなく Linux の作業環境で動くため、点検できません）
2. 新しいセッションを作り、環境は必ず「**このコンピューター**」を選ぶ（フォルダはどこでも可）
3. 次の文章をそのまま貼って送信する

```
次のコマンドを実行して、gyron-security プラグインを入れてください。
claude plugin install gyron-security --marketplace gyron-mukai/security-baseline
--marketplace が使えないと言われたら、claude plugin marketplace add gyron-mukai/security-baseline を実行したあと、claude plugin install gyron-security@gyron-internal を実行してください。
claude コマンドが見つからない場合は、~/Library/Application Support/Claude/claude-code/ の中にある claude という実行ファイルを探して使ってください。
いまの環境が Mac ではなく Linux だと分かったら、何も実行せずにそのことを教えてください。
入れ終わったら、新しいセッションを開くよう案内してください。
```

4. コマンドの実行を許可するか聞かれたら許可する
5. 「コマンドライン・デベロッパツールをインストールしますか」と出たら「インストール」を押し、終わったら Claude に「続けて」と送る
6. インストールが終わったら、新しいセッションを開く

### ターミナル版の Claude Code の場合
セッション内で次の2行を1行ずつ入力します。

```
/plugin marketplace add gyron-mukai/security-baseline
```

```
/plugin install gyron-security@gyron-internal
```

続けて `/plugin` → Marketplaces → `gyron-internal` → Enable auto-update を選ぶと、点検項目の追加が自動で届きます。

> [!note] デスクトップアプリで入れた場合の自動更新の方法は確認中です。更新したときは保守担当から案内します。

## 使い方

Code タブ（環境は「このコンピューター」）で「**セキュリティ点検して**」と話しかけます（`/gyron-security:check` でも可）。フォルダはどこでも構いません。
環境を cloud にするとプラグインが読み込まれないので注意してください。
15分ほどで終わり（不合格の項目を直す場合はさらにかかります）、結果は `~/Documents/セキュリティ点検/` に保存されます。**月に1回**行ってください。

---

## 構成

```
.claude-plugin/marketplace.json        配布元（マーケットプレイス名: gyron-internal）
plugins/gyron-security/
├── .claude-plugin/plugin.json
├── skills/check/SKILL.md              点検の流れ（Claude への指示）
├── scripts/checks.tsv                 全員共通の最低ライン（1行1チェック）
├── scripts/check.sh                   checks.tsv を判定して表にする
├── scripts/inventory.sh               人によって違う部分の棚卸し（判定しない）
└── references/
    ├── remediation.md                 ID ごとの直し方
    └── advisories.md                  その時々の脆弱性情報
```

保守のルールは `CLAUDE.md` を参照。
