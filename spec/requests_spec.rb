require "spec_helper"
describe "requests" do
  include Rack::Test::Methods
  before(:each) do
    @session = {
      uniqname: "tutor",
      authenticated: true,
      expires_at: Time.now + 1.day
    }
    env "rack.session", @session
  end
  context "/" do
    it "for a logged in user, redirects to 'Find, Borrow, Request'" do
      get "/"
      expect(last_response.location).to eq("https://www.lib.umich.edu/find-borrow-request")
    end
  end
  context "/confirmation" do
    it "works" do
      get "/confirmation"
      expect(last_response.body).to include("Go to")
    end
  end
end
