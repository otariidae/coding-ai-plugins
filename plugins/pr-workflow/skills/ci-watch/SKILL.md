---
name: ci-watch
description: PR の CI 完了をバックグラウンドで待ち、失敗時は失敗ジョブとログ要約を返す観測専用スキル。監視中もチャットはブロックしない。「CI 通った？」「CI 落ちたら教えて」「PR の CI 見といて」等の指示で使用する。PR 番号・URL を指定することも可能（省略時はカレントブランチの PR を自動検出）。
---

# ci-watch

現在ブランチに紐づく PR の CI 完了を待ち、結果（green / failure + ログ要約）を返すだけのスキル。**修正はしない**。CI 失敗の検知と原因の手がかり提供までが責務。

## 手順

### 1. PR 解決

`gh pr view [<番号またはURL>] --json number,headRefName,state,url` で PR を取得。
- PR なし → 停止
- state が `OPEN` 以外 → 確認
- 自動検出かつ現在ブランチが headRef と異なる → 警告

### 2. CI 監視（`run_in_background: true` 必須）

フォアグラウンドで実行しないこと（チャットがブロックされ、10 分でタイムアウトする）。

1. `gh pr checks <PR番号> --json name,state,bucket` で現状確認
   - 全チェック完了済みなら watch 不要、手順 3 へ
   - 「no checks reported」なら 30 秒待って 1〜2 回リトライ
2. `gh pr checks <PR番号> --watch --interval 30 --fail-fast` をバックグラウンド起動。「CI 監視を開始した」とユーザーに伝えてターンを終える
3. 起動時に `gh pr view --json headRefOid` で監視対象コミットを控えておく
4. 終了通知後: `gh pr checks <PR番号> --json name,state,bucket,link,workflow` で結果取得
   - headRefOid が変わっていたら「古いコミットの結果」と明記し、再監視するか確認
   - 別作業中に通知が来たら、簡潔に挟んでから元の作業に戻る

### 3. 結果報告

**全て成功:**
✅ CI green (PR #<番号>) — N チェック pass

**失敗あり:**
❌ CI failed (PR #<番号>)

fail-fast で抜けているため pending が残る可能性あり。`bucket` が `pending` のチェックがあれば「他 N 件 pending」と併記する。

失敗ジョブごとに出力:
- <ジョブ名> / <workflow>
  - run URL: <link>
  - ログ要約: `<重要箇所のみ抜粋>`
  - 推測カテゴリ: lint / formatter / type-check / unit test / integration test / build / generated-file mismatch / dependency / その他

PRとは無関係と思われる失敗は、別ですでに修正済みの可能性があるため最新のベースブランチを確認する。

## ログ取得

`gh run view <run-id> --log-failed` で取得。run-id は link の `…/actions/runs/<run-id>/…` から抜く。

コンテキスト汚染防止のため:
- `tail -n 150` や `grep -iE 'error|fail|FAILED'` で絞ってから読む
- ログが巨大 / 失敗ジョブ多数の場合は Explore サブエージェントに委任して要約だけ受け取る

ログ要約ルール:
- タイムスタンプ・装飾行・冗長スタック中間は除く
- エラーメッセージ本文・ファイルパス・行番号を残す
- 1 ジョブ 5〜30 行。スタックは浅いユーザーコード行 + ライブラリ境界 2〜3 行
- 同種失敗が大量なら最初の 1〜2 件 + 「他 N 件同種」

## 制約

このスキルの手順上の制約（監視中のユーザーからの別依頼は通常通り対応してよい）:
- コード修正・commit・push・lint --fix 等は行わない
- 1 回の CI 完了を見届けたら終了。自発的に再起動しない
- ログ全文をそのまま会話に出さない
- ブランチ切り替え・rebase・merge は行わない
