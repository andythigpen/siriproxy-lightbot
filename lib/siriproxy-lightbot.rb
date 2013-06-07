require 'cora'
require 'siri_objects'
require 'pp'
require 'net/http'
require 'json'
require 'uri'

class SiriProxy::Plugin::LightBot < SiriProxy::Plugin
  def initialize(config)
    @host = "localhost"
    @port = "6060"
    @uri  = URI("http://#{@host}:#{@port}/lights")
    @responses = ["If you say so", "OK", "No problem", "Roger", 
                  "Affirmative", "Ayaye Captain", "I suppose I could do that"]
  end

  def send_command(params)
    response = Net::HTTP.post_form(@uri, params)
    return response.code == 200
  end

  def lights_on_off(action)
    say @responses.sample
    send_command(:action => action)
    request_completed
  end

  listen_for /turn.*lights (on|off)/i do |action|
    lights_on_off(action)
  end

  listen_for /turn (on|off) the lights/i do |action|
    lights_on_off(action)
  end

  listen_for /(lower|raise|dim|brighten) the lights/i do |action|
    say @responses.sample
    if action =~ /lower|dim/i
      action = "dim"
    elsif action =~ /raise|brighten/i
      action = "bright"
    end
    send_command(:action => action, :repeat => 6)
    request_completed
  end

end
