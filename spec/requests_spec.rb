require 'spec_helper'
describe "requests" do
  include Rack::Test::Methods
  context "/" do
    it "shows Get This" do
      get '/'
      expect(last_response.body).to include('Get This')
    end
  end
end

