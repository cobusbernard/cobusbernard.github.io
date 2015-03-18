---
layout: post
title: Moving DNS to Amazon Route 53, Dynamic Updates
exclude_comments: false
tagline: Using Amazon Route 53 as primary nameserver. 
image:
categories: [Linux]
tags: [linux, openvpn, vpn]
fullview: false
---

In my previous post, I set up [OpenVPN on my home network]({% post_url 2015-02-14-openvpn-home %}) and [everything was awesome](https://www.youtube.com/watch?v=StTqXEQ2l-Y). Until this morning: I could not connect to my VPN. I had forgotten to set up some kind of [dynamic DNS](http://en.wikipedia.org/wiki/Dynamic_DNS0) updater for it. That should be easy enough, I had previously done this using [DynDNS](http://dyn.com/all-dns). Only problem was that the [service is no longer free](http://dyn.com/blog/why-we-decided-to-stop-offering-free-accounts/). This shouldn't be too much of a problem as I have a couple of my own domains - yes, I will one day still get round to finishing my pet project 'Tinkle Tones' ;)

My domains are split between a couple of different registrars using various tools to manage the DNS updating. Almost none of them had any kind of API for updating the DNS and I **really** don't want to create a hack by doing screen scraping and form posting. I decided to use [Route 53](http://aws.amazon.com/route53/) from Amazon to allow easy scripting of all my DNS needs. The last time I played with the service was in 2011 while doing some infrastructure automation / setup for [22seven](http://22seven.com). Quite a lot has changed in terms of features / the interface and I was pleasantly surprised to be able to register domains as well. The prices seemed on par with my registrars' fees; variation was a couple of dollars, but I would pay that with a smile if it allowed easy management. My only gripe was the cost of transferring a domain: it looks to be the same cost of registering a new one. A couple of my domains have just renewed, so I am going to wait before moving them.

Creating a new domain is dead easy: click 'Created Hosted Domain', add the domain name, a comment if you want and hit 'Create'. The resulting screen provides you with 4 name servers scattered across the world, I had a a .co.uk, .com, .net and .org. The numbers make you realise just how many nameservers Amazon has - my largest one was 1815. After updating my [NS records](http://en.wikipedia.org/wiki/List_of_DNS_record_types) at my registrar and duplicating the existing records on Route 53, I was ready to go.

![Records]({{ site.url }}/assets/media/route.53.dns.png)

Something for my TODO list: create a script for the [Google Apps](https://www.google.com/work/apps/business/) [MX records](http://en.wikipedia.org/wiki/MX_record) as I will use this for all my other domains - I am lucky enough to still have a couple of the free accounts.

I found [this script](http://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/) by searching for *'route 53 script update dns'*. Looks to be what I need, but the https cert was invalid for a short amount of time. Solution was to add another parameter to the curl command '-k' - credit to [this post](https://scottlinux.com/2012/02/14/curl-ignore-ssl-certificate-warnings/).

{% gist 8f7f99eeb9597d3a0979 %}}

The script was a good start, but I wanted to externalize the sensitive parts to allow committing this to a public repository. This led to a merry chase to acquire answers to more questions - [Aarron Patterson](https://twitter.com/tenderlove) spoke about *The joy of programming* at [RubyFuza](http://www.rubyfuza.org/) recently. Moving along swiftly ...

To interact with the AWS API, you will need to install the [CLI tools](http://docs.aws.amazon.com/cli/latest/userguide/installing.html). Quick notes copied from there to get [pip](https://pypi.python.org/pypi/pip) installed:

~~~bash
cd /tmp
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py

pip --help
~~~

And then the CLI:

~~~bash
sudo pip install awscli
~~~

Before we can use the CLI, we will need credentials to interact with the AWS. To generate these, open up your AWS console in the browser and go to the [IAM users](https://console.aws.amazon.com/iam/home#users). Create a new user with the following security policy - copy Hosted Zone ID from [Route 53]() and replace the value in the [ARN](http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) below with your one:

~~~
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:CreateHostedZone",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/BJBK35SKMM9OE"
      ]
    }
  ]
}
~~~

After creating the user, you will be presented with a AWS access key and secret for this user - keep them safe somewhere are you cannot retrive them after this point.

To set up an AWS CLI profile, use the credentials provided in the previous step, the default region and output format can be left empty:

~~~bash
aws configure --profile dns-update-your-site
~~~

Finally, to test that your script is working, run it:

~~~bash
./update-route53.sh BJBK35SKMM9OE dns-update-your-site example.com 1
~~~

This should output the following:

~~~
Force update is set.
IP has changed to 10.0.0.1, updating ...
~~~

The final step is to add this to a cron job, by running `crontab -e` and adding in (note that the trailing `1` has been removed to not force an update unless the IP has changed):

~~~bash
*/30 * * * * /home/will/scripts/update-route53.sh BJBK35SKMM9OE dns-update-your-site example.com
~~~

You should now have an updating DNS for your home connection that will update when you external IP changes by calling into Amazon's Route 53 API.
