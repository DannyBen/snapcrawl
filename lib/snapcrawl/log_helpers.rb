require 'colsole'

module Snapcrawl
  module LogHelpers
    include Colsole

    SEVERITY_COLORS = {
      'INFO'  => :b,
      'WARN'  => :y,
      'ERROR' => :r,
      'FATAL' => :r,
      'DEBUG' => :c,
    }

    def log_formatter
      proc do |severity, _time, _prog, message|
        severity_color = SEVERITY_COLORS[severity]
        line = "#{severity_color}`#{severity.rjust 5}` : #{message}\n"
        use_colors? ? colorize(line) : strip_colors(line)
      end
    end

    def use_colors?
      @use_colors ||= (Config.log_color == 'auto' ? tty? : Config.log_color)
    end

    def tty?
      case ENV['TTY']
      when 'on' then true
      when 'off' then false
      else
        $stdout.tty?
      end
    end
  end
end
