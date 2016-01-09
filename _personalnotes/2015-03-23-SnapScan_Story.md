---
layout: post
title: The SnapScan story
tagline: SnapScan
image:
exclude_comments: false
categories: [Meetups]
tags: [meetups]
fullview: false
---

**The SnapScan story**\\
*Kobus Ehlers*

Initially based the idea of Stripe, but it would not work in SA
: * Cards are chip & pin.
* Merchants didn't have smartphones / computers.

Catch 22, need both customers and merchants. Started with Coffee shops, small merchants and street vendors.
Tech isn't the hard part, the tricky part is to turn the tech into a product and then into a business.
Picked the street merchants as they couldn't get credit card machines, or they would be too expensive. Ditto for small merchants.
Got coffee shops to sign up to get a foothold in a consumer market.

Product pitch
: * Safe - people are nervous about carrying cash, or to hand over a card.
* Easy - lots of people will try something if it makes them feel cool (early adopters)
* Convenient - extremely easy to pay

The product is not sophisticated at all - this is intentional. Need to be easy to use, intuitive and fast - you don't want users to spend time in the app. You want then to not notice that they are using it. Bootstrapping a new user (FTUx):
: * Select yourself from address book
* Take photo of card
* Choose pin / touchId

For the merchant
: * It is cheap.
* Get money quicker, some cards still take up to 1 month
* No new hardware needs to bought
* Set up a new merchant in under 5 mins.


The origin story
-----
Started as part of [FireID](http://www.fireid.com/) to serve banks, etc. Then onto SafeBank 2, then Mahala then finally FireID Pay.
SafeBank 2 was a fairly simple product that integrated with banks, Mahala handled *everything*, ended up being crap. FireID Pay hooked into banks, demo'd, but never launched.

Found out it is interesting if you have a social network and offer transactional capabilities. (Mxit Money 2).

The idea originated after selling off the various startups, decided they wanted to leverage their existing patents / skills. Objective was to go out and buy a cup of coffee with a phone. First PoC in 11 days. Realised you can't roll out 400,000 merchants - too many to roll out physical payment solutions (own hardware). Started out as Doubloon and the v2.0 was called SnapScan.

Doubloon allowed you to checkout online - took 45 days for the first working PoC. It made sense on the consumer side, but not on the merchant side. After 2 months they found that integration works, but Google / Apple would kill it as they are just too big. You don't want to compete with online, one-click checkouts - luckily they were smart enough to realise this before going down that road.

Decided to copy Stripe - go to farmers markets
: * Zero risk
* Lots of bored, rich people.
* They will have smart phones.
* Not really worried about loosing card.

The merchants loved it, wanted to take the QR code to their shops. But there are laws around this. Started talking to Standard Bank to find out about insurance - they're selling point was the **you always get paid, they handle the risk**.

Started getting some press, nominated for [MTN](http://mtn.co.za) [App of the year](https://www.getsnapscan.com/media) - at that point their branding / marketing was bad. Needed to create a pitch pack within 48h for this - got the whole team (and devs) to rebrand, stock photos, etc. Involved anyone they knew. Didn't expect anything, but got through all the rounds and into the top 3. On night before the pitch, Kobus realised there is a Constantia in JHB - mad scramble to get tickets. Top tip - can't buy tickets after 10 on the night before. Ended up winning and receiving R200,000. Some competitions don't mean much, this one did as it forced the team to get their act together.

Started signing up shops, but they didn't quite understand the value proposition for people buying a cup of coffee - they loved it, but the understanding was still missing. Researched using Stellenbosch shops, then sold to [Standard Bank](http://standardbank.co.za). This really helped their marketing.

Initially had 2 devs, up to 4, then down to 3. After a year, had 2 people for sales and 2 for the business side. Started scaling it up a bit with the Standard Bank deal - up to 24 people, still 4 devs. Standard bank wanted the tv ads out within 5.5 weeks, lots of scramble and learnings.

They are now at a point where they can accept almost any kind of payment, including [Apple Pay](https://www.apple.com/apple-pay/) and [BitCoin](https://bitcoin.org/en/)
