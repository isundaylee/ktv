module KTV
  module Playback
    module Preprocessors
      class Transposer
        SILENCE_OUTPUT = ' 2>&1 >/dev/null'
        EXTRACT_AUDIO_CMD = 'mplayer "%s" -ao pcm:fast:file=%s -vo null -vc null -aid 1' + SILENCE_OUTPUT
        TRANSPOSE_CMD = 'rubberband -p%d "%s" "%s"' + SILENCE_OUTPUT
        PLAYBACK_SEPARATE_CMD = 'mplayer "%s" -audiofile "%s" -delay -0.5' + SILENCE_OUTPUT

        def initialize(semitones, retain_file = false)
          @semitones = semitones
          @retain_file = retain_file
        end

        def set_tmp_dir(tmp_dir)
          @tmp_dir = tmp_dir
        end

        def set_logger(logger)
          @logger = logger
        end

        def preprocess(file)
          require 'fileutils'

          push_prefix

          FileUtils.mkdir_p(tmp_dir(file))

          if File.exists?(tmp_audio_path(file))
            @logger.log 'Audio already extracted. '
          else
            @logger.log 'Extracting audio...'
            `#{EXTRACT_AUDIO_CMD % [file, tmp_audio_path(file)]}`
          end

          if File.exists?(tmp_transposed_audio_path(file))
            @logger.log 'Audio already transposed. '
          else
            @logger.log 'Transposing audio...'
            `#{TRANSPOSE_CMD % [@semitones, tmp_audio_path(file), tmp_transposed_audio_path(file)]}`
          end

          pop_prefix
        end

        def play(file)
          push_prefix

          @logger.log 'Playing...'
          `#{PLAYBACK_SEPARATE_CMD % [file, tmp_transposed_audio_path(file)]}`

          pop_prefix
        end

        def cleanup(file)
          push_prefix

          unless @retain_file
            @logger.log 'Cleaning up...'

            FileUtils.rm(tmp_audio_path(file))
            FileUtils.rm(tmp_transposed_audio_path(file))
          end

          pop_prefix
        end

        private
          def file_identifier(file)
            require 'digest'
            Digest::SHA256.hexdigest(file)
          end

          def tmp_dir(file)
            File.join(@tmp_dir, file_identifier(file))
          end

          def tmp_audio_path(file)
            File.join(tmp_dir(file), 'audio.wav')
          end

          def tmp_transposed_audio_path(file)
            File.join(tmp_dir(file), "transposed_audio #{@semitones}.wav")
          end

          def log_prefix
            "Transposer #{@semitones}"
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
end