---
layout: post
title: NodeJS 12 Factor App
exclude_comments: false
categories: [setup, linux]
tags: [linux, security]
fullview: true
---

Topic: 12 Factor Apps

Main Benefits:
* Easy for people to join
* Portable - clean contract
* CI easy - no divergence
* Suitable for cloud deployments
* Scalable

1-Codebase
-----------
Single app per repository, but you can deploy it multiple times (instances / versions)
More than 1 app == more than 1 repo => distributed system

2-Dependencies
--------------
Dependencies are packaged - use the package managers.
They must be isolated and not depend on the OS certain parts, i.e. wget / grep.

3-Config
--------
Separated from code - it varies across deploys.
Must **not** be committed - application config, i.e. routes.js is fine as this is the same across all versions.
Should use environment variables. (part of deployment process)
Node makes this easy (in general Node is suited to 12 factor)
If you can't opensource your code without exposing credentials, the config is not separated.
Configs are inside the docker container.

4-Backing Services
------------------
Treat them as attached resources - local (drive) / remote (db) / 3rd party (api). They can become unavailable.
Changing the resource should be as simple as a config -> #3

5-Build, Release, Run
---------------------
Strict separation, no code changes during runtime.
Build - take code from repo, fetch dependecies (vendoring), compiles assets / binaries (sing grunt / gulp)
Release - takes build and combines with config to prepare for running
  Should have rollback
  Has unique ID
  Immutable - you can never change a past release.
Build process complex, driven by devs.
Run - executing in environment
  Runtime needs to be automated - bring it back up when it dies (upstart)

6-Processes
-----------
Stateless - share nothing: memory, disk, data. I.e. storing session info in memory.
User content in backing service, i.e. S3
Asset compilation done on disk at runtime, should be done as part of build.

7-Port Binding
--------------
App binds directly on to port on startup, no web-server injection / Apache
Not just http, can be for backing services - think microservices (zeroMQ)

8-Concurrency
-------------
Follows Unix process model - scales out via process model (first class citizen??)
Never deamonize on its own or create a PID - relies on OS to do this. OS' differ and you don't want to code for each.
Process manager is responsible for managing and restarting if it crashes. Easier if you use docker.

9-Disposability
---------------
Able to be killed and restarted without losing anything. -> Elastic scaling and rapid deployment (kill, deploy, start)
Also for config changes.
Makes the app more robust.
Minimize startup and shutdown gracefully (stop listening, then finishes, then terminates)

10-Dev/Prod Parity
------------------
Keep environments the same - dev should be as close as prod possible.
Time gap - CD changes deployment from weeks into hours (takes care of difference between dev / prod)
People gap - dev vs ops, if developer can deploy (automated), dev / prod will be a lot closer.
Tooling gap - locally should develop on docker, that is the same container that will ship in the end.

11-Logging
----------
Unbuffered stream to STDOUT.
Underlying system takes care of this.

12-Admin Processes
------------------
DB Migration / cleanup / seeding
Need to run in the same environment.
Same release, codebase and config (admin code ships with the app)

Tools
-----
Deis (config tooling, personal heroku)
Roots.cs (builds static sites)
CoreOS (clustering / cloud systems)
Look for docker monitoring of multiple containers - would be nice to see them spin up
LogRouters - LogStash / fluentd / logplex
Artisan commands?
Docku (single server docker heroku)

Side-notes
----------
Ruby vs Javascript
Docker - talk end of feb. (Laravel meetup)
Ngena.com (search for docker node test)
Lxer (site)
