I've been neglecting my blog, and decided it is time to start writing again. So like any good software developer, I don't actually write a post, I start by tinkering with my blog setup. I initially ran it as a Jekyll generated static site on GitHub using GitHub Pages, and then as part of a live-stream, moved it to use AWS Amplify to host it in on of my many AWS accounts. Coming back to it a few years later, I still remember the headaches of dealing with different Ruby versions, getting `rvm` set up, and then only getting it going. The paging is currently not working, so I'll be trying to move over to Hugo for this.

The first step was to find a theme I liked, settled on [Toha](https://themes.gohugo.io/themes/toha/) by [Emruz Hossain](https://hossainemruz.github.io/) specifically for how I can have multiple sub-sections and [notes](https://hossainemruz.github.io/notes/). When looking at the [GitHub repo](https://github.com/hugo-toha/toha), it starts with a note about using `hugo modules` instead of the `git submodule` approach I previously used. Love how this yak-shaving mimics my usually day-to-day work where I only want to do that 1 things, but end up going down the rabbit hole. I'm jotting down the steps as I go for future reference.

Since I have no idea about what the tradeoffs are, I decided to use Amazon Q to help me through this whole process. I just installed it in VSCode, authenticated, and started asking away. Step one is to ask it:

```text
When setting up a new site using Hugo, can you please explain the difference between a git submodule vs a go module w.r.t. installing a theme?
```

Response:

```text
Suggested follow up questions:
Certainly, I'd be happy to explain the difference between using a Git submodule versus a Go module when installing a theme for a new Hugo site.

When using a Git submodule, you essentially link your Hugo site's repository to the repository of the theme you want to use. This means that the theme's source code is maintained in a separate repository, and your Hugo site's repository contains a reference to that theme repository. This approach has a few advantages: [1]

1. Separation of Concerns: By keeping the theme in a separate repository, you can more easily update the theme independently of your site's content and configuration.

2. Versioning: You can specify a specific version or commit of the theme that you want to use, which helps with maintaining consistency across different deployments of your site.

3. Collaboration: If you're working on a team, using a Git submodule makes it easier for other team members to clone your site's repository and have the theme available as well.

On the other hand, using a Go module for a theme integration is a more modern approach that is recommended by the Hugo team. With Go modules, the theme's source code is directly included in your Hugo site's repository, and the theme is treated as a dependency that is fetched and compiled as part of the build process.

The main advantages of using Go modules are:

1. Simplicity: There's no need to manage the submodule separately, as the theme is just another dependency that is handled by the Go module system.

2. Reproducibility: When you build your Hugo site, the exact versions of the dependencies (including the theme) are guaranteed to be used, making the build process more reliable and reproducible.

3. Tooling Integration: Go modules integrate well with the standard Go tooling, which can make managing dependencies and updating themes easier.

In summary, while both approaches can be used to install a theme for a Hugo site, the Go module approach is generally considered the more modern and recommended way, as it provides a more streamlined and integrated dependency management experience.

Sources
[1] Hugo website on github pages deployed through github actions is not working with custom theme
stackoverflow.comquestions67725758
```

So it looks like the module approach is what folks are doing nowadays, so here we go. After creating [my fork](https://github.com/cobusbernard/toha), and spending 30mins to update my details, I think I'm ready, although I still need to dig into Google Analytics V4 since it has changed, but that will be a task for tomorrow.

Following the [quickstart](https://toha-guides.netlify.app/posts/quickstart/), steps 1 - 3 seem straightforward, but then on step 4, it isn't clear if the `config.yaml` is in the theme repo, or my site repo. Neither exist, but searching for `baseURL` shows it is in the `hugo.yaml` file in my site's repo, so I edit this one with my details. I do suspect the version `v4` in `go.mod` will cause issues, this looks to be referring to a tag via the `/v4` and the long version number in `require github.com/cobusbernard/toha/v4 v4.4.1-0.20240510202123-a959cb174de6 // indirect`. Also seeing the same `/v4` in the `hugo.yaml` now as part of:

```yaml
# Use Hugo modules to add theme
module:
  imports:
  - path: github.com/cobusbernard/toha/v4
```

I'm going to remove the `/v4` in the above for now and see what happens when I try to start the server via the commands in step 5:

```bash
hugo mod tidy

go: github.com/cobusbernard/toha/v4@v4.4.1-0.20240510202123-a959cb174de6: invalid pseudo-version: preceding tag (v4.4.0) not found
hugo: collected modules in 1720 ms
Error: failed to load modules: failed to download modules: failed to execute 'go [mod download -modcacherw]': failed to execute binary "go" with args [mod download -modcacherw]: go: github.com/cobusbernard/toha/v4@v4.4.1-0.20240510202123-a959cb174de6: invalid pseudo-version: preceding tag (v4.4.0) not found
 *errors.errorString
```

Aaaaand there it is! Let's see what I should make it by chatting with Q:

```text
I've decided to use the hugo module approach, forked the repo, and updated the `go.mod` file as per instructions in the highlighted code, but when I try to run `hugo mod tidy`, I ge the following error:

go: github.com/cobusbernard/toha/v4@v4.4.1-0.20240510202123-a959cb174de6: invalid pseudo-version: preceding tag (v4.4.0) not found
hugo: collected modules in 1720 ms
Error: failed to load modules: failed to download modules: failed to execute 'go [mod download -modcacherw]': failed to execute binary "go" with args [mod download -modcacherw]: go: github.com/cobusbernard/toha/v4@v4.4.1-0.20240510202123-a959cb174de6: invalid pseudo-version: preceding tag (v4.4.0) not found
 *errors.errorString

I suspect it is due to the version included in the line starting with "require", can you please help me resolve this?
```

Response:

```text
Okay, let's take a look at the issue you're facing with the pseudo-version error when running 
hugo mod tidy
.

The error message indicates that the pseudo-version  v4.4.1-0.20240510202123-a959cb174de6 is invalid because the preceding tag v4.4.0 cannot be found. This suggests that the version specified in your go.mod file may not be a valid version for the github.com/cobusbernard/toha/v4 module.

Here are a few steps you can try to resolve this issue:

1. Check the available versions: First, you should check the available versions for the github.com/cobusbernard/toha/v4 module. You can do this by running the following command:
    go list -m -versions github.com/cobusbernard/toha/v4
    This will show you all the available versions for the module, and you can use this information to determine the correct version to use in your go.mod file. [1]

2. Update the version in go.mod: Based on the available versions, update the version in your go.mod file to a valid version. For example, if the latest version is v4.4.2, you can update the require line to:
    require github.com/cobusbernard/toha/v4 v4.4.2

3. Run hugo mod tidy again: After updating the version in the go.mod file, run 
hugo mod tidy again. This should resolve the pseudo-version error and allow you to successfully fetch the theme module.

4. Consider using a specific version tag: Instead of using a pseudo-version, you can also try using a specific version tag, such as v4.4.2. This can help ensure that you're using a known, stable version of the theme.
    require github.com/cobusbernard/toha/v4 v4.4.2

If you're still having issues after trying these steps, you may want to check the documentation for the github.com/cobusbernard/toha/v4 module or reach out to the module maintainers for further assistance.

Sources
[1] Go Modules: finding out right pseudo-version (vX.Y.Z--) of required package
stackoverflow.comquestions52242077
```

So that confirms the issue is due to a missing tag, and I want to avoid using a tag at all since I'm the only person working on this, and will just make changes directly on the `main` branch:

```text
How would I update the highlighted code of `go.mod` so that is uses the code on the `main` branch and not try to use a tag? Can I specify a go module without a tag?
```

Response:

```text
Yes, you can specify a Go module without using a tag in the go.mod file. To use the code from the main branch of the github.com/cobusbernard/toha/v4 module, you can update the go.mod file as follows: [1]

module github.com/cobusbernard/cobusbernard.github.io

go 1.19

require github.com/cobusbernard/toha/v4 v4.0.0-main

Here's how this works:

The require line now specifies the module version as v4.0.0-main. This is a pseudo-version that represents the latest commit on the main branch of the github.com/cobusbernard/toha/v4 module. The v4.0.0 part of the pseudo-version is a convention used to indicate that this is the latest version in the v4 major version series, even though there may not be an actual v4.0.0 tag in the repository.

The -main part of the pseudo-version indicates that this version corresponds to the main branch of the repository. By using this pseudo-version syntax, you can ensure that your Hugo site will use the latest code from the main branch of the github.com/cobusbernard/toha/v4 module, without being tied to a specific version tag.

When you run hugo mod tidy after making this change, the Go module system will fetch the latest commit from the main branch and use it in your Hugo site build. Keep in mind that using the main branch directly can introduce potential instability, as the code may change without warning. It's generally recommended to use a specific version tag if possible, to ensure a more stable and predictable build process.

Sources
[1] go.mod use modules without tags
stackoverflow.comquestions64549973
```

I still suspect the `/v4` in `require github.com/cobusbernard/toha/v4 v4.0.0-main` will cause an issue, but let's try it. 

```bash
hugo mod tidy

go: github.com/cobusbernard/toha/v4@v4.4.1-0.20240510202123-a959cb174de6: invalid pseudo-version: preceding tag (v4.4.0) not found
hugo: collected modules in 1720 ms
Error: failed to load modules: failed to download modules: failed to execute 'go [mod download -modcacherw]': failed to execute binary "go" with args [mod download -modcacherw]: go: github.com/cobusbernard/toha/v4@v4.4.1-0.20240510202123-a959cb174de6: invalid pseudo-version: preceding tag (v4.4.0) not found
 *errors.errorString
```

Yup, still an issue, so let's dig in some more:

```text
Do I need to specify the `require` line in go.mod at all, or can I take it out so it just uses the main branch's code?
```

Response:

```text
You don't necessarily need to specify the require line in the go.mod file if you want to use the code from the main branch of the github.com/cobusbernard/toha/v4 module. You can remove the require line altogether, and Hugo will automatically fetch the latest code from the main branch when building your site.

Here's what your go.mod file would look like in that case: [1]

module github.com/cobusbernard/cobusbernard.github.io

go 1.19

By removing the require line, you're telling the Go module system to use the latest version of the github.com/cobusbernard/toha/v4 module, which will automatically point to the main branch.

This approach can be convenient if you want to always use the latest code from the main branch, and don't need to lock down to a specific version. However, it's important to note that this can also introduce potential instability, as the code on the main branch may change without warning.

If you want a more stable and predictable build process, it's generally recommended to specify a specific version of the github.com/cobusbernard/toha/v4 module in your go.mod file, as we discussed earlier. This will ensure that your Hugo site uses a known, stable version of the theme, even if the main branch changes.

The choice between using the main branch directly or specifying a version depends on your specific needs and the level of stability you require for your Hugo site.

Sources
[1] Go: require module from local folder with replace
stackoverflow.comquestions74891171
```

Following this advice, it finally completes without an error, but I suspect it didn't include the theme module. Which it does when I try to run the next step for `hugo mod npm pack:

```bash
hugo mod tidy

go: no module dependencies to download

hugo mod npm pack

go: no module dependencies to download
```

Ok, I've spent enough time on this, let me just tag the theme fork with `v4` and see if `require github.com/cobusbernard/toha/v4 v4` works after running the following on my local copy of the theme:

```bash
git tag v4
git push --tags                                                

Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:cobusbernard/toha.git
 * [new tag]         v4 -> v4
```

That still has the same issue, and I suspect I need to create a GitHub Release first, so let's do that with `v1.0.0` as the tag and then call the release `v1.0.0`, and also clean up the old tags - I can never remember this git command, which is why I want that note section to refer back to ;)

```text
How do I delete a git tag locally and push that delete to the remote repository?
```

Response (summary):

```bash
git tag -d v1.0.0
git push --delete origin v1.0.0
```

After all that, `require github.com/cobusbernard/toha/v1 v1.0.0` seemed to work as I had no error, but also no output. I do suspect I should have just used the existing module instead of forking as I don't plan to edit the theme other than with my details and sections. But I'm keen to learn here, so let's see if that fixed it:

```bash
hugo mod npm pack
npm install

npm WARN deprecated popper.js@1.16.1: You can find the new Popper v2 at @popperjs/core, this package is dedicated to the legacy v1
npm WARN deprecated flag-icon-css@4.1.7: The project has been renamed to flag-icons

added 320 packages in 4s

93 packages are looking for funding
  run `npm fund` for details

hugo server -w

Watching for changes in /Users/cobusb/projects/Personal/toha/{archetypes,assets,content,data,i18n,layouts,package.hugo.json,package.json,static}
Watching for config changes in /Users/cobusb/projects/Personal/toha/config.yaml, /Users/cobusb/projects/Personal/toha/go.mod
Start building sites … 
hugo v0.126.1+extended darwin/arm64 BuildDate=2024-05-15T10:42:34Z VendorInfo=brew


                   | EN  
-------------------+-----
  Pages            | 40  
  Paginator pages  |  1  
  Non-page files   |  0  
  Static files     |  3  
  Processed images |  7  
  Aliases          |  4  
  Cleaned          |  0  

Built in 1873 ms
Environment: "development"
Serving pages from disk
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at //localhost:1313/ (bind address 127.0.0.1) 
Press Ctrl+C to stop
```

Woohoo! It is running! But not with the correct details. Digging into the code, I see the following in the theme for `layouts/partials/sections/home.html`:

```text
{{ $author:= site.Data.author }}
{{ if (index site.Data site.Language.Lang).author }}
  {{ $author = (index site.Data site.Language.Lang).author }}
{{ end }}

{{ $name:="Jane Doe" }}
{{ if $author.nickname }}
  {{ $name = $author.nickname }}
{{ else if $author.name }}
  {{ $name = $author.name }}
{{ end }}
```

It looks like it is not loading the data from the site project for `data/en/author.yaml` and the other files under English in `/en`. 