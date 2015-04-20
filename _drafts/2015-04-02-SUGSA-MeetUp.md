---
layout: post
title: Release cadence: from 6 months to weekly.
exclude_comments: false
tagline: Notes from April SUGSA meetup: How to go from 6 month releases to 1 per week.
image:
categories: [Meetups]
tags: [sugsa, proces]
fullview: false
exclude_as_post: true
---


Nomanimi

Very robust device intended to allow non-conneected people to purchase services. I.e. prepaid water. The company started as a point of sale for taxis in Soweto - soon realised that they sucked at field operations. They were techies at heart, didn't want to learn how taxi unions funciton. Rolled out across 7 african countries, thousands of devices - not off the shelf, all self-built.

In 2011 they still did scrum (used Information Logistics). Kept the team size small - the hockey stick moment was in 2014. Why CI?
: * Product discovery
* Startup = limited cash runway
* Small team

Compounding improvements: 10% vs 15%  - after 2 years, the latter team is 2x more effective. "Move fast and break things". Methodical exploration takes longer, i.e. 95% every 2 weeks, doing 80% every week yields more exploration at the end of 4 weeks. Definition of done did not include "release". At the end of the sprint, there were completed stories, but they weren't released yet. "The problem with customers is that they report bugs..." Bugs prevent you from doing all your stories, which reduces the number of stories you can complete in a sprint, which in turn leads to technical debt building.

There was a lot of variance in the delivery: 20 points on average, but SD was 10. Average started dropping over time. Went back to waterfall, this failed nicely: the development portion always takes too long. Went back to scrum with 2 week iterations. Business wasn't happy as this was too slow, and for the dev team of 3, 1 week was too short. A release intially consisted of walking to the customer, manually updating and going back to the office. This doesn not scale.

With Kanban, they did a standard flow. Then realised that they needed to limit WIP. This negatively affected releases. You have the columns, but you also need to define swimlanes with different priorities. Defined SLAs for the different lanes. Team is allowed to deliver only 80% of the estimated stories. Make all stories done in "5 days" - break everything down into tasks that you can complete in ~5days. If not, then split it smaller.

Feedback loops: Dev in the centre is has the quickest, phases each side take longer. After 100 stories, their bottlenecks were reduced and they werer able to release all stories in under 9 days. The bottleneck shifted to development: now is the time to upgrade the hardware and speed them up. Tracking and graphing the output of the team is very important. The graphs enable business to answer their own questions i.t.o. what / how long tasks will take.

Started the project (greenfield) as automated testing. In 2012, started adding feature flags to decouple the feature release with the feature usage. When pushing out to production that quickly, you need monitoring. (Google BigQuery). Analyze the alpha / beta testers to ensure that the release makes thing better, not worse. Automated alarms to alert the devs that something is not right - it doesn't scale to 10,000's of terminals to monitor manually.

Calendar on the wall: everytime you push to production, you add a dot. This increases team morale - they want to move quicker.
