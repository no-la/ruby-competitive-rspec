# frozen_string_literal: true

require_relative '../../lib/state_space_search'

RSpec.describe StateSpaceSearch::BFS do
  it '1から3へ+1ずつのBFSでゴールに到達できる' do
    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 3 },
      transitions: ->(state) { [state + 1] }
    )

    expect(result).to be_reachable
  end

  it 'ゴールへ到達できない' do
    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 3 },
      transitions: ->(_state) { [] }
    )

    expect(result).not_to be_reachable
    expect(result.distance).to be_nil
  end

  it '循環があっても同じ状態を1度だけ探索する' do
    transition_counts = Hash.new(0)
    graph = { 1 => [2], 2 => [1] }

    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 3 },
      transitions: lambda do |state|
        transition_counts[state] += 1
        transition_counts[state] == 1 ? graph.fetch(state) : []
      end
    )

    expect(result).not_to be_reachable
    expect(transition_counts).to eq(1 => 1, 2 => 1)
  end

  it '開始状態がゴールなら遷移せずに到達とする' do
    transitions = ->(_state) { raise '遷移は呼ばれない' }

    result = described_class.search(
      start: 1,
      goal: ->(state) { state == 1 },
      transitions: transitions
    )

    expect(result).to be_reachable
  end

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
end
