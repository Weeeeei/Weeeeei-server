require 'bundler/setup'
require 'uri'

Bundler.require
Dotenv.load

class WeeeeiApp < Sinatra::Base
  use Rack::MobileDetect

  helpers do
    def ios_app
      {
        name: ENV["IOS_APP_NAME"],
        id: ENV["IOS_APP_ID"],
      }
    end

    def android_app
      {
        name: ENV["ANDROID_APP_NAME"],
        schema: ENV["ANDROID_APP_SCHEMA"],
        identifier: ENV["ANDROID_APP_IDENTIFIER"],
      }
    end

    def ios?
      ["iPhone", "iPod", "iPad"].include?(request.env[Rack::MobileDetect::X_HEADER])
    end

    def android?
      ["Android"].include?(request.env[Rack::MobileDetect::X_HEADER])
    end
  end

  get "/:id" do
    if ios?
      haml :ios, locals: {
        app_name: ios_app[:name],
        app_id: ios_app[:id],
        target_user: params[:id],
      }
    elsif android?
      redirect URI.escape("intent://#{android_app[:name]}/#{params[:id]}#Intent;scheme=#{android_app[:schema]};package=#{android_app[:identifier]};end")
    end
  end
end

run WeeeeiApp
