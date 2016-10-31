require 'rails_helper'

describe ExamsController do
  describe 'search' do
    it 'should not crash' do
      get 'search'
    end
  end
end
