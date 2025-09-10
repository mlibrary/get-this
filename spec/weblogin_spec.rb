require "spec_helper"
describe "requests" do
  include Rack::Test::Methods

  before(:each) do
    env "HTTP_X_AUTH_REQUEST_USER", "tutor"
  end
  let(:stub_item) { stub_alma_get_request(url: "items", output: fixture("item.json"), query: {item_barcode: "somebarcode", expand: "due_date"}) }
  let(:stub_patron) { stub_alma_get_request(url: "users/tutor", output: fixture("mrio_user_alma.json")) }

  let(:stub_api_calls) do
    stub_item
    stub_patron
  end

  let(:expect_uniqname_in_session) do
    session = last_request.env["rack.session"]
    expect(session[:uniqname]).to eq("tutor")
  end

  context "empty X_AUTH header not found in alma" do
    it "returns 401 response" do
      env "HTTP_X_AUTH_REQUEST_USER", nil
      get "/somebarcode"
      expect(last_response.status).to eq(401)
    end
  end

  context "uniqname in the header but there isn't a session" do
    it "sets the session to the user in the header" do
      env "rack.session", {}
      stub_api_calls
      get "/somebarcode"
      expect_uniqname_in_session
    end
  end

  context "session has a different patron than the header" do
    it "sets the session to the user in the header" do
      env "rack.session", {uniqname: "not_tutor"}
      stub_api_calls
      get "/somebarcode"
      expect_uniqname_in_session
    end
  end

  context "/logout" do
    it "clears the session and redirects to oauth2/sign_out" do
      get "/logout"
      expect(last_request.env["rack.session"][:uniqname]).to be_nil
      expect(last_response.location).to include("oauth2/sign_out")
    end
  end
end
