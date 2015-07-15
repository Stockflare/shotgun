require 'shotgun'

module Shotgun
  class CLI

    attr_reader :argv

    def initialize(argv = [])
      @argv = argv.dup
      configure_zone!
    end

    def run
      fork &method(:main)
    rescue Interrupt
    end

    def main
      begin
        exec *argv unless argv.empty?
      rescue Errno::EACCES
        error "not executable: #{argv.first}"
      rescue Errno::ENOENT
        error "command not found: #{argv.first}"
      end
    end

    private

    def configure_zone!
      zone = argv.index('-zone')
      return ENV['HOSTED_ZONE'] unless zone
      argv.delete_at(zone)
      Shotgun.zone = argv.delete_at(zone)
    end

    def error(message)
      puts "ERROR: #{message}"
      exit 1
    end

  end
end
