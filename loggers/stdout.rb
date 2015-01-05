module KTV
  module Loggers
    class Stdout
      def initialize
        @prefixes = []
      end

      def push_prefix(prefix)
        @prefixes << prefix
      end

      def pop_prefix
        @prefixes.pop
      end

      def log(content)
        @prefixes.each { |p| print "[#{p}] " }
        puts content
      end
    end
  end
end