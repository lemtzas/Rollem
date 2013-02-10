#reload utility from http://stackoverflow.com/questions/3463182/reload-rubygem-in-irb
def reload(require_regex)
  $".grep(/^#{require_regex}/).each {|e| $".delete(e) && require(e) }
end
require './lib/ir_color'
reload './lib/ir_color'

#match the roll at the beginning
#$simple_regex = /^(\d)*d(\d)(d\d+|k\d+)?+[+-]((\d)*d(\d)+(d\d+|k\d+)?|\d+)/
#whitespace woo
$full_dice_regex = /^\s*\d*\s*d\s*\d+(d\s*\d+|k\s*\d+)?(\s*[+-]\s*(\s*\d*\s*d\s*\d+\s*(d\s*\d+|k\s*\d+)?|\s*\d+\s*))*/
$full_dice_regex2 = /^\s*\d*\s*d\s*\d+(d\s*\d+|k\s*\d+)?(\s*[+-]\s*(\s*\d*\s*d\s*\d+\s*(d\s*\d+|k\s*\d+)?|\s*\d+\s*))*(;\s*\d*\s*d\s*\d+(d\s*\d+|k\s*\d+)?(\s*[+-]\s*(\s*\d*\s*d\s*\d+\s*(d\s*\d+|k\s*\d+)?|\s*\d+\s*))*)*/

module Rollem
  module Dicebox
    colors = { :max => :red }
    RollData = Struct.new(:sides, :value, :coloring);

    class Roll
      MAXIMUM_ROLLS = 15
      MAXIMUM_DIE = 999

      TOKENS = {/^\d*d\d+(d\d+|k\d+)?/ => lambda{|sin,sout,sum,op,i|
                                        out = sout
                                        if i > 1
                                          if op.to_i == 1
                                            out += " + "
                                          else
                                            out += " - "
                                          end
                                        end
                                        split = sin.split('k')      #get keep part
                                        keep = split[1].to_i if split[1]

                                        split = split[0].split('d') #get qty,drop,roll
                                        die = split[1].to_i
                                        if split[0].length == 0     #dX format
                                          qty = 1
                                        else
                                          qty = split[0].to_i       #given qty
                                        end
                                        drop = split[2].to_i        #copy drop qty or nil
                                        if keep
                                          drop = qty - keep         #keep translation if no drop amount
                                        end
                                        drop = 0 if not drop
                                        puts "roll(" + qty.to_s + "," + die.to_s + "," + drop.to_s + ")" + keep.to_s
                                        text,val = self.roll(qty,die,drop)
                                        #text,val = "5",5
                                        out += text
                                        sout.replace out
                                        val},
                /^\d*d\d+/        => lambda{|sin,sout,sum,op,i|
                                        out = sout
                                        if i > 1
                                          if op.to_i == 1
                                            out += " + "
                                          else
                                            out += " - "
                                          end
                                        end
                                        split = sin.split('d')
                                        if split[0].length == 0
                                          split[0] = "1"
                                        end
                                        text,val = self.roll(split[0].to_i,split[1].to_i)
                                        puts "#" + val.to_s
                                        #text,val = "5",5
                                        out += text
                                        sout.replace out
                                        val},
                /^\d+/            => lambda{|sin,sout,sum,op,i|
                                        out = sout
                                        if i > 1
                                          if op.to_i == 1
                                            out += " + "
                                          else
                                            out += " - "
                                          end
                                        end
                                        out += sin
                                        sout.replace out
                                        sin.to_i },
                /^\+/             => lambda{|sin,sout,sum,op,i| op.replace('1');0},
                /^\-/             => lambda{|sin,sout,sum,op,i| op.replace('-1');0}
      }

      attr_reader :fulltext, :roll, :flavor, :components

      def initialize(fulltext)
        @fulltext = fulltext.to_s.strip
        @roll = $full_dice_regex.match(fulltext.to_s).to_s.strip
        @flavor = fulltext.to_s[@roll.length .. -1].strip

        #kill whitespace in roll
        @roll.gsub!(/ /,'')

        #split into separate components
        troll = @roll.dup
        @breakdown = Array.new()

        #while there are tokens left to parse
        i = 0
        op = '1' #the operator (+ or - ... '1' or '-1')
        sout = IRColor.bold.to_s + @roll + IRColor.clear.to_s + " => " #the roll text
        sin = ""
        sum = 0
        while (not troll.empty?) and i < 30 ; i += 1
          TOKENS.each_key do |k|
            puts "\"#{troll}\".match(/#{k}/)"
            if(troll.match(k))
              troll = troll[$~.to_s.length .. -1]
              sin = $~.to_s
              puts "sin := " + sin
              puts $~
              sum += op.to_i*TOKENS[k].call(sin,sout,sum,op,i)
              break
            end
          end
        end
        @output = sout + " => " + IRColor.bold.to_s + sum.to_s + IRColor.clear.to_s
      end

      def to_s
        #IRColor.red.bold.to_s
        #@roll.to_s + " | " + @flavor.to_s + " | " + @breakdown.to_s
        @output
      end

      #Roll (returns text,sum)
      def self.roll(qty,die,drop=0)
        text = "["
        val = 0
        if die <= MAXIMUM_DIE and qty <= MAXIMUM_ROLLS
          rolls = rollem(qty,die)
          rolls.sort! {|x,y| y <=> x } if drop != 0   #sort high to low (if dropping)
          i = 0
          rolls.each do |r| i += 1

            val += r if i <= qty - drop #only add those not dropped
            if i > qty - drop
              text += IRColor.grey.bold.to_s + r.to_s + IRColor.clear.to_s
            elsif r == die
              text += IRColor.green.bold.to_s + r.to_s + IRColor.clear.to_s
            elsif r == 1
              text += IRColor.red.bold.to_s + r.to_s + IRColor.clear.to_s
            else
              text += r.to_s
            end
            text += " + "
          end
          text = text[0..-4] #truncate the final " + "
        else
          text += IRColor.red.bold.to_s + ">:(" + IRColor.clear.to_s #ANGRY FACE, NO ROLL
        end
        text += "]"
        text += "d" + drop.to_s if drop != 0
        return text,val
      end


      #ROLL HEADS
      def self.rollem(qty,die)
        rolls = Array.new
        qty.times do
          rolls.push(rand(1..die))
        end
        rolls
      end
    end
  end
end