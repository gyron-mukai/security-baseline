#!/bin/zsh
# inventory.sh — 人によって違う部分（入っているアプリ・拡張機能・常駐物など）を棚卸しして Markdown で出す（読み取りのみ）
# 判定はしない。Claude が結果を読んで、注意点を本人に説明する
# 守ること: ファイルの中身・パスワード・トークンは出力しない（名前・件数・バージョンだけ）

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin"

echo "## アプリ（/Applications、バージョン付き）"
for app in /Applications/*.app; do
  v=$(defaults read "$app/Contents/Info" CFBundleShortVersionString 2>/dev/null)
  electron=""
  [ -d "$app/Contents/Frameworks/Electron Framework.framework" ] && electron="（Electron）"
  echo "- ${app:t:r} ${v}${electron}"
done

echo
echo "## ブラウザ拡張機能（全サイトを読み書きできる権限のもの）"
# Chrome / Brave / Edge / Arc のプロファイルを走査。名前が __MSG_ 形式の場合は ID のまま出す
typeset -A browsers
browsers=(
  Chrome "$HOME/Library/Application Support/Google/Chrome"
  Brave "$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
  Edge "$HOME/Library/Application Support/Microsoft Edge"
  Arc "$HOME/Library/Application Support/Arc/User Data"
)
found=0
for b in ${(k)browsers}; do
  root="${browsers[$b]}"
  [ -d "$root" ] || continue
  for ext_dir in "$root"/*/Extensions(N/); do
    profile=${ext_dir:h:t}
    total=0; broad=()
    for id_dir in "$ext_dir"/*(N/); do
      manifest=$(ls -d "$id_dir"/*/manifest.json(N) | tail -1)
      [ -n "$manifest" ] || continue
      total=$((total + 1))
      perms="$(plutil -extract permissions json -o - "$manifest" 2>/dev/null) $(plutil -extract host_permissions json -o - "$manifest" 2>/dev/null) $(plutil -extract content_scripts json -o - "$manifest" 2>/dev/null)"
      if echo "$perms" | grep -qE '<all_urls>|\*://\*/\*|https?://\*/\*'; then
        name=$(plutil -extract name raw -o - "$manifest" 2>/dev/null)
        if [[ "$name" == __MSG_* ]]; then
          # 多言語化された名前は _locales/<言語>/messages.json から引く（キーは大文字小文字を区別しない）
          key=${${name#__MSG_}%__}; resolved=""
          for loc in ja en en_US "$(plutil -extract default_locale raw -o - "$manifest" 2>/dev/null)"; do
            msg="${manifest:h}/_locales/$loc/messages.json"
            [ -f "$msg" ] || continue
            real_key=$(plutil -convert json -o - "$msg" 2>/dev/null | grep -oiE "\"$key\"" | head -1 | tr -d '"')
            [ -n "$real_key" ] && resolved=$(plutil -extract "$real_key.message" raw -o - "$msg" 2>/dev/null)
            [ -n "$resolved" ] && break
          done
          name="${resolved:-(ID ${id_dir:t})}"
        fi
        broad+=("$name")
      fi
    done
    [ $total -eq 0 ] && continue
    found=1
    echo "- $b / $profile: 拡張 ${total} 件、うち全サイト権限 ${#broad} 件"
    for n in $broad; do echo "  - $n"; done
  done
done
[ $found -eq 0 ] && echo "- 対象ブラウザの拡張機能は見つからず（Safari は対象外）"

echo
echo "## ログイン時・常駐で動くもの（Apple 以外）"
for d in "$HOME/Library/LaunchAgents" /Library/LaunchAgents /Library/LaunchDaemons; do
  items=("$d"/*.plist(N))
  items=(${items:#*/com.apple.*})
  echo "- ${d/#$HOME/~}: ${#items} 件"
  for p in $items; do echo "  - ${p:t:r}"; done
done

echo
echo "## 外部から接続を受け付けているプロセス（全インターフェースで待ち受け）"
o=$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 && $9 ~ /^(\*|0\.0\.0\.0|\[::\]):/ {print "- "$1" "$9}' | sort -u)
echo "${o:-- なし}"

echo
echo "## 開発ツール・ランタイム"
command -v brew >/dev/null && echo "- Homebrew: 更新待ち $(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ') 件" || echo "- Homebrew: なし"
command -v node >/dev/null && echo "- Node.js: $(node -v)" || echo "- Node.js: なし"
command -v claude >/dev/null && echo "- Claude Code: $(claude --version 2>/dev/null | head -1)" || echo "- Claude Code: パス上になし"

echo
echo "## 平文で置かれている可能性のある秘密情報（ファイル名だけ。中身は開かない）"
# 鍵ファイルはそのまま、キーワードは人がメモを残しがちな形式（テキスト・表・画像・PDF）に限る。プログラムのソースは対象外
o=$(find "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Library/Mobile Documents/com~apple~CloudDocs" -maxdepth 3 -type f \
  \( -iname '*.pem' -o -iname '*.key' -o -iname '*.p12' \
     -o \( \( -iname '*recovery*' -o -iname '*password*' -o -iname '*パスワード*' -o -iname '*リカバリ*' -o -iname '*seed*' -o -iname '*secret*' -o -iname '*backup*code*' \) \
           \( -iname '*.txt' -o -iname '*.md' -o -iname '*.rtf' -o -iname '*.csv' -o -iname '*.xlsx' -o -iname '*.numbers' -o -iname '*.pdf' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.heic' \) \) \) 2>/dev/null \
  | sed "s|^$HOME|~|" | head -30)
echo "${o:-- 該当なし}"

echo
echo "## 前回の点検"
reports=("$HOME/Documents/セキュリティ点検"/*.md(N))
if [ ${#reports} -gt 0 ]; then echo "- ${reports[-1]:t:r}"; else echo "- 記録なし（初回）"; fi
