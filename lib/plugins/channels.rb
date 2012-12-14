require 'cinch'
require './rollem_bot'

module Cinch
  module Plugins
    class Channels
      include Cinch::Plugin
      match /(?i)join(?:\s([A-Za-z0-9_]+))?(?:\s(#[#A-Za-z0-9_]+))/, method: :join
      match /(?i)leave(?:\s([A-Za-z0-9_]+))?(?:\s(#[#A-Za-z0-9_]+))?/, method: :leave

      def join(m,server,channel)
        m.reply("Acknowledged! Joining '#{server}#{channel}'")

        #puts "s1" + server.inspect
        server = m.bot if not server or (server and server.empty?)
        #puts "s2" + server.inspect

        if $rollem
          $rollem.join_channel(server,channel)
        else
          m.reply("Cross-server operations not supported!")
        end
      end

      def leave(m,server,channel)

        channel = m.channel if not channel

        m.reply("Acknowledged! Leaving '#{server}#{channel}'")

        #puts "s1" + server.inspect
        server = m.bot if not server or (server and server.empty?)
        #puts "s2" + server.inspect

        if $rollem
          $rollem.leave_channel(server,channel)
        else
          m.reply("Cross-server operations not supported!")
        end
      end
    end
  end
end