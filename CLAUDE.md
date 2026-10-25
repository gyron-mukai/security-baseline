# security-baseline 保守ルール

社員全員の Mac に配る点検プラグイン。ここへの変更は push 後、自動更新を ON にしている全員に届く。

## 点検項目を足す（保守担当が自分の環境で新しく点検したことを全員に広げる）
- **常に確認すべき設定** → `plugins/gyron-security/scripts/checks.tsv` に1行足し、`references/remediation.md` に同じ ID の直し方を足す
- **期間限定の脆弱性**（CVE など） → `references/advisories.md` の先頭に1件足す。対象期間を必ず書く
- **人によって違う情報**が新たに必要 → `scripts/inventory.sh` に棚卸し項目を足す（判定はしない）

## 守ること
- checks.tsv の頭に書いたルール（読み取りのみ・秘密を出力しない・macOS 標準コマンドだけ）を守る
- 変更したら push 前に次の2つを行う
  1. `plugins/gyron-security/scripts/check.sh` と `inventory.sh` を実行し、エラーが出ないこと、新しい行が意図どおり判定されることを確認する（不合格になる条件も一度試す）
  2. `claude plugin validate ./` が通ること
- plugin.json に `version` を書かない（書くと、上げ忘れたときに更新が届かない。省略するとコミットごとに配られる）
- このリポジトリは public。メンバーは招待なしで導入できるので、共同編集者は追加しない（追加すると書き込み可になり、全員の Mac で動くコードを書き換えられるため）
- 公開されている前提で書く。社員の個人名・社内のフォルダパス・顧客名・社内システムの情報を入れない
