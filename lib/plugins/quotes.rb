#require 'sqlite3'

module Cinch
  module Plugins
    class Quotes
      include Cinch::Plugin
      match /^quote(?:\s?(add|del|by)\s(.+))?$/, method: :execute
      match /^server$/, method: :server

      def server(m)
        m.reply("You are on #{$rollem.server_to_id(m.bot)}")
      end

      def execute(m,subopt,quote_or_by)
        m.reply "Not implemented"
      end
    end
  end
end
