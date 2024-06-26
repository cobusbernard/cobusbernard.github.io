---
title: Migrating my Jekyll blog to Hugo with Gen-AI
description: Trying out Amazon Q to help me move my personal blog from Jekyll to Hugo
date: 2024-05-28
thumbnail: /posts/2024-05-28/migrating-jekyll-to-hugo/images/amazon_q_migrate_jekyll_to_hugo.png
categories: [gen-ai]
tags: [linux, aws-amplify, amazon-q, hugo, blog]
aws-services:
  - aws-amplify
  - amazon-q
---

I've been neglecting my blog, and decided it is time to start writing again. So like any good software developer, I don't actually write a post, I start by tinkering with my blog setup. I initially ran it as a Jekyll generated static site on GitHub using GitHub Pages, and then as part of a live-stream, moved it to use AWS Amplify to host it in on of my many AWS accounts. Coming back to it a few years later, I still remember the headaches of dealing with different Ruby versions, getting `rvm` set up, and then only getting it going. The paging is currently not working, so I'll be trying to move over to Hugo for this.

The first step was to find a theme I liked, settled on [Toha](https://themes.gohugo.io/themes/toha/) by [Emruz Hossain](https://hossainemruz.github.io/) specifically for how I can have multiple sub-sections and [notes](https://hossainemruz.github.io/notes/). When looking at the [GitHub repo](https://github.com/hugo-toha/toha), it starts with a note about using `hugo modules` instead of the `git submodule` approach I previously used. Love how this yak-shaving mimics my usually day-to-day work where I only want to do that 1 things, but end up going down the rabbit hole. I'm jotting down the steps as I go for future reference.

## Getting some help from Amazon Q

Since I have no idea about what the tradeoffs are, I decided to use Amazon Q to help me through this whole process. I installed the Amazon Q extension in VSCode, authenticated, and started asking away. Step one is to ask it:

```markdown
Prompt:
=======
When setting up a new site using Hugo, can you please explain the difference 
between a git submodule vs a go module w.r.t. installing a theme?

Response:
=========
Certainly, I'd be happy to explain the difference between using a Git submodule
versus a Go module when installing a theme for a new Hugo site.

When using a Git submodule, you essentially link your Hugo site's repository to 
the repository of the theme you want to use. This means that the theme's source 
code is maintained in a separate repository, and your Hugo site's repository 
contains a reference to that theme repository. This approach has a few 
advantages: [1]

1. Separation of Concerns: By keeping the theme in a separate repository, you 
   can more easily update the theme independently of your site's content and 
   configuration.

2. Versioning: You can specify a specific version or commit of the theme that 
   you want to use, which helps with maintaining consistency across different 
  deployments of your site.

3. Collaboration: If you're working on a team, using a Git submodule makes it 
   easier for other team members to clone your site's repository and have the 
   theme available as well.

On the other hand, using a Go module for a theme integration is a more modern 
approach that is recommended by the Hugo team. With Go modules, the theme's 
source code is directly included in your Hugo site's repository, and the theme 
is treated as a dependency that is fetched and compiled as part of the build 
process.

The main advantages of using Go modules are:

1. Simplicity: There's no need to manage the submodule separately, as the theme 
   is just another dependency that is handled by the Go module system.

2. Reproducibility: When you build your Hugo site, the exact versions of the 
   dependencies (including the theme) are guaranteed to be used, making the 
   build process more reliable and reproducible.

3. Tooling Integration: Go modules integrate well with the standard Go tooling, 
   which can make managing dependencies and updating themes easier.

In summary, while both approaches can be used to install a theme for a Hugo site, 
the Go module approach is generally considered the more modern and recommended way, 
as it provides a more streamlined and integrated dependency management experience.

Sources
[1] Hugo website on github pages deployed through github actions is not working with 
custom theme stackoverflow.comquestions/67725758
```

## Planning

Before we get too carried away, let's build ourselves a todo list to move the blog:

```markdown
Prompt:
=======

I have a personal blog currently deployed using AWS Amplify from a GitHub repository 
that is public, with Disqus for comments, Google Analytics for my site analytics, 
and would like to change it to use Hugo, but keep the other technologies the same, 
can you please create a todo list for me to ensure I don't forget to migrate something?

Response:
=========
Certainly, here's a suggested todo list to help you migrate your personal blog from 
GitHub Pages with Jekyll to using Hugo, while keeping the existing technologies like 
AWS Amplify, Disqus, and Google Analytics:

TODO List for Migrating Personal Blog from Jekyll to Hugo:

1. Set up a new Hugo project
   - Create a new Hugo site using the `hugo new site` command
   - Choose a suitable Hugo theme, such as the Toha theme you mentioned previously

2. Migrate content from Jekyll to Hugo
   - Convert your existing Markdown posts to the Hugo format
   - Ensure that the front matter (metadata) in your posts is compatible with Hugo

3. Configure AWS Amplify for the new Hugo site
   - Create a new Amplify app for your Hugo site
   - Set up the necessary build settings and environment variables
   - Configure the Amplify app to use your new Hugo site's repository

4. Integrate Disqus comments
   - Add the necessary Disqus shortname and configuration to your Hugo site's templates

5. Integrate Google Analytics
   - Add the Google Analytics tracking code to your Hugo site's templates
   - Ensure that the tracking code is compatible with the latest version of Google 
     Analytics (GA4)

6. Update DNS and domain settings
   - If you're using a custom domain, update the DNS settings to point to your new Hugo 
     site hosted on AWS Amplify

7. Test the migration
   - Thoroughly test your new Hugo-based site to ensure that all features, content, and 
     integrations are working as expected
   - Verify that your site is rendering correctly and that all links, images, and other 
     assets are properly loaded

8. Redirect old Jekyll-based URLs (optional)
   - If you had a significant number of existing URLs for your Jekyll-based site, consider 
     setting up URL redirects to ensure that existing links continue to work

9. Update any external references (e.g., social media, email signatures)
   - Update any references to your old Jekyll-based site with the new Hugo-based site URL

10. Monitor and maintain the new Hugo-based site
    - Set up monitoring and alerting for your new Hugo-based site hosted on AWS Amplify
    - Keep your Hugo version, theme, and dependencies up-to-date to ensure security and 
      stability

Remember, this is a general todo list, and the specific steps may vary depending on your 
existing setup and the technologies you're using. It's always a good idea to thoroughly 
test and validate each step of the migration process to ensure a smooth transition for 
your personal blog.
```

<br/>

The `toha` theme mentioned above is due to a longer discussion on figuring out the theme install first, but this is a decent list. The only step I would update is point 4 - for Disqus, you would also need to migrate the existing comments if the domain or path structure of the content changed. Luckily there are [a few ways to do it](https://help.disqus.com/en/articles/1717068-migration-tools), I will just need to look into how to handle redirects with Hugo, it should be a standard feature.

I do need to confess that I went down a rabbit hole first here when I followed the [quickstart](https://toha-guides.netlify.app/posts/quickstart/) without realising those instructions are for modifying and publishing the theme to then pull into Hugo as a module. But I digress, let's build this!

## Barebones site

Following the steps in the [getting started guide](https://toha-guides.netlify.app/posts/getting-started/prepare-site/), I ran the following:

```bash
git checkout -b switch-to-hugo # Let's not break the site before we are ready to move
mkdir old
mv !(old)* old/ # Include all files / folders, but not hidden ones, and exclude the one called "old".

hugo new site ./ --format=yaml --force
hugo mod init github.com/cobusbernard/cobusbernard.github.io # Repo name is a left-over from when I used GitHub pages

# Adding the theme module to the Hugo config
cat << EOF >> hugo.yaml
module:
  imports:
  - path: github.com/hugo-toha/toha/v4
  mounts:
  - source: ./node_modules/flag-icon-css/flags
    target: static/flags
  - source: ./node_modules/@fontsource/mulish/files
    target: static/files
  - source: ./node_modules/katex/dist/fonts
    target: static/fonts
EOF

hugo mod get -u
hugo mod tidy
hugo mod npm pack
npm install

hugo server -w
```

And voila! The site is up and running, but very bare. I then spent some time updating the configs with all my details, and added the sections I needed. Next, I need to migrate my old content from the Jekyll front matter format to the one for Hugo. This was a tedious, manual task, but an hour or 3 later I was done. Also, past-Cobus really needs to sort out consistency in filenames, this is what I found - you can clearly spot when I started working at a company that used quite a lot of Python:

```bash
.
├── 2011-07-25-Ubuntu-on-HyperV.md
├── 2012-02-04-git-rpc-error.md
├── 2012-03-27-Terminal-install-Java-Ubuntu-10.10.md
├── 2012-04-10-chrome_default_xubuntu.md
├── 2012-04-12-ssh-config-multiple-keys.md
├── 2013-01-28-ssh-rate-limit.md
├── 2015-01-26-basic-github-jekyll-blog.md
├── 2015-02-08-convert-putty-keys-to-openssh.md
├── 2015-02-13-openvpn-on-digital-ocean.md
├── 2015-02-14-openvpn-home.md
├── 2015-02-17-route-53-dns-update-script.md
├── 2015-02-19-mdadm-replace-drive.md
├── 2015-02-27-git-checkout-ssh-vs-https.md
├── 2015-03-30-MSBuild-External-Error.md
├── 2015-04-04-GitFlow-SemVer-PSake.md
├── 2015-12-16-NTP-on-AWS.md
├── 2016-02-06-Parameterizing_Webconfig.md
├── 2016-02-18-Upgrading_Berks_Dependency_Issue.md
├── 2016-06-12-Centos_Gluster_Startup.md
├── 2016-09-03-AWS_Multi_Account.md
├── 2017-01-15-timemachine-backups.md
├── 2017-02-05-Yak_shaving_Makefiles.md
├── 2017-02-09-OSX_Home_End_Keys.md
├── 2024-05-28-migrating-jekyll-to-hugo.md
└── _index.md
```

## Deploying the new version

Now that the main site is ready, I want to deploy it from the branch to double check that everything works and I didn't miss anything. This is fairly simple with Amplify, at least it would be once I can remember in which account I deployed it - I have about 7 - 9 that I used, will do a write-up soon of why I use to many. More yak-shaving later as I had to add MFA to my [root accounts](https://docs.aws.amazon.com/IAM/latest/UserGuide/enable-virt-mfa-for-root.html), then trying to revive my South African mobile number on a phone missing 2cm of screen on the left-hand side to reset the MFA on the account where I *think* my site is deployed, I gave up. Also realised that using auto-branch detection for Amplify won't work out of the box as it would use the same build as for the main branch (which is for Jekyll, not Hugo), I decided to add a `buildspec.yml` to this branch to test if it works. My theory is that if I test this in another account, and the branch builds & deploy, I should just be able to merge it to my `master` branch where my site is - I still need to update the repo to use `main` for the branch name, but that would require me to be able to log into the account where I have the Amplify app running.

> **2024-06-07 Update:** Finally rewatched the livestream where Darko and I migrated my site and realised it wasn't using my `cobus.io` domain, my site will still being deployed using GitHub Pages, this has been updated now to use Amplify.

To create the build configuration, I was lazy and just asked Q:

```text
Prompt:
=======

Can you please show me a build file for AWS Amplify to build my Hugo app? What should the filename be for Amplify to use it in the branch?

Response:
=========

Certainly! For AWS Amplify to build your Hugo-based site, you'll need to create a build specification (buildspec) file. The filename for this file should be buildspec.yml, as this is the default name that Amplify looks for.

Here's an example buildspec.yml file that you can use to build your Hugo site on Amplify:

version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 14
    commands:
      - echo "Installing Hugo..."
      - wget -q https://github.com/gohugoio/hugo/releases/download/v0.111.3/hugo_0.111.3_Linux-64bit.deb
      - sudo dpkg -i hugo_0.111.3_Linux-64bit.deb
  pre_build:
    commands:
      - echo "Installing dependencies..."
      - npm ci
  build:
    commands:
      - echo "Building the Hugo site..."
      - hugo
artifacts:
  files:
    - '**/*'
  base-directory: public
cache:
  paths:
    - 'node_modules/**/*'

```

Mostly looks ok, except I want to use Hugo `0.126.1` to match what I have running locally, I'm not too sure `nodejs: 14` is a recent enough version, and lastly, the line for `- npm ci` seems very odd, so I'll be removing it. Final `buildspec.yml` in the root of the repo is now:

```yml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 14
    commands:
      - echo "Installing Hugo..."
      - wget -q https://github.com/gohugoio/hugo/releases/download/v0.126.1/hugo_0.126.1_Linux-64bit.deb
      - sudo dpkg -i hugo_0.126.1_Linux-64bit.deb
  pre_build:
    commands:
      - echo "Installing dependencies..."
  build:
    commands:
      - echo "Building the Hugo site..."
      - hugo
artifacts:
  files:
    - '**/*'
  base-directory: public
cache:
  paths:
    - 'node_modules/**/*'
```

I set up a new Amplify application (Hey! The Amplify console has a new look!) by connecting it to my GitHub account, selecting the `cobusbernard.github.io` repo, and then ignoring the fact that the detected build settings was empty. I'm not surprised it couldn't pick up my old Jekyll site's build as it is 7 years old, I vaguely remember needing to add some custom steps. I think. Now I just need to wait for the build and hope it works... which it did not. The following in the AWS Console may be a hint:

> *To modify your app's build spec choose 'Edit'. Alternatively, you may download the YML file and deploy in the root of your repository to as amplify.yml to override this setting.*

The file should be called `amplify.yml` according to that line, so let's do that. And again it breaks:

> *!!! CustomerError: Missing frontend definition in buildspec*

Clearly there is an issue with the layout of `amplify.yml`, so I stop being lazy and open the [documentation](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html). The default example uses `npm run build`, which is why there was that line for `npm ci` I believe. I also took a look at the [Hugo documentation for Amplify](https://gohugo.io/hosting-and-deployment/hosting-on-aws-amplify/), which seems to be what I want, so here is the updated version:

```yml
version: 0.1

frontend:
   phases:
      build:
          commands:
            - echo "Building the Hugo site..."
            - hugo
   artifacts:
      baseDirectory: public
      files:
         - '**/*'
cache:
  paths: []
```

Finally this works, sort of:

![Hugo blog site shown without any CSS](images/no_css_site.png)

Looking at the page source, it is referencing `http://localhost:1313`, which is the default for local development. Looking at my `hugo.yml` config file, the `baseURL` is set to `/`, which is likely the cause. After searching and reading a few different solutions, it appears I need to either create multiple config files depending on which environment I'm deploying to, or I can use the `-b  https://mydomain.com/` build flag to specify the domain. Since I don't have access to my current production deployment environment, I need to be very careful here, so let's see if I can use the [environment variables in the build](https://docs.aws.amazon.com/amplify/latest/userguide/environment-variables.html) to work around this. I should be able to use the following ones with some logic:

1. `AWS_BRANCH` - name of the branch from the repository, would need to check for `main` / `master`
2. `AWS_APP_ID` - the ID of the Amplify App, used in the URL with the format `https://<branch>.<AWS_APP_ID>.amplifyapp.com`.

My approach is to set `baseUrl: https://cobus.io` in the Hugo config, and then detect in the build if I'm on the `main` / `master` branch, and only call the `-b` flag to override it when I am not. Let's take the easy route again:

```text
Prompt:
=======

Given 2 environment variables AWS_BRANCH and AWS_APP_ID, can you please provide me with a bash script that will generate a string in the form "https://AWS_BRANCH.AWS_APP_ID.amplifyapp.com" when the AWS_BRANCH is not set to "main" or "master"? Please store this string in an environment variable called APP_DEPLOY_DOMAIN. 

Response:
=========

#!/bin/bash

# Check if AWS_BRANCH is set and not equal to "main" or "master"
if [ -n "$AWS_BRANCH" ] && [ "$AWS_BRANCH" != "main" ] && [ "$AWS_BRANCH" != "master" ]; then
    APP_DEPLOY_DOMAIN="-b https://$AWS_BRANCH.$AWS_APP_ID.amplifyapp.com"
else
    APP_DEPLOY_DOMAIN=""
fi

# Export the APP_DEPLOY_DOMAIN variable
export APP_DEPLOY_DOMAIN
```

So in theory, the following updated `amplify.yml` should do the job - I had to ask Amazon Q how to do a multi-line command in the build file, and also just to double check that `hugo $APP_DEPLOY_DOMAIN` would work - I always get confused between `$ENV_VAR` and `$(ENV_VAR)`. The "final" build file now after adding in `https://cobus.io` for the `else` clause:

```yml
version: 0.1

frontend:
   phases:
      build:
          commands:
            - echo "Building the Hugo site..."
            - |
              if [ -n "$AWS_BRANCH" ] && [ "$AWS_BRANCH" != "main" ] && [ "$AWS_BRANCH" != "master" ]; then
                APP_DEPLOY_DOMAIN="https://$AWS_BRANCH.$AWS_APP_ID.amplifyapp.com"
              else
                APP_DEPLOY_DOMAIN="https://cobus.io"
              fi
              export APP_DEPLOY_DOMAIN
              echo "App Deployment Domain set to $APP_DEPLOY_DOMAIN"
            - hugo -b $APP_DEPLOY_DOMAIN
   artifacts:
      baseDirectory: public
      files:
         - '**/*'
cache:
  paths: []
```

Finally a working build of any new branch! Yay! Time to merge to the `master` branch - I will be doing a squash merge to turn this into a single commit instead of the multiple ones I had before.

## Migrating Disqus comments

The last step before I do that merge is to ensure I can migrate the existing Disqus comments. Luckily there is a way to add a redirect for any page via the following in the front matter:

```yaml
aliases:
  - "/version control/2012/02/04/git-rpc-error.html" # The quotes here are needed as using %20 without them didn't work
```

Disqus has a tool [Redirect Crawler](https://help.disqus.com/en/articles/1717126-redirect-crawler) that will then migrate all of the discussions for you, so I'll kick that off afterwards.

## Conclusion

This was quite a bit of fun for me as I learnt a few new things, and had some challenges to dig into. Having a gen-ai assistant directly in my IDE does make a big difference though, I find myself using it more often now, but I do always take a moment to make sure it isn't hallucinating. Think of them as that smart person at work how usually knows the answer, but sometimes just bluffs when they don't. The main time sink ended up not understanding how the module approach for themes work, and then spending way too much time trying out different themes. In the end, I didn't use the Toha theme, but opted for the [Poison](https://github.com/lukeorth/poison) one after tweaking it a little bit, still have some changes I would like to add. But that will wait for another day, the next item on my TODO is to sort out all my AWS accounts.
<!-- 
## Completing the switch

**2024-06-07 Update:** Just finished implementing the custom domain, Amplify now has the option to auto-manage the SSL certificate for me, so I used that. Now I'm just waiting on the deployment to complete, and then it should all be done.

![Amplify creating the SSL certificate in the console](images/amplify_applying_custom_comain.png) -->
