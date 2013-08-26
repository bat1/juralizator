jQuery ->
  get_captcha()
  $("#search_form").submit (e) ->
    e.preventDefault()
    $("#wrap").slideUp()
    if $("#captcha").val() == ""
      get_captcha()
    else
      do_search $("#inn").val(), $("#captcha").val()
      $("captcha").empty()
      get_captcha()

get_captcha = ->
  $.getJSON "/get_captcha.json", {}, (captcha) ->
    $("#captcha_img").attr "src", captcha[0]['captcha']
do_search =  (inn, captcha) ->
  $.getJSON $("#search_form").attr("action"), {inn: inn, captcha: captcha}, (json) ->
    result = JSON.parse json[0]['result']
    if result['result']['found']
      found = result['result']['found']
      orgs = result['result']['orgs']
      org = orgs[0] 
      $("#item-name").html org['name']
      $("#item-date").html org['date']
      $("#item-address").html org['address']
      org['name'] = org['name'].replace(/&quot;/g,'').replace(/ограниченной/,'О').replace(/ответственностью/,'О').replace(/[оО]бщество/,'О')
      full_search org
      law_search org
      debit_search org
      $("#info-panel").slideDown()

full_search = (org) ->
  $.get "http://ajax.googleapis.com/ajax/services/search/web", {v: '1.0', q: org['name']}, ((data) ->
    console.log data
    results = data['responseData']['results']
    $("#item-site").html results[0]['visibleUrl']
    $("#item-site").attr 'href', results[0]['url']
    for result in results
      do (result) ->
        $("#more-url ul").append("<li><a href='"+result['url']+"'>"+result['title']+"</a>"+"</li>") if result['title']
  ), "jsonp"

law_search = (org) ->
  $.getJSON "/search/law.json", {org: org}, (data) ->
    console.log data
    for d in data[0]['result']
      do (d) ->
        $("#court-list").append "<li><a href='http://rospravosudie.com/#{d[0]['url']}'>#{d[0]['value']}</a></li>"
        console.log d[0]['url']

debit_search = (org) ->
  $.get "http://ajax.googleapis.com/ajax/services/search/web", {v: '1.0', q: "долги #{org['name']}"}, ((data) ->
    console.log data
    results = data['responseData']['results']
    for result in results
      do (result) ->
        $("#credit-list ul").append("<li><a href='"+result['url']+"'>"+result['title']+"</a>"+"</li>") if result['title']
  ), "jsonp"


