---
layout: post
title: ScaleConf 2015, Day 3
tagline: Notes for day 3 of ScaleConf
image: scale_conf_logo.png
exclude_comments: false
categories: [Conferences]
tags: [scaling]
fullview: false
---

**How to upgrade your databases**\\
*[Charity Majors](https://twitter.com/mipsytipsy) from [Parse](http://parse.com)*

Parse
: * Mobile backend with 500k apps
* Runs on AWS
* Mongo, cassandra, mysq, redis
* Ruby on Rails => golang

Operations / backend maintenance: if you do it well, no-one will notice. That is why operation engineers drink and swear a lot. [Benckmarketing](http://www.urbandictionary.com/define.php?term=benchmarketing). Why not to upgrade? "You can get fuuuucked". Additional risk for upgrading is that for the current version, you know where all the [gremlins](http://en.wikipedia.org/wiki/Gremlin) live, so you can avoid them. For new versions, it is like a write-your-own-adventure book: you will find them in surprising, new places.

So the basic steps for upgrading are:
: * Read the release notes
* Write some unit tests
* Finally sit down and evaluate risk

The "cowboy continuum": how much risk will you take for the new shiny version.
Anything with "[NoSQL](http://en.wikipedia.org/wiki/NoSQL)" in the description means your db is not mature. ;)

Risk assessment:
: * How mature is the DB
* How critical is the data - will the NY times know you are dowb?
* How mature is your company - can you afford 1 man-year of assessment
* Can you roll back? How hard will it be?
* How much does your workload push the boundaries o f the db? If you are doing new / out of boundaries things, make sure you can test properly

Your db content determines how risky upgrading the db is - using [Redis](http://redis.io/) for caching means a broken upgrade isn't hard to recover from. For [MySQL](http://www.mysql.com/) that contains usernames / passwords, you don't want to just do it. We do loads of different things with mongo that no-one else are doing.

Real production testing
: * YOUR query set
* YOUR data set
* with YOUR hardware
* and YOUR concurrency

When upgrading from MySQL 4 - > 5 at Linden, benchmarks said +10%, actual was -35%. Focussing on outliers provides the most information - break these down into to 50 / 75 / 90 / etc percentiles.

Correctness
: * Unit tests
* Tools to replay sample queries against 2 primaries (pt-upgrade)
* Traffic splitter
* Build traffic capture + replay

Base Performance
: * Snapshot data
* Capture ops
* Replay ops
* Reset snapshot, tweak variable, repeat

Mongo: going from 2.4 -> 2.6 took 9 months, to go to 3.0 will take a full year.

Replay tools: (mongo flashback)
: * Snapshot - from start of record run. Then create an LVM snapshot for resetting.
* Record - python tool to capture ops
* Replay - go too to play back ops
* Rewind snapshot, rinse, repeat

MySql tools
: * [Apiary](http://apiary.io/) (old, deprecated)
* [Percona](http://www.percona.com/) playback (new, shiny)

Make sure you are stressing the performance of your db, not your tool

When you feel confident that the upgrade will work without problems? "Never".
We

Data integrity, your sanity, query performance - you can only have 2 ...

---

**"Just" shard it**\\
*[Maggie Zhou](https://twitter.com/zmagg) from [Etsy](http://etsy.com)*

Initially designed a sharding solution in 2010 on MySQL.
Ticket server for UUID (twitter uses snowflake)
Taking 2 months to load balance the shards when adding new ones. So 2010's solution is not scaling.

Migrations were:
: * error prone
* arbitrary
* developers had to be aware
* created orphaned data
* locked shops / users out of changes for up to 8 hours
* slow


* Error prone? We can fix the errors - script more!
* Arbitrary? Write tooling to figure out which rows are right to migrate off / unit test
* Developers had to be aware? We can write better interfaces. Orphaned data?
* Deletes are expensive, so we didn't do them.
* Migrations created orphaned data on old hosts that were still picked up by full table scans (downstram systems: search, analytics). ** Financial systems were showing duplicate records!!**

Able to solve 1 - 4, but the locking and slowness haven't been solved yet.

For slowness, use logical sharding. So why not do that in the first place. You first need to understand the issue, i.e. run your site to learn your data access patterns. Etsy won't have viral traffic: once things are sold out, the shop will not be heavy traffic anymore. Changed to multiple logical shards per server. Up to 16 shards on a node.

So when you need to move / rebalance, you would:
:* Create a copy using a backup
* Then start replication to bring 2nd copy up to speed with the first one
* Split the writes for the logical shards to new shardpile (writing to 1/2 or to 3/4 (makes 3/4 dead on 1/2 and vice versa)
* Used the old row-based migration framework to migrate the system to the new sharding setup. Took 5 months

*'Why not NoSQL for sharding'?*
Etsy loves MySQL, not just about your team, but the cost to company. ORM expects to talk to some SQL-like DB.

---

**From horses to unicorns - Practical DevOps tools and tips.**\\
*[Shaun Norris](http://za.linkedin.com/in/shaunnorris) - [Amazon AWS](http://aws.amazon.com/)*

Standard process:
: * Dev (agile) -> Test (waterfall) -> Prod (waterfall). This leads to configuration drive.
* Expensive to replicate environments.
* Error prone deployments
* Different environments: dev --(days) --> test --(weeks) --> production

Goals are different: dev (ne features), ops (uptime)

How is DevOps different?
:*"The traditional model is that you take your software to the wall that separates development and operations, and throw it over and then you forget about it. Not at Amazon. You build it, you run it."*

[Conway's Law](http://en.wikipedia.org/wiki/Conway%27s_law): Org and culture will shape how you build your software.

Old way of different teams for db / deploy / dev don't work, rather have smaller service teams that do all the tasks.

How to scale your organization
: * Start with your customer, then work backwards.
* Hire full stack developers
* Adopt a "you build it, you run it" - if you get woken up by pages, you will be more motivated to fix the issue.
* Two pizza team rules - *if you can't feed the team with 2 pizzas, it is too big*. Smaller, focussed team is more efficient / successful.
* Hire for attitude, teach skills.

Automate everything
: * All types of testing: unit, functional, load and security. Shift them to the left - earliest possible point in the cycle.
* CI and CD.
* Infrastructure deployments and scaling.
* Log analysis and production feedback.

Automation Ideas
: * [Jenkins](http://jenkins-ci.org/), [Electric Cloud](http://electric-cloud.com/)
* [Chef](http://jenkins-ci.org/), Puppet, CloudFormation, Opsworks
* spluk, Smologic, lggly, datadog, elasticsearch + kibana

Load Testing
: * Redline13.com

Automation tips
: * Shift key testing activities left
* Adopt CI/CD
* Use containers
* Treat your infrastructure like code
* Aim for 'no login' production environment - tools make it so you don't need to log into servers (look at logs on kibana, etc).

Log everything
: * Storage has never been cheaper
* Analyze now
* Analyze later
* Data > intuition: assumptions are sometimes wrong ...

Api driver infrastrucure
: * Requires coding skills
* Required for full automation
* Immutable infrastructure
* Design for failure

**No LAMP, microservices!!!**

Adrian Cockcroft

Micrososervices tips
: * Small microservices > code monoliths
* Share nothing but APIs
* Use least expensive storage option - if you don't need a relational DB, don't use one. They are very expensive and least scalable.
* Use loose coupling
* Services > servers

Bare metal < VMs < Cloud instances < Containers < Lambdas

Loose coupling
: * Use queues
* Don't share databases
* Interservices comms via an API
* Scale services independently

Outputs of DevOps
: * Shorter cycle times
* Faster pace of innovation
* Security, reliability, availability, performance should all be better / higher

DevOps is not
: * A job title
* A tool or toolset

Better to have a clear roadmap for teams than to try and collaborate across them to avoid duplication - can consolodate it later. Floating architects.

---

**Scaling a web app to 15 million page views**\\
*Stephen Perelson from Mxit*

Caching
: * Was not forgottern, We'll do that later (prototype, for release we will fix this...)
* Needed to cache more than just DB:
** Pages are JSON blobs
** Pages must be rendered
** Mxit apps can go from zero to 10,000s of page views in minutes

Caching was tricky
: * Varnish wouldn't work
* Must cater for Mxit client differences (resolutions differences)
* Aslo server-side analytics
** Breaking Mxit's heaving caching
** Ensuring each page view gets tracked


Caching approach
: * Render the slow bits and cache those
* Unitque page is created for each client type:
* Use Memcache (Elasticache)
* Make sure to be able to invalidate a page (cache invalidation / eviction)

Advantages
: * Custom footers
* Special tags designed to be replaced
* Dynamic enough & fast enough
* Uncached page generation: 0.2 seconds
* Cached page generation: 0.002 seconds (100x)

Side-effects in the front-end
: * AngularJS - we were inexperienced
* Models get watched: Model changes, event fires
* Loading a page to edit would fire multiple calls to the backend - updates

Summary
: * Discover extraneous calls and resolve
* Try to reduce comms - size & repetition
* Cache from the beginnging - introduces side-effects, need to resolve that from the start

Data & MongoDB
: * Had text blobs for each message in MySQL ...
* A DB for every Launch app
* Centralised member collection
** Each member ahs an array of visited apps

That Central DB
: * Hut a few nukkuib ysers abd certaub qyerues becane very slow
* Newer mongodb releases helped slightly
* Decided to move members into each app's DB
* Took months to plan an prepare - live system

Migration plan
: * Duplicate data writes to old and new
* Migrate data across
* Move reads to new data and remove old writes
* Clean up old data

Extra bits
: * Domain specific enhancements at the same time:
** Certain apps do not require memeber data
** Don't update member data too often

*"When things break at scale, you will never know how it reacts"*

Summary #2
: * Changes will likely have to be made no matter how much you plan ahead
* Need to fully understand dataa, db and other systems in order to successfully plan a data migrations.

Infrastructure:
: * Need to scale out web servers
* Amazon specific
* Scaling:
** Cloudformation - custom AMIs
*** Watched the dev suffer
*** Never confident in this tech
*** Learned elastic beanstalk

Summary #3
: * Small teams need to reduce their admin burden as much as apossible
* Elastic Beanstalk is one such approach
* Separation of concerns
** Very modular
** Identify high traffic items (called often)
** Optimize or move to own service

---

**Scaling product development**\\
*Jeanre Swanepoel from IKhasi Digital*\

Challenges
: * Developer environments
* Rapid scaling the team
* Effective communication
* Infrastructure

On-boarding developers consist of "vagrant up".
