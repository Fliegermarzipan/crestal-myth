require "colorize"
require "logger"

module Crestal::Myth
  class Log < Logger
    def initialize
      super(STDOUT)

      self.level = Logger::DEBUG

      severity_color = [
        :magenta,
        :blue,
        :green,
        :red,
        :yellow,
        :white,
      ]
      self.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
        label = severity.unknown? ? "ANY" : severity.to_s
        io << label.rjust(5).colorize(severity_color[severity.to_i]) << progname << ": " << message
      end
    end
  end
end
