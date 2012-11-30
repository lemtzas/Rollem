#precedence
# ()
# d
# * /
# - +

def shunt(input)        #input string
  index = 0             #input string index
  output = Array.new    #output queue (TODO: make efficient)
  ops    = Array.new    #operator stack

  #load token
  while(index < input.length)
    token = ''            #token holder
    case input[index..-1]
      when /^\d+/           #number token
        token = $~.to_s
        output.push(token)
      when /^[d\-\+\/\*]/   #operator token
        #more complex, expand for precedence
        token = $~.to_s
        ops.push(token)
      when /^\(/            #left paren
        token = $~.to_s
        ops.push(token)
      when /^\)/            #right paren
        token = $~.to_s
        #shift operators to the output queue until we find the matching paren
        last_op = ops.pop()
        while not last_op == '(' and not ops.empty?
          output.push(last_op)
          last_op = ops.pop()
        end

        if last_op != '('
          puts 'mismatched parentheses'
          return
        end


      else
        puts  'invalid'

    end

    index += token.length #step the token position

  end

  #finalize
  while not ops.empty?
    token = ops.pop()
    if token == '(' or token == ')'
      puts 'mismatched parentheses'
      return
    else
      output.push(token)
    end
  end



  puts 'output: ' + output.to_s
  puts 'ops:    ' + ops.to_s

  ostr = ''
  output.each do |t|
    ostr += t += ' '
  end
  ostr = ostr[0..-2] #truncate trailing space
  puts ostr

  output
end

def calculate(rpn)
  stack = Array.new
  rpn.each do |o|
    case o
      when /^\d+/           #number token
        stack.push(o.to_i)
      when /^[d\-\+\/\*]/   #operator tokens
        o1 = stack.pop
        o2 = stack.pop
        case $~.to_s
          when 'd'
            res = roll(o2,o1).inject(0,:+) #sum it
          when '-'
            res = o2 - o1
          when '+'
            res = o2 + o1
          when '/'
            res = (o2 / o1.to_f).round
          when '*'
            res = o2 * o1
        end
        stack.push res
      else
        puts  'invalid'
    end
  end
  stack.pop
end


def roll(qty,die)
  rolls = Array.new
  qty.times do
    rolls.push(rand(1..die))
  end
  rolls
end