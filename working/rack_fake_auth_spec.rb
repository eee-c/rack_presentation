require 'spec'
require 'rack/test'
require 'rack_fake_auth'
require 'webrat'

def app
  @target_app = mock("Target Rack App")
  @target_app.
    stub!(:call).
    and_return([200, { }, "Target app"])

  Rack::FakeAuth.new(@target_app)
end

context "no user" do
  include Rack::Test::Methods
  include Webrat::Matchers

  describe "accessing any resource" do
    it "should be prompted for login" do
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
    it "should remember the original URL" do
      get "/foo"
      last_response.
        body.
        should have_selector("input",
                             :name => "original_url",
                             :value => "/foo")
    end
  end
  describe "authenticating" do
    it "should prompt for login if none is supplied" do
      get "/fake_auth_login", { :login => "" }
    end
    it "should pass thru if login is supplied" do
      get "/fake_auth_login", { :login => "foo" }
      last_response.should contain("Target app")
    end
    it "should store login for upstream consupmtion" do
      get "/fake_auth_login", { :login => "foo" }
      last_request.
        env['rack.session']['login'].
        should == "foo"
    end
  end
end

context "authenticated user" do
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
