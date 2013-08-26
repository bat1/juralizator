# encoding: utf-8

class SearchController < ApplicationController
  def index
  end
  def get_captcha
    agent = create_agent
    captcha_img_file_path = ""
    agent.get "http://egrul.nalog.ru/" do |page|
      page_new_captcha = agent.get "http://egrul.nalog.ru/?r=new_captcha"
      h_code = JSON.parse page_new_captcha.body
      new_captcha = agent.get "http://egrul.nalog.ru/?r=captcha&h=#{h_code['h']}"
      captcha_img_file_path = "captcha/captcha_#{Digest::SHA1.hexdigest(Time.now.to_s)}.png"
      new_captcha.save  "public/#{captcha_img_file_path}"
    end
      session[:jar] = agent.cookie_jar.jar['egrul.nalog.ru']['/']['PHPSESSID']

    respond_to do |format|
      format.json do
        render json: [captcha: captcha_img_file_path]
      end
    end
  end
  def do_search
    agent = create_agent
    result = nil
    agent.get "http://egrul.nalog.ru/" do |page|
      agent.cookie_jar.jar['egrul.nalog.ru']['/']['PHPSESSID'] = session[:jar]
      puts agent.cookie_jar.jar['egrul.nalog.ru']['/']['PHPSESSID'] 
      result = page.form_with(id: 'search_form') do |form|
        form = page.forms.first
        form.action = "/?r=search"
        form.num = params[:inn]
        form.capcha = params[:captcha]
      end.submit
    end
      respond_to do |format|
        format.json do
          render json: [ result: result.body ]
        end
      end
  end

  def full_search
      result = google_query(create_agent, params[:org][:name].delete("&quot;"))
      result.each do |li|

      end
      first_link_with_site = result.first.search(".r").first.search("a").first.attributes['href'].value
      respond_to do |format|
        format.json do
          render json: [ result: ['site' => first_link_with_site.inspect] ]
        end
      end
  end

  def law_search
    agent = create_agent
    results = agent.get("http://rospravosudie.com/act-#{params[:org][:name].delete("&quot;")}-q/section-acts/").search(".table a")
    results =results.map { |r| [url: r.attributes['href'].value, value: r.text] }
    respond_to do |format|
      format.json do
        render json: [ result: results ]
      end
    end
  end

  private
    def create_agent
      agent = Mechanize.new do |a|
       a.log = Logger.new('log.txt')
       a.user_agent_alias = "Windows IE 6"
      end
      #unless session[:jar].nil?
      agent
    end
    def create_google_client
      client = Google::APIClient.new
      client.authorization.access_token = 'AIzaSyDQsz0wkqFcJyJ6Qmk6JpUQuhbABmaX4O4'
      search = client.discovered_api('customsearch') 
      return client, search
    end
    def google_query(agent, query)
       agent.get('http://google.com/') do |page|
         result = page.form_with(name: "f") do |form|
           form.field_with(name: 'q').value = query.to_s
         end.submit
         return (result/"li.g")
       end
    end
end

