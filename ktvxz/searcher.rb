module KTV
  module KTVXZ
    class Searcher
      require 'mechanize'
      require 'nokogiri'
      require 'logger'

      require_relative '../loggers/stdout'

      CREDENTIALS_FILE = File.join(File.dirname(__FILE__), '.credentials')
      COOKIES_FILE = File.join(File.dirname(__FILE__), '.cookies.yml')
      POST_DATA = "Keyword={{NAME}}&action=DVD1&Submit=+%CB%D1+%CB%F7+"
      LOGIN_URL = "http://dvd.ktvxz.com:3333/login.asp"
      INDEX_URL = "http://dvd.ktvxz.com:3333/1index.asp"

      DOWNLOAD_CURL_COMMAND = "curl 'http://dvd.ktvxz.com:3333/search.asp?page=1&action=dvd1&fangshi=xiazai&leixing=dvd1' -H 'Cookie: %s' -H 'Referer: http://dvd.ktvxz.com:3333/search.asp' --data 'chk=%s'"

      REGEX = /<td>\[(.*?)\]<input type="checkbox" name="chk" id="chk1" value="(.*?)">(.*?)   <\/td>/
      TASK_REGEX = /ThunderAgent.AddTask "(.*?)"/

      MAX_RETRIES = 10

      @@logger = KTV::Loggers::Stdout.new
      @@logger.push_prefix 'KTVXZ Searcher'

      def self.retrieve_link(value)
        agent = self.get_logged_in_agent

        begin
          page = agent.post('http://dvd.ktvxz.com:3333/search.asp?page=1&action=dvd1&fangshi=xiazai&leixing=dvd1', {
            'chk' => value.force_encoding('utf-8').encode('gb2312')
          }, {
            'Referer' => 'http://dvd.ktvxz.com:3333/search.asp'
          })
        rescue Mechanize::ResponseCodeError => e
          # Why the FUCK do you raise 500 on successful downloads??
          match = TASK_REGEX.match(e.page.body.force_encoding('gb2312').encode('utf-8', invalid: :replace, undef: :replace, replace: '?'))

          if match
            return match[1]
          else
            return nil
          end
        end

        nil
      end

      def self.search(keyword)
        agent = self.get_logged_in_agent
        res = []

        agent.get(INDEX_URL) do |index_page|
          result_page = index_page.form_with(name: 'myform') do |f|
            f['Keyword'] = keyword
          end.click_button

          body = result_page.body.force_encoding('gb2312').encode('utf-8')

          doc = Nokogiri::HTML(body)
          res = doc.css('#chk1').map do |chk|
            str = chk.parent.to_s
            match = REGEX.match(str)

            id = match[1]
            value = match[2]
            name = match[3]
            name.gsub!(/<font.*?>/, "")
            name.gsub!("</font>", "")

            {
              id: id.to_i,
              value: value,
              name: name
            }
          end
        end

        res
      end

      def self.get_logged_in_agent
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'

        if File.exists?(COOKIES_FILE)
          agent.cookie_jar.load COOKIES_FILE
          @@logger.log 'Cookies loaded from file. '
        else
          username, password = File.read(CREDENTIALS_FILE).lines
          username.strip!
          password.strip!

          agent.get(LOGIN_URL) do |login_page|
            login_page.form_with(action: 'login.asp?action=login') do |f|
              f.username = username
              f.password = password
            end.click_button
          end

          agent.cookie_jar.save_as COOKIES_FILE, session: true
          @@logger.log 'Cookies obtained and saved to file. '
        end

        agent
      end
    end
  end
end