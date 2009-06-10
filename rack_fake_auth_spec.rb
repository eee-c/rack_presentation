require 'spec'
require 'rack/test'
require 'rack_fake_auth'
require 'webrat'

def app
  @target_app = mock("Target Rack Application")
  @target_app.
    stub!(:call).
    and_return([200, { }, "Target app"])

  Rack::FakeAuth.new(@target_app)
end

context "no user" do
  include Rack::Test::Methods
  include Webrat::Matchers

  describe "accessing any resource" do
    it "should prompt for login" do
      get "/foo"
      last_response.
        body.
        should have_selector("form",
                             :action => "/fake_auth_login")
    end
    it "should be prompted for username" do
      get "/foo"
      last_response.
        body.
        should have_selector("input",
                             :name => "login")
    end
  end
  describe "authenticating" do

    it "should redirect to the original URL if login is supplied" do
      get "/fake_auth_login", { :login => "foo", :original_url => "/foo"}
     # follow_redirect!()
      last_response.headers['Location'].should  == "/foo"
    end
    it "should store login for upstream consupmtion" do
      get "/fake_auth_login", { :login => "foo" }
      last_request.
        env['rack.session']['login'].
        should == "foo"

    end
  end
end

context "with a user" do
  include Rack::Test::Methods
  include Webrat::Matchers

  describe "accessing any resource" do
    it "should allow access" do
      get "/foo", { },
        { 'rack.session' => { 'login' => 'foo' } }
      last_response.should contain("Target app")
    end
  end
end
