# Hacke rNews Alerts

A simple Ruby script to be alerted by email whenever one specific keyword is mentioned on YCombinator [Hacker News](http://news.ycombinator.com) (not just on the front page).
By design this script covers the frontpage, the new submitted articles and comments. For hosted service and more features see [HNWatcher](http://www.hnwatcher.com).

The code is based on the [hnsearch API](https://www.hnsearch.com/api) / [ThriftDB Search API](http://www.thriftdb.com/documentation/rest-api/search-api)

## Usage

Modify the file [alert_hackernews.rb](https://github.com/jbarbier/hackernews_alert/blob/master/alert_hackernews.rb) & configure your database as follow.
Then add the script to the cron jobs. And wait for alerts :)

### Keyword

Update the file [alert_hackernews.rb](https://github.com/jbarbier/hackernews_alert/blob/master/alert_hackernews.rb), line 10

```
look_for = 'docker'
```

### Email

Update the file [alert_hackernews.rb](https://github.com/jbarbier/hackernews_alert/blob/master/alert_hackernews.rb) from line 14 to 16

```
email_from = 'your@email_from.io'
email_to = 'your@email_to.com'
email_title = "New mention of #{look_for} on HN"
```

#### Database

Create the MySQL database and add the table from the [mysql.db](https://github.com/jbarbier/hackernews_alert/blob/master/mysql.db) script file

```
CREATE TABLE `logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_hn` int(11) NOT NULL,
  `id_parent_hn` int(11) DEFAULT NULL,
  `create_ts` date NOT NULL,
  `type` enum('SUBMISSION','COMMENT') NOT NULL DEFAULT 'SUBMISSION',
  `title` varchar(1024) DEFAULT NULL,
  `url` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8;
```

Update the file [alert_hackernews](https://github.com/jbarbier/hackernews_alert/blob/master/alert_hackernews.rb) with the right credentials (lines 11-12-13)

```
db_db = 'hn_alert'
db_username = 'mdm'
db_password = 'charmes_g'
```

### Cron

Add the script as a cron job with the frequency you want it to check for your keyword on HackerNews

## Next steps

Be free to use the code and improve it to:
- add more than one keyword (being able to monitor several keywords on HackerNews)
- add more than one email to be alerted
- add more information (usernames, points, ...)
- add a back office to list all mentionned on HackerNews (from the database)
- add a back office option to manage the keywords and the emails for each keyword

## Questions?

If you have any questions, feel free ton contact me on [twitter](https://twitter.com/julienbarbier42)

## HNWatcher
For hosted service and more features see [HNWatcher](http://www.hnwatcher.com).

Have fun!


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/jbarbier/hackernews_alert/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

