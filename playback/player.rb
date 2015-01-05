require_relative '../loggers/stdout'

module KTV
  module Playback
    class Player
      TMP_DIR = File.join('/tmp', 'ktv_playback')

      SILENCE_OUTPUT = ' 2>&1 >/dev/null'
      DEFAULT_PLAYBACK_CMD = 'mplayer %s -aid 1' + SILENCE_OUTPUT

      def initialize(file, logger = KTV::Loggers::Stdout.new)
        @file = File.expand_path(file)
        @preprocessors = []
        @logger = logger
      end

      def add_preprocessor(preprocessor)
        preprocessor.set_tmp_dir(TMP_DIR)
        preprocessor.set_logger(@logger)

        @preprocessors << preprocessor
      end

      def preprocess
        push_prefix

        @preprocessors.each do |p|
          p.preprocess(@file)
        end

        pop_prefix
      end

      def play
        push_prefix

        @preprocessors.reverse.each do |p|
          if p.respond_to?(:play)
            p.play(@file)
            pop_prefix
            return
          end
        end

        @logger.log('Playing...')
        `#{DEFAULT_PLAYBACK_CMD % @file}`

        pop_prefix
      end

      def cleanup
        push_prefix

        @preprocessors.reverse.each do |p|
          p.cleanup(@file)
        end

        pop_prefix
      end

      private
        def log_prefix
          File.basename(@file)
        end

        def push_prefix
          @logger.push_prefix(log_prefix)
        end

        def pop_prefix
          @logger.pop_prefix
        end
    end
  end
end