---
name: babysit-pr
description: このスキルは git push や gh pr create の直後で PR が存在するとき、または明示的な起動で使用する。所与の PR に張り付いて CI/レビュー/コンフリクトを監視・解消する。
---

所与の PR を監視し、問題が発生するたびに修正・push してクリーンな状態を維持する。
PR が存在しない場合は終了する。

PR が merge されるまで監視を継続し、merge を確認したらユーザーに伝えて完了とすること。

## PR の指定

対象 PR は以下のいずれかで指定する。指定がない場合はカレントブランチの PR を自動検出する。

- PR 番号: `123`
- PR URL: `https://github.com/owner/repo/pull/123`
- カレントブランチ: 省略（`gh pr view` が自動検出）

ci-watch / pr-review-watch / conflict-check を起動する際は、この PR 指定を引き継いで渡すこと。

---

## CI

**ci-watch** skill でバックグラウンド監視する。失敗が報告されたらログ要約から原因を特定し、修正→commit→push。push 後は CI が再走するので ci-watch を再起動して再監視する。
PRとは無関係と思われる失敗は別ですでに修正済みの可能性があるため最新のベースブランチを確認する。

## レビュー

**pr-review-watch** skill でバックグラウンド監視する（CI 監視と並行で起動してよい）。監視・解消対象はAIやBotからも含む。新着指摘が来たら:
- バグ・規約違反・must-fix → 修正→commit→push
- nit / 好み / 判断に迷うもの → 方針を簡潔に提示してユーザーに諮る

pr-review-watch は 1 回の検知で終了するので、まだ来てなければ再起動して待つこと。

## コンフリクト

**conflict-check** skill で確認する。コンフリクトがあれば解消→commit→push。
