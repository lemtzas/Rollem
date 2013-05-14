require 'cinch'
require 'cinch/plugins/identify'


require "./lib/plugins/plugin_management"
require "./lib/plugins/search"
require './lib/plugins/url_title'
require './lib/plugins/dicebox'
require './lib/plugins/channels'
require './lib/plugins/quotes'
require './lib/plugins/cards'


#contains relevant server info
ServerData = Struct.new(:name,:address,:port)

module Rollem
  #RollemBot contains enhancements to Cinch::Bot
  class RollemBot
    attr_reader :bot,:thread
    @bot
    @thread

    def initialize(server_data,channels,nickname,authtype,password)
      puts "+++" + server_data.to_s
      @bot = Cinch::Bot.new do
        configure do |c|
          puts server_data[:address]
          c.server = server_data[:address]
          c.port = server_data[:port] if not server_data[:port].nil?
          c.channels = channels
          c.nick = nickname
          c.plugins.plugins = [Cinch::Plugins::Dicebox,
                               Cinch::Plugins::Identify,
                               Cinch::Plugins::PluginManagement,
                               Cinch::Plugins::UrlTitle,
                               Cinch::Plugins::Channels,
                               Cinch::Plugins::Quotes,
                               Cinch::Plugins::Help,
                               Cinch::Plugins::Cards]
          c.plugins.options[Cinch::Plugins::Identify] = {
              :username => nickname,
              :password => password,
              :type     => authtype
          }
        end

        on :message, /(?i)hello,?\s+#{nickname}/ do |m|
          m.reply "Hello, #{m.user.nick}"
        end

        on :message, /(?i)die,?\s+#{nickname}/ do |m|
          $rollem.die
        end
      end
    end

    def die()
      @bot.quit("FAREWELL CRUEL WORLD")
    end

    def start()
      @thread = Thread.new do
        print "bot starting\n"
        @bot.start
      end
      @thread
    end
  end
end


class Test
  def initialize(server_data)
    puts "---" + server_data.to_s
    puts "---" + server_data[:address].to_s
    puts "---" + server_data[:port].to_s
  end
end