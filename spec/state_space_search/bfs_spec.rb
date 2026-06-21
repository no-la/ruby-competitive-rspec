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
  end
end
