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

  it '次の状態を生成する遷移を設定する' do
    problem = search_problem do
      transitions { |state| [state - 1, state + 1, state * 2] }
    end

    expect(problem.transition_generator.call(3)).to eq([2, 4, 6])
  end

  it '探索可能な状態の条件を設定する' do
    problem = search_problem do
      valid? { |state| state.between?(0, 10) }
    end

    expect(problem.valid_condition.call(-1)).to be(false)
    expect(problem.valid_condition.call(5)).to be(true)
  end

  it 'valid?を省略した場合はすべての状態を許可する' do
    problem = search_problem { nil }

    expect(problem.valid_condition.call(:anything)).to be(true)
  end

  it 'DSLで定義した問題をBFSで解く' do
    problem = search_problem do
      start 1
      goal? { |state| state == 3 }
      transitions { |state| [state + 1] }
      valid? { |state| state <= 3 }
    end

    result = problem.solve_with(:bfs)

    expect(result).to be_reachable
    expect(result.distance).to eq(2)
    expect(result.path).to eq([1, 2, 3])
  end

  it 'DSLで定義した問題をDFSで解く' do
    graph = {
      1 => [2, 3],
      2 => [4],
      3 => [5],
      4 => [],
      5 => []
    }
    problem = search_problem do
      start 1
      goal? { |state| state == 5 }
      transitions { |state| graph.fetch(state) }
    end

    result = problem.solve_with(:dfs)

    expect(result).to be_reachable
    expect(result.visit_order).to eq([1, 2, 4, 3, 5])
    expect(result.path).to eq([1, 3, 5])
  end
end
