require 'rubygems'
require 'mechanize'
require 'nokogiri-styles'
require 'json'
require 'logger'

agent = Mechanize.new do |a|
  a.log = Logger.new('log.txt')
  a.user_agent_alias = "Windows IE 6"
end

agent.get "http://egrul.nalog.ru/" do |page|
  
  page_new_captcha = agent.get "http://egrul.nalog.ru/?r=new_captcha"
  h_code = JSON.parse page_new_captcha.body
  new_captcha = agent.get "http://egrul.nalog.ru/?r=captcha&h=#{h_code['h']}"
  new_captcha.save "captcha_eg.png"
  puts "enter captcha"
  captcha = gets
  captcha = captcha.delete("\n")

  result = page.form_with(id: 'search_form') do |form|
    form = page.forms.first
    form.action = "/?r=search"
    form.num = '7716527993'
    form.capcha = captcha
  end.submit

  result = JSON.parse result.body
  puts result['result']
end



