# frozen_string_literal: true

require_relative '../../lib/state_space_search'

RSpec.describe StateSpaceSearch::Problem do
  it 'DSLブロックから探索問題を構築する' do
    problem = search_problem { nil }

    expect(problem).to be_a(described_class)
  end
end
