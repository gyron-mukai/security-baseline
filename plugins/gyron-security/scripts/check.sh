#!/bin/zsh
# check.sh — checks.tsv の最低ラインを1件ずつ判定し、Markdown の表で出す（読み取りのみ）
# 終了コード: 0 = 全件合格／1 = 必須に不合格あり／2 = 推奨のみ不合格

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec:/opt/homebrew/bin:/usr/local/bin"

LIST="${0:A:h}/checks.tsv"
TIMEOUT=60
NG=0
WARN=0
PASS=0
TOTAL=0

echo "点検日時: $(date '+%Y-%m-%d %H:%M') ／ macOS $(sw_vers -productVersion) ／ $(sysctl -n hw.model)"
echo
echo "| ID | 重要度 | 項目 | 結果 |"
echo "|---|---|---|---|"
while IFS=$'\t' read -r id level category name cmd; do
  [[ -z "$id" || "$id" == \#* ]] && continue
  TOTAL=$((TOTAL + 1))
  # 60秒で打ち切る（macOS に timeout コマンドが無いため perl の alarm を使う）
  out=$(perl -e 'alarm shift; exec @ARGV' "$TIMEOUT" zsh -c "$cmd" 2>&1 </dev/null)
  rc=$?
  first=$(echo "$out" | grep -m1 . | tr '|' '/' | cut -c1-100)
  [ $rc -eq 142 ] && first="${TIMEOUT}秒で応答なし"
  if [ $rc -eq 0 ] && [ -n "$first" ]; then
    echo "| $id | $level | $name | ✅ $first |"; PASS=$((PASS + 1))
  elif [ "$level" = "推奨" ]; then
    echo "| $id | $level | $name | ⚠ ${first:-出力なし} |"; WARN=1
  else
    echo "| $id | $level | $name | ❌ ${first:-出力なし（終了コード $rc）} |"; NG=1
  fi
done < "$LIST"

echo
echo "合格 ${PASS} / ${TOTAL} 件"

[ $NG -eq 1 ] && exit 1
[ $WARN -eq 1 ] && exit 2
exit 0
