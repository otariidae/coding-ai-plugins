---
name: conflict-check
description: PR のマージコンフリクト状態を確認し、結果（コンフリクトなし / コンフリクトあり＋ファイル一覧）を返す観測専用スキル。「コンフリクトある？」「マージできる？」「conflict 確認して」「コンフリクト確認」、PR 作成・push 直後の確認等で使用する。PR 番号・URL を指定することも可能（省略時はカレントブランチの PR を自動検出）。
---

# conflict-check

現在ブランチに紐づく PR のマージコンフリクト状態を確認し、結果を報告するスキル。**修正・rebase・merge はしない**。検知と影響ファイルの特定までが責務。

## 手順

### 1. PR 解決

`gh pr view [<番号またはURL>] --json number,headRefName,state,url,baseRefName` で PR を取得。PR 番号と `baseRefName` を控えておく。
- PR なし → 停止
- state が `OPEN` 以外 → 確認
- 自動検出かつ現在ブランチが headRef と異なる → 警告

### 2. マージ可否確認

`gh pr view <PR番号> --json mergeable,mergeStateStatus` を叩く。

push 直後は `mergeable: UNKNOWN` になる（GitHub の計算待ち）。UNKNOWN なら 30 秒待って最大 4 回リトライする:

```bash
PR=<PR番号>
for i in $(seq 1 4); do
  RESULT=$(gh pr view "$PR" --json mergeable,mergeStateStatus)
  MERGEABLE=$(echo "$RESULT" | jq -r '.mergeable')
  if [ "$MERGEABLE" != "UNKNOWN" ]; then echo "$RESULT"; exit 0; fi
  sleep 30
done
echo "$RESULT"  # UNKNOWN のまま返す
```

通常 1〜2 分以内に解決するため、フォアグラウンドで待って問題ない。

### 3. 結果報告

**MERGEABLE:**
✅ コンフリクトなし (PR #<番号>) — `<baseRefName>` へマージ可能
mergeStateStatus が `BEHIND` なら「ベースより遅れているがコンフリクトはなし」と併記。

**CONFLICTING:**
コンフリクトファイルを特定:
```bash
git fetch origin "$BASE" 2>/dev/null
git merge-tree --write-tree HEAD "origin/$BASE" 2>&1 | head -200
```
git 2.38 未満の代替: `git merge-tree $(git merge-base HEAD "origin/$BASE") HEAD "origin/$BASE" 2>&1 | grep -E "^changed in both|^added in both" | head -50`

exit code 0 なら「GitHub API と不一致、コンフリクトなし」と伝える。非 0 なら出力からコンフリクトファイルを抽出して報告:

❌ コンフリクトあり (PR #<番号>)
コンフリクトしているファイル:
- `<ファイルパス>`
- ...

rebase で解消する？

**4 回リトライ後も UNKNOWN:**
⚠️ マージ可否確認タイムアウト (PR #<番号>) — GitHub がまだ計算中の可能性あり。再確認は conflict-check を再実行。

## 制約

このスキルの手順上の制約（ユーザーからの別依頼は通常通り対応してよい）:
- rebase・merge・コード修正・commit・push は行わない（`git merge-tree` は読み取り専用のため OK）
- 作業ツリーを変更する操作（`git merge --no-commit`・ブランチ切り替え等）は行わない
