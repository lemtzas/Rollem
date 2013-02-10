require 'cinch'
require './rollem_bot'

module Cinch
  module Plugins
    class Cards
      include Cinch::Plugin
      COMMANDS = "(SWR|SWRAND)"

      match /(?i)help\s#{COMMANDS}/, method: :help
      match /(?i)#{COMMANDS}(?:\s(\w+))?\sdraw(\d*)(?:\s(.*))?/, method: :char

    end
  end
end