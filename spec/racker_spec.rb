RSpec.describe Codebreaker::Racker do

  describe 'Menu' do
    before do
      get '/'
      post '/game', player_name: TEST_NAME, level: TEST_LEVEL
    end
  end

end