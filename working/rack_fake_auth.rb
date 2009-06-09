require 'pp'

module Rack
  class FakeAuth
    def initialize(app)
      @app = app
    end

    def call(env)
      #puts env.pretty_inspect

      req = Rack::Request.new(env)
      if req.params['login'].to_s != "" ||
          (env['rack.session'] &&
           env['rack.session']['login'].to_s != "")

        if req.params['login'].to_s != ""
          env['rack.session'] =
            { 'login' => req.params['login'] }
        end

        if req.params['original_url']
          return [302, { "Location" => req.params['original_url'] }, ""]
        end

        @app.call(env)
      else
        [200,
         { 'Content-Type' => 'text/html' },
         [
          %Q|<form action="#{env['SCRIPT_NAME']}/fake_auth_login">|,
          "<label>",
          "login",
          %Q|<input type="text" name="login"/>|,
          "</label>",
          %Q|<input type="hidden" name="original_url" value="#{req.fullpath}"/>|,
          %Q|<input type="submit" name="b" value="Go"/>|,
          "</form>"]
        ]
      end
    end
  end
end
