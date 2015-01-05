module KTV
  module Site
    class Searcher
      require 'mechanize'
      require 'nokogiri'

      CREDENTIALS_FILE = File.join(File.dirname(__FILE__), '.credentials')
      POST_DATA = "Keyword={{NAME}}&action=DVD1&Submit=+%CB%D1+%CB%F7+"
      LOGIN_URL = "http://dvd.ktvxz.com:3333/login.asp"
      INDEX_URL = "http://dvd.ktvxz.com:3333/1index.asp"

      REGEX = /<td>\[(.*?)\]<input type="checkbox" name="chk" id="chk1" value="(.*?)">(.*?)   <\/td>/
      TASK_REGEX = /ThunderAgent.AddTask "(.*?)"/

      MAX_RETRIES = 10

      def self.search(keyword, download = nil)
        agent = self.get_logged_in_agent
        res = []

        agent.get(INDEX_URL) do |index_page|
          result_page = index_page.form_with(name: 'myform') do |f|
            f['Keyword'] = keyword
          end.click_button

          if download
            download_page = result_page.form_with(name: 'gogo') do |f|
              f.checkbox_with(value: download).check
            end.click_button

            body = download_page.body
            match = TASK_REGEX.match(body)

            if match
              return match[1]
            else
              return nil
            end
          end

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

          if download
            return nil
          else
            return res
          end
        end
      end

      def self.try_get(keyword, download)
        MAX_RETRIES.times do
          begin
            res = search(keyword, download)

            return res if res
          rescue
          end
        end

        nil
      end

      def self.get_logged_in_agent
        username, password = File.read(CREDENTIALS_FILE).lines
        username.strip!
        password.strip!

        agent = Mechanize.new

        agent.get(LOGIN_URL) do |login_page|
          login_page.form_with(action: 'login.asp?action=login') do |f|
            f.username = username
            f.password = password
          end.click_button
        end

        agent
      end

      def self.get_song_link(value)
        agent = self.get_logged_in_agent

        a = {
          "ok" => "%D1%B8%C0%D7%CF%C2%D4%D8",
          "chk" => CGI.escape(value.force_encoding('utf-8').encode('gb2312'))
        }

        puts a

        page = agent.post('/search.asp?page=1&action=dvd1&keyword=%B3%C2%DE%C8%D1%B8&fangshi=xiazai&leixing=dvd1', {
          "ok" => "%D1%B8%C0%D7%CF%C2%D4%D8",
          "chk" => CGI.escape(value.force_encoding('utf-8').encode('gb2312'))
        })

        puts page.body
      end
    end
  end
end