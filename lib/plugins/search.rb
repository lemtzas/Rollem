require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'rubygems'
require 'mechanize'

module Cinch
  module Plugins
    class Google
      include Cinch::Plugin

      match /google (.+)/

      def search(query)
        url = "http://www.google.com/search?q=#{CGI.escape(query)}"
        res = Nokogiri::HTML(open(url)).at("h3.r")

        title = res.text
        link = res.at('a')[:href]
        desc = res.at("./following::div").children.first.text
        CGI.unescape_html "#{title} - #{desc} (#{link})"
      rescue
        "No results found"
      end

      def execute(m, query)
        m.reply(search(query))
      end
    end
    class OneDeeFourChan
      include Cinch::Plugin

      match /tg (.+)/

      def search(query)
        url = "http://1d4chan.org/wiki/#{query.gsub(' ','_')}"
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'
        title = agent.get(url).title
        "#{title} (#{url})"
      rescue
        "No results found"
      end

      def execute(m, query)
        m.reply(search(query))
      end
    end
  end
end
  