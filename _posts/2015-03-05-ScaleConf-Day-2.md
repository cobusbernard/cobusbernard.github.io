---
layout: post
title: ScaleConf 2015 Day 2
exclude_comments: false
categories: [Conferences]
tags: [scaling]
fullview: false
---

**Scaling past 5 million**\\
*Matty Cohen*

Started the project in September 2011, 1 designer, engineer. Scaled that up to 3 engineers, didn't work on it full time. In November 2014, hit 5M downloads. Currently up to 4 full time engineers, ~6.5M downloads. Has 11k commits on GitHub.

**Understand your market**

**Hire passion & understanding**\\
A lot of people say the "understand" WordPress, need to ask proper tech questions to ensure the person really knows what they are talking about.

**Be aware of scale at all times**\\
All the code is open sourced, needs to be of high standard or the community will call them out on it. Good way to ensure that your product work is to eat your own dog-food. WooCommerce are their own biggest user.

**Unit tests for EVERYTHING**\\
The most important thing you should do. Each new method / function being added requires a test. Need to be able to know that your code works, not just "trust" that it does.

**Tools**
: - [Scrutinizer](https://scrutinizer-ci.com/): CI + code analysis
- [Coveralls](https://coveralls.io/): Unit test coverage
- [Transifex](https://www.transifex.com/): Language translations

A lot of these tools are free for open source projects. **Another [Slack](http://slack.com) using company!** Helps with the mindset shift - for all commits the committer will be notified if they do not have proper tests.

**Find the cookie monsters**\\
Need to get your product to be really loved by customers - if they don't, they will just use something else. Need to identify these kinds of customers, their feedback will be the most useful - they **really** want the product to be awesome.

**Help people to help other people**\\
Very meta, "We are an online store to help people make online stores." Helping others to succeed / do what they want to do.

**Key partnerships to solve key problems**\\
Someone wants [Stripe](https://stripe.com/) / [PayPal](https://www.paypal.com) / fulfillment, but don't have the expertise in-house. Forming partnerships to address these are extremely important. Note: go look at [Zapier](https://zapier.com/), automates everything!

**Develop for your ecosystem**\\
APIs, WebHooks. Installing plugins are difficult for non-professional WordPress users.

**Foster an ecosystem**\\
Your product is bigger than the box you ship it in. 327 contributors. All contributors are treated equally, it helps the product become better.

**Businesses built from WooCommerce**\\
[SkyVerge](https://www.skyverge.com/) / [Prospress](http://prospress.com/) - didn't exist prior to WooCommerce. Prospress is a subscription plugin for WooCommerce, best selling plugin.

**Expand other product lines around your product**\\
Developers get bored if they aren't solving problems, need to expand around the product. Started building plugins. *"My slider doesn't work in IE7"* - StoreFront theme doesn't have any sliders.

**Repeat and refine your formula**\\
*"Cook your favourite dish often, the more you do, the better it will get."*

---

**Building an Android App**\\
*Ales Koller and Hiren Patel*

[Android](https://www.android.com/) has been constantly be growing - there are a billion active Android users. Use the [MyCiti](http://myciti.org.za/) bus daily, but need to know where my bus is and how much money do I have on my card. Got a Nexus 4 with NFC, realised that the MyCiti can be scanned. KitKat allows Host Mode emulation mode - can pretend to be a card. The cards use open [EMV](http://en.wikipedia.org/wiki/EMV) schemes, hacked away at the binary data. Started with only the ability to show transactions + balance. Started adding more and more features. Used the Android wearables to add "where is my bus" option - allows finding out all your bus details without taking out your phone. Submitted the app to the store, got a lot of positive reviews. Best metric for Android apps. Google reached out to feature the app, but only if the UI was improved. Project isn't monitized at all - part of the challenge it to keep it entirely free. Need to also not cost to host / scale.

Used Twitter for scraping, but soon hit the rate limit - users received their info 4 days late. New button in Android studio allowed creating an AppEngine app. Wanted to learn something new, so decided to use it, but couldn't figure out what it would cost. This is when he contacted Hiren.

Used AppEngine as it is PaaS and had early benefits:
: * Daily free quota
* Simple setup process
* Low maintenance - disk space, security, etc are all abstracted away
* Language support - Java on Android and server.

Concerned that platform locked them in - did some research on if this would be an issue. Wasn't:
: * Data liberation front
* Easy export of persistent storage
* Open specifications.
* AppScale - allows running AppEngine apps on other infrastructure without changes.

Core components:
: * [AppEngine](https://appengine.google.com/)
* [Datastore](https://cloud.google.com/datastore/docs)
* [EndPoints](https://cloud.google.com/appengine/docs/java/endpoints/)

How to deploy the version with all the new shiny features, without breaking it for everyone. You have alpha, beta channels and you can do slow rollout via the AppStore. Rolling out to all users puts a lot of load on the system, forced learning about datastore and queue impacts. Can do split testing via the end point setup. When scaling, the first question is "does it need to scale." Looked at about 30 ~ 70k users, but there are 2.7M tourists. That could add 27k if only 1% used the app. Using the built-in load testing tool - made the instance count jump from 3 ~ 4 up to 40.

**Questions:**\\
What limitations are there on AppEngine, i.e. latest Spring?
Some things are limited, i.e. filesystem access, but you can get around that by using Managed VMs - treats your app like an AppEngine.

How did MemCache save costs?
Billed for reads from the DB, so made it cheaper.

---

**Scaling your frontend**\
*Donovan Graham*

It is divided into Web Sites and Apps. The usage / focus / implementation of the 2 differ a lot. User interfaces are hard to build. Managing state is very very hard. Using the right tool for the job: choose the correct framework and libraries.

---

**Bananas for scale**\\
*Chris Oloff / Albert de Jongh*

Outline:
* Know your metrics
* Know your system
* Change one thing at a time

If you have logs flooding past, it doesn't really give you any kind of insight into how your system is doing. As a first step, keeping counts and an average helps. But using those in a statement like *"The system has served 587846 requests in the last 532 seconds with an average response time of 123ms"*. If you had 50 failed calls in the last few seconds, that metric will not tell you anything about those failures. To address this, you need *recency* and *percentiles - reservoir sampling and forward decaying priority sampling. Watch the talk [Metrics Everywhere](www.youtube.com/watch?v=czes-oa0yik). There are libraries available for this, you shouldn't try to build it yourself.

Looking at the 1, 5, 15 minute and overall time-frame averages gives a much better feel for system health. Add in the different percentile views and you can really start to see how your system is performing. Drawing graphs over the last 24h, or different time frames.

**Metrics**\\
Many different settings you can change to try and resolve performance. Changing them without understanding exactly what they do will lead to problems -> slide on being sucked into an airplane engine.

---

**From screens to context**\\
*Tim Park*

Computers have been defined as a screen / keyboard for a long time (i.e. laptop). That changed with the first smart phones and more so with the IoT type toys like fitness bands, cars, etc.

---

**Scaling Learning**\\
*Sam Laing / Karen Greaves*

Very awesome talk, how do you scale transferring knowledge in a large organization? Tried professional recordings, took 3 days for 11mins of output. Shorter (10min) videos recorded with a phone are good enough. The content is more important that the recording quality.
