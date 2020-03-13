require 'logger'

module Snapcrawl
  module Logging
    SEVERITY_COLORS = {
      'INFO' => :blue,
      'WARN' => :red,
      'ERROR' => :red,
      'FATAL' => :red,
      'DEBUG' => :none
    }

    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDOUT, formatter: log_formatter)
    end

  private

    def log_formatter
      proc do |severity, _time, _prog, message|
        severity_color = SEVERITY_COLORS[severity]

        "%{#{severity_color}}#{severity.rjust 5}%{reset} : #{message}\n" % log_colors
      end
    end

    def log_colors
      @log_colors ||= log_colors!
    end

    def log_colors!
      tty? ? actual_colors : empty_colors
    end

    def actual_colors
      {
        red: "\e[31m", green: "\e[32m", yellow: "\e[33m",
        blue: "\e[34m", purple: "\e[35m", cyan: "\e[36m",
        underlined: "\e[4m", bold: "\e[1m",
        none: "", reset: "\e[0m"
      }
    end

    def empty_colors
      {
        red: "", green: "", yellow: "", 
        blue: "", purple: "", cyan: "",
        underlined: "", bold: "",
        none: "", reset: ""
      }
    end

    def tty?
      ENV['TTY'] == 'on' ? true : ENV['TTY'] == 'off' ? false : $stdout.tty?
    end
  end
end