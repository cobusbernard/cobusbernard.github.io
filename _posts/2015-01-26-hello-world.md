---
layout: post
title: Hello World!
comments: true
categories: [general, setup, demo]
tags: [demo, jekyll, setup]
fullview: true
---

So I finally got round to sorting out the tech blog. I chose to use [Jekyll](http://jykellrb.com) rather than [WordPress](https://wordpress.com) as I didn't want to deal with constant updates and security vulnerabilities. Jekyll generates a static site based on the posts created, but still has the advantages of a CMS like tags and categories. Posts are written using [Markdown](http://kramdown.gettalong.org/) in a plain text file, making it very easy to do the formatting. You are able to generate the site locally before publishing / pushing it elsewhere. This is where one of the other benefits come in: [GitHub Pages](https://pages.github.com/). You are able to create a repository with the format \<GitHub Username\>.github.io - in my case, that is [cobusbernard.github.io](https://cobusbernard.github.io). GitHub itself uses Jekyll, and by creating this repository, it automatically creates the Jekyll site for you.

Getting Started
---------------

First things first, need to have a decent look to the blog. Easiest solution was to grab a theme from [Jekyll Themes](http://jekyllthemes.org/), I decided to go for [dbyll](https://github.com/dbtek/dbyll) that you can [preview here](http://dbtek.github.io/dbyll/). After editing the required configs (hint: _config.yml), I previewed the outcome by running:

~~~ bash
jekyll serve
~~~

High-fives all round... Celebrating mediocrity is fun ;) Moving along swiftly...

Publishing to GitHub
--------------------
To be able to publish this as a [GitHub Pages](https://pages.github.com/) project, you will first need to create a repository in GitHub called \<GitHub Username\>.github.io. The username has to match exactly what you have as your username in GitHub, mine is 'cobusbernard'. After creating the repo, you will need to initialise the local Jekyll folder as a git repo, set the remote to point to the newly created GitHub project and push your first version:

~~~ bash
git init
git remote set-url origin git@github.com:cobusbernard/cobusbernard.github.io.git
git push -u origin master
~~~

Viola! Head on over to [\<GitHub Username\>.github.io](https://cobusbernard.github.io) and you should see your site. Most of the themes ship with some sample posts in the _posts folder. I created a _drafts folder to keep these for reference while I get comfortable with the [Markdown](http://kramdown.gettalong.org/) syntax.

Custom Domain
-------------
I recently bought the domain [cobus.io](http://cobus.io) and wanted to point that to this blog. The [GitHub instructions](https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages/) seemed simple enough. To enable this, first add a file to your repo called CNAME **(all-caps is important!)** in the root of your repository with the domain name as content:

~~~
cobus.io
~~~

Do not prefix with **http://!**

Go to your GitHub repo and look at the settings section - to do this, follow [these instructions](https://help.github.com/articles/adding-a-cname-file-to-your-repository/). GitHub -> Repository -> Settings (right sidebar) -> Scroll down to *GitHub Pages*. You should see your custom domain name with a checkmark and a green background if all went well.

Lastly, you need to point your domain to the GitHub site by adding a [CNAME](http://en.wikipedia.org/wiki/CNAME_record) or a custom apex domain. In my case, I used the custom apex domain as I wanted just [cobus.io](http://cobus.io) to be the URL for the blog and not something like blog.cobus.io. This required having two A records (changing the existing one and adding another) for the GitHub IPs:

~~~
192.30.252.153
192.30.252.154
~~~

Once the DNS change has propogated (up to 24h), you will be able to access your blog / site from [\<GitHub Username\>.github.io](https://cobusbernard.github.io).

That is it, you should now be ready to start adding some content.


Adding Content
--------------

Now let's try out some code blocks. Currently I am doing most of my work in C#, so would like to see if Jekyll supports the text markup for this correct:

{% highlight csharp %}
public void Main(string args[])
{
    System.Console.Writeln("Hello World");
}
{% endhighlight %}

That worked! The markup is very easy, just wrap the code in {% raw %} {% hightlight csharp %} {% endraw %} tags, i.e.

~~~
{% raw %}
{% highlight csharp %}
public void Main(string args[])
{
  System.Console.Writeln("Hello World");
}
{% endhighlight %}
{% endraw %}
~~~
