#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'json'
require 'mysql2'
require 'mail'

######### CONFIG ###########
look_for='docker'
db_db = 'hn_alert'
db_username = 'mdm'
db_password = 'charmes_g'
email_from = 'hn@docker.io'
email_to = 'julien@dotcloud.com'
email_title = "New mention of #{look_for} on HN"
############################

client = Mysql2::Client.new(:host => 'localhost', :database => db_db, :username => db_username, :password => db_password)
text = ""
url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?q=#{look_for}&limit=42&sortby=create_ts+desc"
parsed_json = JSON.parse(Net::HTTP.get(URI.parse(url)))

parsed_json["results"].each do |res|
  if res["item"]["type"] == "submission"
    safe_id_hn = res["item"]["id"].to_i
    sql = "SELECT `id` FROM `logs` WHERE `id_hn` = #{safe_id_hn} LIMIT 1"
    results = client.query(sql)
    if results.count == 0
      text += "SUBMISSION [ http://news.ycombinator.com/item?id=#{res["item"]["id"]} ] '#{res["item"]["title"]}' pointing to #{res["item"]["url"]}\n\n"
      d = Date.parse res["item"]["create_ts"]
      sql = "INSERT INTO `logs` (`id_hn`, `create_ts`, `type`, `title`, `url`) VALUES (#{safe_id_hn}, '" + client.escape(d.to_s) +
        "', 'SUBMISSION', '" + client.escape(res["item"]["title"]) + "', '" + client.escape(res["item"]["url"]) + "')"
      client.query(sql)
    end
  end
end

parsed_json["results"].each do |res|
  if res["item"]["type"] == "comment"
    safe_id_hn = res["item"]["id"].to_i
    safe_id_parent_hn = res["item"]["discussion"]["id"].to_i
    sql = "SELECT `id` FROM `logs` WHERE `id_hn` = #{safe_id_hn} LIMIT 1"
    results = client.query(sql)
    if results.count == 0
      text += "COMMENT direct link: [ http://news.ycombinator.com/item?id=#{res["item"]["id"]} ]\n" +
        "about '#{res["item"]["discussion"]["title"]}' [ http://news.ycombinator.com/item?id=#{res["item"]["discussion"]["id"]} ]\n\n"
      d = Date.parse res["item"]["create_ts"]
      sql = "INSERT INTO `logs` (`id_hn`, `create_ts`, `type`, `id_parent_hn`, `title`) VALUES (#{safe_id_hn}, '" + client.escape(d.to_s) +
        "', 'COMMENT', #{safe_id_parent_hn}, '" + client.escape(res["item"]["discussion"]["title"]) + "')"
      client.query(sql)
    end

  end
end

if (!text.empty?)
  text = "NEW mentions of #{look_for} on HN\n\n" + text
  Mail.deliver do
    from     email_from
    to       email_to
    subject  email_title
    body     text
  end
end
