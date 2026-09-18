# rails-design の eval

`references/controllers.md`「レスポンス」節と、対応するレビューチェックリスト項目の実効性を見る。
プラグインの配布物には含めない（`plugins/` の外に置いている）。

## 構成

- `evals.json` — テストケース（プロンプト・対象ファイル・アサーション）
- `fixtures/eval-N/` — レビュー対象の架空 Rails コード

## 何を見ているか

| ケース | 機構 | 狙い |
|---|---|---|
| eval-1 `response-definition-scattered` | ハッシュ直書き | 表現定義がコントローラに散っているのを**拾えるか** |
| eval-2 `empty-body-and-error-shape` | ハッシュ直書き | 空ボディ・認可NG・不要な respond_to を**拾えるか** |
| eval-3 `no-false-positive-on-correct-response` | jbuilder partial | 規約どおりのレスポンスを**誤指摘しないか** |
| eval-4 `ams-split-definition` | `active_model_serializers` | serializer を使っている＝1箇所、と**誤判定しないか** |
| eval-5 `jb-template-camelize` | `.json.jb` + `deep_camelize` | jbuilder 以外の機構でも**同じ指摘ができるか** |
| eval-6 `legacy-and-new-serializer` | `JSONAPI::Serializer` → `AMS::JSON` 移行中 | 基底が2つ併存する状態を**拾えるか** |

eval-3 が要。指摘を増やすだけの追記は eval-1/2 だけ見ていると通ってしまう。

eval-4〜6 は実在のコードベースで使われている機構を、架空ドメインで書き起こしたもの
（gem の使い方だけ真似ている。実コードは持ち込まない）。
規約を機構非依存に書いたのが効いているかを見る。

## 回し方

`anthropic-skills:skill-creator` の手順に従う。各ケースにつき2エージェント
（追記後のスキル / 追記前のスナップショット）を同一ターンで起動し、レビュー本文を
`<workspace>/iteration-N/eval-*/{with_skill,old_skill}/outputs/review.md` に保存させる。
スナップショットは `git archive <前の SHA> plugins/rails-design/skills/rails-design` で作る。

`eval_metadata.json` は `evals.json` から生成する:

```bash
jq --argjson id 1 '.evals[] | select(.id == $id) | {eval_id: .id, eval_name: .name, prompt, assertions}' evals.json
```

採点は skill-creator の `agents/grader.md`、集計は `scripts.aggregate_benchmark`、
閲覧は `eval-viewer/generate_review.py` を使う。

## 初回（レスポンス節の追記時）に分かったこと

**アサーションのほとんどが非差別的だった。** 追記前のスキルでも、eval-2 は5項目すべて、
eval-1 は4項目中3項目を拾った。eval-3 は追記の有無にかかわらず誤指摘ゼロ。
`head :no_content` / `head :forbidden` / 不要な `respond_to` / `success: true` を捨てる、
といった指摘は書かなくても出る。

差がついたのは2点だけ:

- **キー変換の散らばり** — 追記前は表現の話のついでに括弧書きで触れるだけ。追記後は独立した指摘になった
- **エラー形式を1つに決める** — 追記前は言及なし

そのため初稿の40行は12行に削った。残すのはこの2点と、両者の前提になる
「表現の定義は1箇所」だけ。**素のモデルが出せる指摘を書いても、長さが増えるだけで出力は変わらない。**

非差別的なアサーションも消さずに残している。退行検知（削りすぎて出なくなっていないか）には使える。
次に回すときは、差がついた項目とそうでない項目を分けて読むこと。

## 機構を変えても効くか（eval-4〜6）

3ケースとも全アサーション該当。機構に合わせた具体案まで出た
（AMS なら `render json: @lesson, serializer:` に寄せる、jb ならレンダラ側で
`deep_camelize` を1回だけ通しテンプレートは snake のまま、など）。
「serializer を使っているから表現は1箇所」という誤判定も起きていない。

**規約を機構非依存に書いた判断はここで裏が取れた。** 逆に、初稿のように jbuilder の
コード例を厚く書いていたら、jb や AMS のコードに当てたとき「機構が違う」で流れた可能性がある。

副産物として、仕込んでいない問題も拾った（eval-4 の認可漏れ、eval-5 の
partial 二重エンコード疑い）。fixture は機構の再現だけを狙って書いたので、
これらは意図しない現実味であって、アサーションには入れていない。
