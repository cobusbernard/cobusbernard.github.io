---
title: Basic Jekyll GitHub Blog
description: Covers the basics of getting a Jekyll blog running on GitHub with a custom URL.
date: 2015-01-26
categories: [Ruby]
tags: [demo, jekyll, setup, ruby]
aliases:
  - /ruby/2015/01/26/basic-github-jekyll-blog
  - /ruby/2015/01/26/basic-github-jekyll-blog.html
---

So I finally got round to sorting out the tech blog. I chose to use [Jekyll](http://jekyllrb.com) rather than [WordPress](https://wordpress.com) as I didn't want to deal with constant updates, security vulnerabilities and backing up of the site. Jekyll generates a static site based on the posts created, but still has the advantages of a CMS like tags and categories. Posts are written using [Markdown](http://kramdown.gettalong.org/) in a plain text file, making it very easy to do the formatting. You are able to generate the site locally before publishing / pushing it elsewhere. This is where one of the other benefits come in: [GitHub Pages](https://pages.github.com/). You are able to create a repository with the format `<GitHub Username>.github.io` - in my case, that is [cobusbernard.github.io](https://cobusbernard.github.io). GitHub itself uses Jekyll, and by creating this repository, it automatically creates the Jekyll site for you. No backup is required as your site is already under version control in GitHub!

## Getting Started

First things first, need to have a decent look to the blog. Easiest solution was to grab a theme from [Jekyll Themes](http://jekyllthemes.org/), I decided to go for [dbyll](https://github.com/dbtek/dbyll) that you can [preview here](http://dbtek.github.io/dbyll/). After editing the required configs (hint: _config.yml), I previewed the outcome by running:

```bash
jekyll serve
```

High-fives all round... Celebrating mediocrity is fun ;) Moving along swiftly...

## Publishing to GitHub

To be able to publish this as a [GitHub Pages](https://pages.github.com/) project, you will first need to create a repository in GitHub called `<GitHub Username>.github.io`. The username has to match exactly what you have as your username in GitHub, mine is 'cobusbernard'. After creating the repo, you will need to initialise the local Jekyll folder as a git repo, set the remote to point to the newly created GitHub project and push your first version:

```bash
git init
git remote set-url origin git@github.com:cobusbernard/cobusbernard.github.io.git
git push -u origin master
```

Viola! Head on over to [\<GitHub Username\>.github.io](https://cobusbernard.github.io) and you should see your site. Most of the themes ship with some sample posts in the _posts folder. I created a _drafts folder to keep these for reference while I get comfortable with the [Markdown](http://kramdown.gettalong.org/) syntax.

## Custom Domain

I recently bought the domain [cobus.io](http://cobus.io) and wanted to point that to this blog. The [GitHub instructions](https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages/) seemed simple enough. To enable this, first add a file to your repo called `CNAME` **(all-caps is important!)** in the root of your repository with the domain name as content:

```bash
cobus.io
```

Do not prefix with `http://`!

Go to your GitHub repo and look at the settings section - to do this, follow [these instructions](https://help.github.com/articles/adding-a-cname-file-to-your-repository/). GitHub -> Repository -> Settings (right sidebar) -> Scroll down to *GitHub Pages*. You should see your custom domain name with a checkmark and a green background if all went well.

Lastly, you need to point your domain to the GitHub site by adding a [CNAME](http://en.wikipedia.org/wiki/CNAME_record) or a custom apex domain. In my case, I used the custom apex domain as I wanted just [cobus.io](http://cobus.io) to be the URL for the blog and not something like blog.cobus.io. This required having two A records (changing the existing one and adding another) for the GitHub IPs:

```bash
192.30.252.153
192.30.252.154
```

Once the DNS change has propogated (up to 24h), you will be able to access your blog / site from [\<GitHub Username\>.github.io](https://cobusbernard.github.io).

That is it, you should now be ready to start adding some content.

## Adding Content

Now let's try out some code blocks. Currently I am doing most of my work in C#, so would like to see if Jekyll supports the text markup for this correctly:

```csharp
public void Main(string args[])
{
    System.Console.Writeln("Hello World");
}
```

That worked! The markup is very easy, just wrap the code in `{% raw %} {% highlight csharp %} {% endraw %}` tags, i.e.

```text

{% raw %}

{% highlight csharp %}
public void Main(string args[])
{
  System.Console.Writeln("Hello World");
}
{% endhighlight %}
{% endraw %}
```

## Google Analytics

This will be a completely new area for me as I know what analytics do, but have never worked with them before. The easiest way to get going is to create an account on [Google Analytics](http://www.google.com/analytics/), set up a site and stick the chunk of Javascript they give you into the page. To do this cleanly, create a new file in [_includes/google_analytics.html](https://github.com/cobusbernard/cobusbernard.github.io/blob/master/_includes/google_analytics.html) that will contain the following:

```javascript
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '<tracking code>', '<site name>');
  ga('send', 'pageview');

</script>
```

This needs to be added to all the pages by adding the following line to [_includes/default.html](https://github.com/cobusbernard/cobusbernard.github.io/blob/master/_includes/default.html#L146):

```javascript
{% include google_analytics.html %}
```

## Comments

One of the major pain points for me on my almost non-existent blog were the number of spam comments I had to delete. I installed some plugins to deal with it, but some still slipped through. There were even some cases where my WordPress site was high-jacked due to some weird comment being added. To avoid this, use [Disqus](https://disqus.com) - create an account and set up your first site. Choose the *Universal* code option at the end and they will provide you with a chunk of Javascript to paste in. As with the Google Analytics, we don't want to just dump this into the file, but rather use another include. Create a file [_includes/comments.html](https://github.com/cobusbernard/cobusbernard.github.io/blob/master/_includes/comments.html) and add the Javascript into it:

```javascript
<div id="disqus_thread"></div>
<script type="text/javascript">
/* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
var disqus_shortname = '<disqus forum name>'; // required: replace example with your forum shortname
/* * * DON'T EDIT BELOW THIS LINE * * */
(function() {
  var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
  dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
  (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
```

To add the this to the page layout, edit the [default.html](https://github.com/cobusbernard/cobusbernard.github.io/blob/master/_includes/default.html#L134) page to include it above the footer by adding in:

```javascript
include comments.html
```

This will display the comments on all pages. To add the ability to exclude comments from certain posts, add a variable at the top of the specific post with:

```yaml
exclude_comments: true
```

Also wrap the _comments.html content with:

```javascript
{% raw %}
{% if page.exclude_comments == false %}
{% endif %}
{% endraw %}
```

When `exclude_comments` is set to `true`, the Disqus comment section will not be displayed.
