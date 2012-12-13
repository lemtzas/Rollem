require 'cinch'
require './rollem_bot'

module Cinch
  module Plugins
    class Channels
      include Cinch::Plugin
      match /(?i)join\s(?:([A-Za-z0-9_]*)\s?)?(#[#A-Za-z0-9_]+)/

      def execute(m,server,channel)
        m.reply("Acknowledged! Joining '#{server}#{channel}'")
        if server
          server = m.bot if server.empty?
          puts server.inspect
          if $rollem
            $rollem.join_channel(server,channel)
          else
            m.reply("Cross-server operations not supported!")
          end
        end
      end
    end
  end
end