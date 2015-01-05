# encoding: utf-8

require_relative 'ktvxz/searcher'
require 'cgi'

# keyword = gets.strip
# value = gets.strip

# value = nil if value.empty?

# puts KTV::Site::Searcher.try_get('一丝不挂', "1135714★3338")
# keyword = gets.strip
# puts KTV::KTVXZ::Searcher.try_get('陈奕迅')
# puts KTV::KTVXZ::Searcher.search('陈奕迅', '1401466★3340')

# puts KTV::KTVXZ::Searcher.search('酷爱')
puts KTV::KTVXZ::Searcher.retrieve_link('1318463★3335')
# puts KTV::KTVXZ::Searcher.search('陈奕迅', "1409245★3340")
# puts KTV::Site::Searcher.search('富士山下', "1331921★3336")

# KTV::Site::Searcher.get_song_link("1128301★3338")