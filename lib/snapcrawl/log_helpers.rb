require 'colsole'

module Snapcrawl
  module LogHelpers
    include Colsole

    SEVERITY_COLORS = {
      'INFO' => :txtblu,
      'WARN' => :txtylw,
      'ERROR' => :txtred,
      'FATAL' => :txtred,
      'DEBUG' => :txtcyn
    }
    
    def log_formatter
      proc do |severity, _time, _prog, message|
        severity_color = SEVERITY_COLORS[severity]
        line = "!#{severity_color}!#{severity.rjust 5}!txtrst! : #{message}\n"
        colors? ? colorize(line) : strip_color_markers(line)
      end
    end

    def colors?
      if Config.log_color == 'auto'
        tty?
      else
        Config.log_color
      end
    end

    def tty?
      ENV['TTY'] == 'on' ? true : ENV['TTY'] == 'off' ? false : $stdout.tty?
    end

    def strip_color_markers(text)
      text.gsub(/\!([a-z]{6})\!/, '')
    end
  end
end
