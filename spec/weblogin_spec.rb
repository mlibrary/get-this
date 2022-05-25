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
  let(:stub_item) { stub_alma_get_request(url: "items", output: fixture("item.json"), query: {item_barcode: "somebarcode", expand: "due_date"}) }
  let(:stub_patron) { stub_alma_get_request(url: "users/tutor", output: fixture("mrio_user_alma.json")) }
  context "/login" do
    it "sends off to omniauth; session has correct redirect path" do
      stub_item
      @session[:authenticated] = false
      env "rack.session", @session
      get "/somebarcode"
      expect(last_request.env["rack.session"][:path_before_login]).to eq("/somebarcode")
      expect(URI.parse(last_response.location).path).to eq("/login")
    end
  end
  context "authenticated but expired" do
    it "redirects to omniauth with correct redirect path" do
      @session[:authenticated] = true
      @session[:expires_at] = Time.now - 1.hour
      env "rack.session", @session
      get "/somebarcode"
      expect(last_request.env["rack.session"][:path_before_login]).to eq("/somebarcode")
      expect(URI.parse(last_response.location).path).to eq("/login")
    end
  end
  context "not authenticated" do
    it "has nil uniqname for barcode page" do
      stub_item
      @session[:authenticated] = false
      @session[:uniqname] = nil
      env "rack.session", @session
      get "/somebarcode"
      expect(last_request.env["rack.session"][:uniqname]).to be_nil
    end
  end
  context "authenticated" do
    it "passes through with logged in info" do
      stub_item
      stub_patron
      get "/somebarcode"
      session = last_request.env["rack.session"]
      expect(session[:uniqname]).to eq("tutor")
      expect(session[:authenticated]).to eq(true)
    end
  end
  context "get '/auth/openid_connect/callback'" do
    let(:omniauth_auth) {
      {
        info: {nickname: "nottutor"},
        credentials: {expires_in: 86399}
      }
    }
    before(:each) do
      stub_alma_get_request(url: "users/nottutor", status: 400)
      OmniAuth.config.add_mock(:openid_connect, omniauth_auth)
    end
    it "sets session to appropriate values and redirects to home" do
      get "/auth/openid_connect/callback"
      session = last_request.env["rack.session"]
      expect(session[:authenticated]).to eq(true)
      expect(session[:uniqname]).to eq("nottutor")
      expect(session[:expires_at]).to be <= (Time.now.utc + 1.hour)
      expect(URI.parse(last_response.location).path).to eq("/")
    end
    it "redirects to location stored in the session" do
      @session[:path_before_login] = "/somebarcode"
      env "rack.session", @session
      get "/auth/openid_connect/callback"
      expect(last_request.env["rack.session"][:path_before_login]).to be_nil
      expect(URI.parse(last_response.location).path).to eq("/somebarcode")
    end
  end
  context "/logout" do
    it "clears the session and redirects to shibboleth" do
      get "/logout"
      expect(last_request.env["rack.session"][:uniqname]).to be_nil
      expect(last_response.location).to eq("https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/")
    end
  end
  context "dev_login" do
    it "shows dev login options when 'WEBLOGIN_ON' is false and in development environment" do
      stub_item
      stub_patron
      app.settings.environment = :development
      with_modified_env WEBLOGIN_ON: "false" do
        get "/somebarcode"
        expect(last_response.body).to include("Development Options")
      end
      # reset the environment
      app.settings.environment = :test
    end
    it "doesn't show dev login options for 'WEBLOGIN_ON' is true even in development environment" do
      stub_item
      stub_patron
      app.settings.environment = :development
      with_modified_env WEBLOGIN_ON: "true" do
        get "/somebarcode"
        expect(last_response.body).not_to include("Development Options")
      end
      # reset the environment
      app.settings.environment = :test
    end
    it "doesn't show dev login options for 'WEBLOGIN_ON' false but not in development environment" do
      stub_item
      stub_patron
      expect(app.settings.environment).to eq(:test)
      with_modified_env WEBLOGIN_ON: "false" do
        get "/somebarcode"
        expect(last_response.body).not_to include("Development Options")
      end
    end
  end
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
