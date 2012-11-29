require 'mechanize'

module Cinch
  module Plugins
    class UrlTitle
      #strings wrapped in single quotes for later eval
      PRECURSORS = ['"#{m.user} demands you view \"#{title}\""',
                    '"#{m.user} commands you to view \"#{title}\""',
                    '"#{m.user} calls forth \"#{title}\""',
                    '"#{m.user} salivates over \"#{title}\""',
                    '"#{m.user} infringes on the copyrights of \"#{title}\""',
                    '"#{m.user} fears \"#{title}\""',
                    '"#{m.user} likes to spam \"#{title}\""',
                    '"#{m.user} would totally sleep with \"#{title}\""']
      URL_REGEX = /(?i)\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?]))/
      #same regex but matches whole line
      URL_REGEX2 = /(?i)\b.*((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?])).*/
      include Cinch::Plugin

      @prefix = ''

      match URL_REGEX2

      def execute(m)
        url = m.message.match(URL_REGEX)
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'
        title = agent.get(url).title.strip
        m.reply( eval PRECURSORS.sample )
      end
    end
  end
end
