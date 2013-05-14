require 'cinch'
require 'yaml'
require './rollem_bot'

module Cinch
  module Plugins
    class Help
      include Cinch::Plugin
      match /(?i)help/, method: :help
      match /(?i)code|source/, method: :code
      match /(?i)owner/, method: :owner
      match /(?i)bug|issue|issues|request|feature\srequest|/, method: :issues

      @code_message
      @help_message
      @owner_message
      @issues_message

      def initialize(*args)
        super

        puts "File exists? " + File.exists?('persist/config/config.yml').to_s
        yaml = YAML.load(File.open( 'persist/config/config.yml' ))
        yaml = Hash.new if not yaml
        @code_message = yaml['code-message'] || "code-message not defined in persist/config/config.yml"
        @help_message = yaml['help-message'] || "help-message not defined in persist/config/config.yml"
        @owner_message = yaml['owner-message'] || "owner-message not defined in persist/config/config.yml"
        @issues_message = yaml['issues-message'] || "issues-message not defined in persist/config/config.yml"


      end

      def help(m)
        m.reply("#{@help_message}")
      end

      def code(m)
        m.reply("#{@code_message}")
      end

      def owner(m)
        m.reply("#{@owner_message}")
      end

      def issues(m)
        m.reply("#{@issues_message}")
      end
    end
  end
end