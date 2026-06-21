# frozen_string_literal: true

require_relative '../../lib/state_space_search'

RSpec.describe StateSpaceSearch::DFS do
  it_behaves_like 'state space search'

  it '奥まで探索してから次の分岐へ進む' do
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

    expect(result).to be_reachable
    expect(result.visit_order).to eq([1, 2, 4, 3, 5])
    expect(result.path).to eq([1, 3, 5])
    expect(result.distance).to eq(2)
  end
end
