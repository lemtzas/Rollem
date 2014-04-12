
require './lib/dicebox'
require './lib/shunting-yard'

module Cinch
  module Plugins
    class Dicebox
      include Cinch::Plugin

      @prefix = '' #kill the prefix

      match /!spacegen(?: (verbose))?./, method: :spacegen
      match $full_dice_regex2
      match $inline_dice_regex
      match /!statgen(?: (verbose))?.*/
      match "reload dice"
      match /shunt .*/

      def execute(m,subopt='',*args)
        case m.message
          when "reload dice"
            m.reply "It is done, my liege."
            load './dicebox.rb'
          when /!statgen(?: (verbose))?.*/
            if subopt == "verbose"
              verbose = true
              m.reply "#{m.user.to_s} requested some stats:"
            end
            stats = []
            (1..6).each do
              text,sum = Rollem::Dicebox::Roll::roll(4,6,1)
              stats.push(sum)
              m.reply "#{m.user.to_s}, #{text} => #{IRColor.bold.to_s}#{sum}#{IRColor.clear.to_s}" if verbose
            end
            stats.sort! {|x,y| y <=> x}
            m.reply "#{m.user.to_s}, #{stats}"
          when $full_dice_regex2
            res = Array.new
            puts $~.to_s
            $~.to_s.split(";").each do |roll|
              puts roll
              res.push Rollem::Dicebox::Roll.new(roll).to_s
            end
            #m.reply "I would roll...but that would be useful"
            #m.reply "instead..." + dice.to_s
            m.reply m.user.to_s + ", " + res.join(" ; d")
          when $inline_dice_regex
            res = Array.new
            puts $~[0][0].to_s
            $~[0][0].to_s.split(";").each do |roll|
              puts roll
              res.push Rollem::Dicebox::Roll.new(roll).to_s
            end
            #m.reply "I would roll...but that would be useful"
            #m.reply "instead..." + dice.to_s
            m.reply m.user.to_s + ", " + res.join(" ; d")
          when /shunt .*/
            sr = shunt(m.message[6..-1])
            m.reply "shunt it! " + IRColor.grey.to_s + sr.to_s + IRColor.clear.to_s + ' => ' + IRColor.bold.to_s + calculate(sr).to_s

        end
      end

      def spacegen(m,verbose='')
        if verbose == "verbose"
          verbose = true
          m.reply "#{m.user.to_s} requested some stats:"
        end
        stats = []
        (1..6).each do
          begin
            a,b = rand(1..die),rand(1..die)
            sum = (a-b).abs
          until sum > 0
          stats.push(sum)
          if verbose
            text = "| #{a} - #{b} | = #{sum}"
            m.reply "#{m.user.to_s}, #{text} => #{IRColor.bold.to_s}#{sum}#{IRColor.clear.to_s}"
          end
        end
        stats.sort! {|x,y| y <=> x}
        m.reply "#{m.user.to_s}, #{stats}"
      end
    end

  end
end