# encoding: utf-8

require_relative 'site/searcher'
require 'cgi'

# keyword = gets.strip
# value = gets.strip

# value = nil if value.empty?

puts KTV::Site::Searcher.try_get('一丝不挂', "1135714★3338")
# puts KTV::Site::Searcher.search('富士山下', "1331921★3336")

# KTV::Site::Searcher.get_song_link("1128301★3338")