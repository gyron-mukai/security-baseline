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

> [!info] 下の2つを順番に行います。GitHub のアカウントは不要です。分からなければ Claude に「security-baseline の README の導入手順を一緒にやって」と頼んでください。

### 1. プラグインの追加
Claude デスクトップアプリの **Code タブ**を開き、環境を「**このコンピューター**」にしたセッションで、次の2行を1行ずつ入力します（ターミナル版の Claude Code でも同じ）。
うまくいかない場合は、入力欄横の「＋」→「Add plugins」から追加します。

> [!warning] 2026-10-26 時点で、Code タブからこの2行で追加できるかは試験導入で確認中

```
/plugin marketplace add gyron-mukai/security-baseline
```

```
/plugin install gyron-security@gyron-internal
```

### 2. 自動更新を ON にする
`/plugin` と入力 → Marketplaces → `gyron-internal` を選ぶ → Enable auto-update を選ぶ。
（これをしないと、点検項目が追加されても届きません）

## 使い方

Code タブ（環境は「このコンピューター」）で「**セキュリティ点検して**」と話しかけます（`/gyron-security:check` でも可）。フォルダはどこでも構いません。
環境を cloud にするとプラグインが読み込まれないので注意してください。
10分ほどで終わり、結果は `~/Documents/セキュリティ点検/` に保存されます。**月に1回**行ってください。

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
