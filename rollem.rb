require 'yaml'
require './rollem_bot.rb'

#Rollem's core class. Manages each instance of Rollem
module Rollem
  class Rollem
    #Instances of Rollem
    #stores a mapping of server_id => rollem instance
    @instances

    #Alias mapping
    #stores a mapping of alias => server id
    @server_alias_to_id

    #Server ID to addresses
    #stores a mapping of server id => array of ips
    @server_id_to_data

    def initialize()
      load_server_list()
      create_cinch_army()
    end

    def load_server_list()
      @server_alias_to_id = Hash.new
      @server_id_to_data = Hash.new
      aliases = YAML.load(File.open( 'config_junk/servers.yml' ))
      aliases.each do |key,value|
        puts 'alias "' + key + '" => "' + key + '"'
        @server_alias_to_id[key] = key
        if value["aliases"] then
          value["aliases"].each do |dat_alias|
            puts 'alias "' + dat_alias + '" => "' + key + '"'
            @server_alias_to_id[dat_alias] = key
          end
        end
        if value["servers"] then
          @server_id_to_data[key]
          t_array = Array.new
          value["servers"].each do |input|
            input = input.split(':')   #split address,port
            address = input[0]
            port    = input[1].to_i if input[1]
            #puts key + ": " + address + " " + port.to_s
            s = ServerData.new(address,port)
            puts s[:address]
            puts s[:port]
            Test.new(s)
            t_array.push(s)
          end
          @server_id_to_data[key] = t_array
        end
      end
    end

    #creates all needed cinch wrapper objects
    def create_cinch_army()
      @instances = Hash.new

      servers = YAML.load(File.open( 'config_junk/join_list.yml' ))
      defaults = servers["defaults"]
      if defaults then
        d_nickname = defaults["nickname"]
        d_authtype = defaults["authtype"]
        d_password = defaults["password"]
      end

      servers["servers"].each do |server,entry|
        nickname = entry["nickname"]
        authtype = entry["authtype"]
        password  = entry["password"]
        nickname = d_nickname if nickname.nil?
        authtype = d_authtype if authtype.nil?
        password = d_password if password.nil?
        channels = entry["channels"]
        @instances[server] = RollemBot.new(@server_id_to_data[server][0],
                                           channels,nickname,authtype.to_s.to_sym,password.to_s)
      end
    end

    def start()
      wait_list = Array.new
      @instances.each do |key,value|
        wait_list.push(value.start())
      end
      wait_list.each do |thread|
        thread.join
      end
    end

    def die()
      @instances.each do |key,value|
        value.die
      end
    end

    def alias_to_id(dat_alias)
      @server_alias_to_id[dat_alias]
    end
  end
end

$rollem = Rollem::Rollem.new
$rollem.start