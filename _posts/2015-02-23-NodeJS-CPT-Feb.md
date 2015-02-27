---
layout: post
title: NodeJS February Meetup
exclude_comments: false
categories: [Meetups]
tags: [nodejs, docker]
fullview: false
---

**Node.js for IOLmobile.co.za**\\
*Evan Summers*\\
23 February 2015

Reason for changing
---
* Better US (no page reloads)
* Rapid UI Protyping (no rebuilds)
* Browser tooling e.g. Chrome Dev Tools
* JavaScript performance improvement

Reason for Angular
---
* Testability
* Modularity
* Seperation of concerns

PayPal Case Study
---
* 33% less lines of code
* Developed almost twice as fast with fewer people
* Double the requests / second
* 35% decrease in response times

Cons
----
* Not typed
* Async in nature - callback hell [promises]
* Long running process / calculations block [offload to cluster]

Pros
----
* Rapid development of JSON microservices
* Code and mind sharing between front / back-end
* High performance, low resource requirements
* Vibrant community for 3rd part libraries
* npm !!

Uses
----
* JSON microservices for web / mobile [Native JSON]
* Back-end microservices for SPAs [language homogeneity]
* Integration glue [Network services, SOA, microservices]
* Isomorphic web pages [Jade, handlebars, react componentes]
* Testing

Better ways of working working with JS
-----
* TypeScript
  * Types, interfaces
  * Compile-time type checking, runtime erasure
  * Opensource
  * IDE Support: VS, WebStorm, Eclipse
* Facebook Flow
  * Static typ checking, gradual typing
* CoffeeScript
  * Syntactic sugar for JavaScript

Cost of Microservices
------
* Integration testing and debugging can be tricky
* Complicated to manage whole products
* High operations overhead
* DevOps and own tools might be required
* Required superherioc admins

Benefits of Microservices
------
* Resilience, performance, and scalability [Tolerate failures, cache, scale out - stateless]
* Enables emerging tech like Node [Node is awesome for HTTP/JSON microservices]
* Productivity and satisfaction [Prototype, deploy quickly and independently, less meetings, more coding]
* Integrate and test via HTTP [using the browser, curl, Node scripts]
* Canary releases with Docker
* Decompose database service [mix sql with nosql]

Infrastructure
-----
* Offload auth* to API gateway - NGinX

Notes
-----
* Javascript - The Good Parts (Douglas Crockford)
* Check with JSLint for "bad parts"
* Google's AtScript - Traceur transpiler
* JSON Viewers pluging for Chrome - makes JSON pretty
* Cloudflare - has edge server in JHB, free?
* Reactive Manifesto
* 12 Factor apps
* Logly / GreyLog2


Json notation: $: ?
