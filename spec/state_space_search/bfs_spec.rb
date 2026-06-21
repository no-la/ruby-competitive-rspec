# frozen_string_literal: true

require_relative '../../lib/state_space_search'

RSpec.describe StateSpaceSearch::BFS do
  it_behaves_like 'state space search'

  it '深さの浅い状態から順に訪問する' do
    graph = {
      1 => [2, 3],
      2 => [4],
      3 => [5],
      4 => [],
      5 => []
    }

    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 5 },
      transitions: ->(state) { graph.fetch(state) }
    )

    expect(result.visit_order).to eq([1, 2, 3, 4, 5])
  end

  it 'ゴールまでの最短距離を返す' do
    graph = {
      1 => [2, 3],
      2 => [4],
      3 => [5],
      4 => [5],
      5 => []
    }

    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 5 },
      transitions: ->(state) { graph.fetch(state) }
    )

    expect(result.distance).to eq(2)
  end

  it '各状態を最初に発見した親を記録する' do
    graph = {
      1 => [2, 3],
      2 => [4],
      3 => [4],
      4 => []
    }

    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 4 },
      transitions: ->(state) { graph.fetch(state) }
    )

    expect(result.parents).to eq(
      1 => nil,
      2 => 1,
      3 => 1,
      4 => 2
    )
  end

  it 'ゴールまでの最短経路を復元する' do
    graph = {
      1 => [2, 3],
      2 => [4],
      3 => [5],
      4 => [5],
      5 => []
    }

    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 5 },
      transitions: ->(state) { graph.fetch(state) }
    )

    expect(result.path).to eq([1, 3, 5])
  end
end
