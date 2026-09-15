# ロジックの置き場（concern と PORO）

判断が変わる点だけ。

## concern は 2 種類

| | モデル固有 | 横断 |
|---|---|---|
| 置き場 | `app/models/post/publishable.rb` | `app/models/concerns/searchable.rb` |
| モジュール名 | `Post::Publishable` | `Searchable` |
| 使うモデル | 1 つだけ | 2 つ以上 |

**まずモデル固有。** 2 つ目が欲しがった時点で横断へ昇格。

## 1 concern = 1 機能

関連 + スコープ + 述語 + 操作 + コールバックが1ファイル。機構で切らない。

```ruby
# app/models/user/watchable.rb
module User::Watchable
  extend ActiveSupport::Concern

  included do
    has_many :watches, dependent: :destroy
    has_many :watched_posts, through: :watches, source: :post
    scope :watching, ->(post) { joins(:watches).where(watches: { post: post }) }
    after_create_commit :watch_welcome_post
  end

  def watching?(post) = watches.exists?(post: post)

  def watch(post)
    watches.find_or_create_by!(post: post)
  end

  def unwatch(post)
    watches.find_by(post: post)&.destroy!
  end

  private
    def watch_welcome_post = watch(Post.welcome)
end
```

命名は**形容詞か名詞**（動詞不可）。`-able` / 形容詞 / 複数形名詞。

## 横断 concern はテンプレートメソッド

骨格を横断に、埋め方を**同名のモデル固有concern**に。直接 include しない。

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern
  included { after_update_commit :reindex_for_search }
  private
    # モデル側が実装: search_title, search_content
    def searchable? = true
end

# app/models/post/searchable.rb
module Post::Searchable
  extend ActiveSupport::Concern
  include ::Searchable       # `::` 必須（無いと自分を再帰参照）
  def search_title   = title
  def search_content = body.to_plain_text
  def searchable?    = published?
end
```

モデル差分が大きいときは `class_methods do` の DSL（`positioned_within :book, ...`）。
除外マクロ（`allow_unauthenticated_access`）も同じ。

**依存**: 横断が include 先に依存するならテンプレートメソッド経由のみ。相互参照は避ける。
クラスメソッドは `class_methods do`（`ClassMethods` 手書きしない）。

## PORO の 4 分類

主語になる既存モデルが無いときだけ。PORO 自身が主語の名前を名乗る。

| 分類 | 形 | 例 |
|---|---|---|
| 手続きの主体 | `ActiveModel::Model`。コントローラに errors を返す | `Signup`, `Import` |
| 外部境界 | 外側との会話を閉じる。モデルは入口だけ | `Payment::Charge` |
| 値・表現 | `Data.define` / `Struct` | `Money`, `Invoice::Summary` |
| 行為者 | オーナー名前空間下。入口は1行 | `Post::SlugGenerator` |

外部境界の翻訳先は `error-handling.md` §4。
試行を記録する外部通信は AR にしてよい（`Webhook::Delivery`）。
`on:` の罠は SKILL.md「個別の指針」。

**置き場は `app/models`。**
`-er` / `-or`（`Notifier`, `SlugGenerator`）は普通に使う。

| 症状 | 置き場 |
|---|---|
| DBに保存しない計算 | PORO（値） |
| 外部API | PORO（境界） |
| 「誰が何をした」という行為 | イベント型 AR |
| 画面ごとのバリデーション | フォームオブジェクト |
| 複数モデルの1回きり手続き | PORO（手続き） |

`self` がそのモデルであることに意味が無いなら concern ではなく別オブジェクト。

## PORO の書き方

`Xxx.new(主語).動詞` が基本。** 状態の有無で判断しない
（状態が無くても `Opengraph::Fetch.new.fetch_document` のようにインスタンス化する）。

```ruby
# app/models/order/fraud/detector.rb
class Order::Fraud::Detector
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def detect
    if suspicious?
      flag
      true
    else
      false
    end
  end

  private
    def suspicious? = ...
    def flag = ...
end

# 入口はオーナーの1行
module Order::Screenable
  def detect_fraud = Order::Fraud::Detector.new(self).detect
end
```

**クラスメソッドだけにしてよいのは4用途。** それ以外で `self.` しか無い PORO は `new(主語).動詞` に戻す。

| 用途 | 形 | 例 |
|---|---|---|
| 純粋関数の名前空間 | `module` + `class << self`（private も置ける） | `MagicLink::Code.sanitize`, `Search::Stemmer.stem` |
| 状態を持ち回らない一回きりの生成 | `class` + `self.create!` | `FirstRun.create!(user_params)` |
| 定数コレクションの検索 | `self.for_value` / `self.find_by_name` + `COLORS` 定数 | `Color.for_value`, `Passkey::Authenticator.find_by_aaguid` |
| ファクトリ・ディスパッチ | `self.for(source)` がサブクラスや nil を返し、本体はインスタンス | `Notifier.for(event)&.notify`, `Card::Entropy.for(card)` |

**`module_function` は使わない。** `self.parse(s) = new.parse(s)` のショートカットは呼び出し側が複数ある時だけ足す。

**`initialize` の引数**

| 引数 | 形 |
|---|---|
| 主語のレコード 1〜2 個 | 位置引数（`new(order)`, `new(order, event)`, `new(event, viewer)`） |
| 任意・既定値あり | キーワード（`new(now: Time.current)`, `new(user, filter, expanded: false)`） |
| 3 個以上、または対等な 2 者で順序に意味が無い | キーワード（`new(invoice:, payment:)`, `new(account:, model:, attributes: nil)`） |

受けたものは `attr_reader` で公開。持っているオブジェクトへは `delegate`。

**動詞メソッド名はクラス名の名詞に対応する素の動詞**（`Notifier#notify`, `Seeder#seed`, `Highlighter#highlight`）。
`call` / `perform` / `execute` / `run` は使わない。
戻り値は true/false か作ったレコードか nil。Result オブジェクトは作らない（`error-handling.md`）。

**入口**: オーナーモデル／concern の1行メソッドから呼ぶ。コントローラ直呼びはフォームオブジェクト（`Signup`）とビューヘルパー（`QrCodeLink`）だけ。

**混ぜるもの**: `ActiveModel::Model` / `Validations` は `valid?` と `errors` が要るときだけ。
値だけなら `Data.define` / `Struct`（`Passkey::Authenticator < Data.define(...)`）。
