require 'cinch'
require './rollem_bot'

Deck = Struct.new(:cards,:drawn,:help)

module Cinch
  module Plugins
    class Cards
      include Cinch::Plugin
      COMMANDS = "(?:deck|cards|card)"
      DECK_LOCATION = "./persist/plugin_settings/cards/decks/"
      DECK_EXTENSION = ".txt"
      DECK_DEFAULT = "fiftyfour"
      HELPTEXT = ["## Lem's Card Plugin Help ##",
                  "Commands: [optional] <required> ; 'deck_id' always defaults to 'default'",
                  " '!deck [deck_id] draw [fluff]' - draws a card, from 'default' deck if no [deck_id] is given.",
                  " '!deck [deck_id] new|load [template]' - Creates a new deck named 'deck_id' based on 'template'; default template is 'fiftyfour'.",
                  " '!deck [deck_id] shuffle [fluff]' - Shuffles the named deck.",
                  " '!deck [deck_id] help [fluff]' - PMs sender the help text associated with the deck.",
                  "## End Lem's Card Plugin Help ##"]
      match /(?i)help\s#{COMMANDS}/, method: :help
      match /(?i)#{COMMANDS}(?:\s(\w+))?\sdraw(\d*)(?:\s(.*))?/, method: :draw
      match /(?i)#{COMMANDS}(?:\s(\w+))\s(?:new|load)(?:\s(.*))?/, method: :new_deck
      match /(?i)#{COMMANDS}(?:\s(\w+))?\sshuffle(?:\s(.*))?/, method: :shuffle
      match /(?i)#{COMMANDS}(?:\s(\w+))?\shelp(?:\s(.*))?/, method: :deck_help

      attr_accessor :decks
      @decks = Hash.new() #channel -> decks

      def help(m)
        if m.channel?
          m.reply("#{m.user.nick}, check PMs for help.")
        end
        HELPTEXT.each do |line|
          m.user.send(line)
        end
      end

      def deck_help(m,deck_id,fluff)
        deck_id = "default" if not deck_id or deck_id.empty?
        fluff = "" if not fluff or fluff.empty?
        deck = get_deck(m.channel,deck_id,m)
        if not deck
          m.reply("#{m.user.nick}, deck '#{deck_id}' not found")
          return
        end
        if not deck[:help] or deck[:help].empty?
          m.reply("#{m.user.nick}, deck '#{deck_id}' has no associated help.")
          return
        end
        if m.channel?
          m.reply("#{m.user.nick}, check PMs for '#{deck_id}' help.")
        end
        m.user.send("## Help for '#{deck_id}': ##")
        deck[:help].each do |line|
          m.user.send(line)
        end
        m.user.send("## End of help for '#{deck_id}' ##")
      end
      def draw(m,deck_id,cards,fluff)
        deck_id = "default" if not deck_id or deck_id.empty?
        cards = 1 if not cards or cards.empty?
        fluff = "" if not fluff or fluff.empty?
        deck = get_deck(m.channel,deck_id,m)
        cards = cards.to_i
        if cards.to_i <= 0
          m.reply("*Hands #{m.user.nick} air*")
          return
        end
        if not deck
          m.reply("#{m.user.nick}, deck '#{deck_id}' not found")
          return
        end
        if deck[:cards].empty?
          m.reply("#{m.user.nick}, deck '#{deck_id}' has no cards to draw. Shuffle first.")
          return
        end
        if cards > 10
          m.reply "#{m.user.nick}, That's a lot of cards!"
          return
        end
        res = _deck_draw(deck,cards)
        if not res or res.empty?
          m.reply "#{m.user.nick}, not possible! Deck '#{deck_id}' only has #{deck[:cards].size} cards!"
        else
          m.reply("#{m.user.nick} drew: #{res.join(', ')}. Deck down to #{deck[:cards].size} cards!")
        end
      end
      def new_deck(m,deck_id,base)
        deck_id = "default" if not deck_id or deck_id.empty?
        base = "fiftyfour" if not base or base.empty?
        _channel_setup(m.channel)
        action = "loaded"
        action = "overwrote" if @decks[m.channel][deck_id]
        begin
          @decks[m.channel][deck_id] = _deck_load(DECK_LOCATION + base + DECK_EXTENSION)
          _deck_shuffle(@decks[m.channel][deck_id])
          m.reply("#{m.user.nick}, #{action} deck '#{deck_id}' with '#{base}'.")
        rescue
          m.reply("#{m.user.nick}, unable to load deck '#{deck_id}'. Template '#{base}' not found. respecify template?")
        end
      end
      def shuffle(m,deck_id,fluff)
        deck_id = "default" if not deck_id or deck_id.empty?
        fluff = "" if not fluff or fluff.empty?
        deck = get_deck(m.channel,deck_id,m)
        if not deck
          m.reply("#{m.user.nick}, deck '#{deck_id}' not found")
          return
        end
        _deck_shuffle(deck)
        m.reply("#{m.user.nick}, deck '#{deck_id}' has been shuffled! Now contains #{deck[:cards].size} cards!")
      end

      def get_deck(channel,deck_id,m)
        _channel_setup(channel)
        deck = @decks[channel][deck_id]
        if not deck #create channel storage and load deck
          begin
            @decks[channel][deck_id] = _deck_load(DECK_LOCATION + deck_id + DECK_EXTENSION)
            _deck_shuffle(@decks[channel][deck_id])
            m.reply("#{m.user.nick}, loaded deck from template of same name.")
          rescue
            m.reply("#{m.user.nick}, unable to load deck. Deck does not exist and template not found. Specify template?")
          end
        end
        deck
      end

      def _deck_load(file)
        cards = Array.new
        help = Array.new
        File.readlines(file).each do |line|
          line.strip! #strip newline
          case line
            when /^\#+(.*)/
              help.push $~[1] #push commentary
            else
              cards.push line
          end
        end
        Deck.new(cards,Array.new,help) #return blank deck
      end

      def _deck_shuffle(deck)
        deck[:cards] = deck[:cards] + deck[:drawn]
        deck[:drawn].clear
        deck[:cards].shuffle!
      end

      def _deck_draw(deck,num)
        if num > deck[:cards].length
          return nil
        end
        result = Array.new
        for i in 1..num
          c = deck[:cards].pop
          result.push c
          deck[:drawn].push c
        end
        result
      end
      def _channel_setup(channel)
        @decks = Hash.new if not @decks
        ch_decks = @decks[channel]
        if not ch_decks or ch_decks.empty? #create channel storage and load deck
          @decks[channel] = Hash.new
          @decks[channel]["default"] = _deck_load(DECK_LOCATION + DECK_DEFAULT + DECK_EXTENSION)
          _deck_shuffle(@decks[channel]["default"])
        end
      end
    end
  end
end