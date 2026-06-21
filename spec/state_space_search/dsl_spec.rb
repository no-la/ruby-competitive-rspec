# frozen_string_literal: true

require_relative '../../lib/state_space_search'

RSpec.describe StateSpaceSearch::Problem do
  it 'DSLブロックから探索問題を構築する' do
    problem = search_problem { nil }

    expect(problem).to be_a(described_class)
  end

  it '開始状態を設定する' do
    problem = search_problem do
      start [1, 2]
    end

    expect(problem.start_state).to eq([1, 2])
  end

  it 'ゴール条件を設定する' do
    problem = search_problem do
      goal? { |state| state == 3 }
    end

    expect(problem.goal_condition.call(2)).to be(false)
    expect(problem.goal_condition.call(3)).to be(true)
  end
end
