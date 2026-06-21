# ruby-competitive-rspec

Rubyで競技プログラミングをするために、RSpecで基礎アルゴリズムのスニペットを育てる実験用リポジトリです。

## セットアップ

Ruby 3.3.11を使用します。macOSではHomebrewの `ruby@3.3` を前提にしています。

```sh
bundle install
bundle exec rspec
bundle exec rubocop
```

`bundle exec rake` で全specとRuboCopをまとめて実行できます。スニペットは `lib/`、対応するspecは `spec/` に配置します。

LazyVimではRuby extra、test extra、DAP extraを設定済みです。Ruby LSP、RuboCop、Treesitter、neotest-rspec、デバッガを利用できます。主なテスト操作は `<leader>tr`（カーソル位置）、`<leader>tt`（現在のファイル）、`<leader>tT`（全件）、`<leader>td`（カーソル位置をデバッグ）です。

## 使い方

開始状態、ゴール条件、遷移を宣言し、同じ問題をBFSまたはDFSで解きます。

```ruby
require_relative 'lib/state_space_search'

graph = {
  a: %i[b c],
  b: [:d],
  c: [:e],
  d: [:e],
  e: []
}

problem = search_problem do
  start :a
  goal? { |state| state == :e }
  transitions { |state| graph.fetch(state) }
end

bfs = problem.solve_with(:bfs)
dfs = problem.solve_with(:dfs)

bfs.path        # => [:a, :c, :e]
bfs.distance    # => 2
bfs.visit_order # => [:a, :b, :c, :d, :e]

dfs.path        # => [:a, :b, :d, :e]
dfs.distance    # => 3
dfs.visit_order # => [:a, :b, :d, :e]
```

探索してよい状態を制限する場合は `valid?` を追加します。省略した場合はすべての状態を許可します。

```ruby
valid? { |state| state.between?(0, 100) }
```

探索結果から以下を取得できます。

- `reachable?`: ゴールへ到達できたか
- `distance`: 発見した経路の長さ。BFSの場合のみ最短距離
- `path`: 発見した経路。到達不能なら `nil`
- `parents`: 各状態を発見したときの親
- `visit_order`: 状態を訪問した順序

## 目的

wakate.rbでの発表準備として、RubyでAtCoderの問題を解きつつ、RSpecを競プロにどう活かせるかを試します。

サンプル入出力の確認は `oj test` で十分なので、このリポジトリではRSpecを「提出コード全体のstdioテスト」ではなく、「再利用するアルゴリズム部品のテスト」に使います。

## 方針

- 問題ごとの入出力確認は `oj test` に任せる
- DFS/BFSの到達性、訪問順、親、経路をRSpecで直接テストする
- 問題定義と探索戦略を分離し、同じDSLをDFS/BFSで使う
- 実際のAtCoder問題で実用性を確認する

## 実装済み

- 反復実装のDFS/BFS
- 循環防止と状態の有効性判定
- 到達可能性、訪問順、距離、親、経路復元
- DFS/BFS共通のRSpec shared examples
- 状態空間探索DSL

## 発表で話したいこと

競プロはサンプルテストが最初から与えられているので、TDDっぽく見えます。
しかし、サンプル入出力をRSpecに貼るだけなら `oj test` の置き換えに近く、RSpecを使う意味は弱いです。

RSpecが効くのは、DFSやBFSのような「分かっているつもりの部品」のふるまいを直接確認できるところです。
特に、到達可能判定だけでは見えない探索順や親配列などをテストできる点は、stdioテストとの違いになります。

## メモ

Rubyの標準ライブラリや配列操作の計算量、発表構成のメモはObsidian側の `📖wakate.rb登壇` にまとめています。
