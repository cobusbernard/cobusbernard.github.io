---
layout: post
title: Hello World!
categories: [general, setup, demo]
tags: [demo, jekyll, setup]
fullview: true
---

So I finally got round to sorting out the tech blog. I chose to use [Jekyll](http://jykellrb.com) rather than [WordPress](https://wordpress.com) as I didn't want to deal with constant updates and security vulnerabilities. Jekyll generates a static site based on the posts created, but still has the advantages of a CMS like tags and categories. Posts are written using [Markdown](http://kramdown.gettalong.org/) in a plain text file, making it very easy to do the formatting. You are able to generate the site locally before publishing / pushing it elsewhere. This is where one of the other benefits come in: [GitHub Pages](https://pages.github.com/). You are able to create a repository with the format \<GitHub Username\>.github.io - in my case, that is [cobusbernard.github.io](https://cobusbernard.github.io). GitHub itself uses Jekyll, and by creating this repository, it automatically creates the Jekyll site for you.

Now let's try out some code blocks. Currently I am doing most of my work in C#, so would like to see if Jekyll supports the text markup for this correct:

{% highlight csharp %}
public void Main(string args[])
{
    System.Console.Writeln("Hello World");
}
{% endhighlight %}

That worked! The markup is very easy, just wrap the code in {% raw %} {% hightlight csharp %} {% endraw %} tags.

