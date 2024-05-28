---
layout: post
title: Creating a build script with PSake
exclude_comments: false
tagline: How to easily build and package Web Api and library projects.
image:
categories: [DevOps]
tags: [windows, psake, webapi, builds]
fullview: false
---

In [the previous post]({% post_url 2016-02-06-Parameterizing_Webconfig %}), we added the ability to set parameters for our project when we do the deployment. Before we can get to that step, we need to be able to easily build and test our project.

**PSake**

[James Kovacs](https://github.com/JamesKovacs) created a [PSake](https://github.com/psake/psake) to do:

~~~
psake is a build automation tool written in PowerShell. It avoids the angle-bracket tax associated with executable XML by leveraging the PowerShell syntax in your build scripts. psake has a syntax inspired by rake (aka make in Ruby) and bake (aka make in Boo), but is easier to script because it leverages your existing command-line knowledge.

psake is pronounced sake – as in Japanese rice wine. It does NOT rhyme with make, bake, or rake.
~~~

The install instructions on the site will show you how to install it outside of Visual Studio, but as we are going to use it specifically for our project, we can cheat and use the Nuget Package Manager Console. You will find it under `TOOLS -> NuGet Package Manager -> Packge Manager Console`:

![Open NuGet Console]({{ site.url }}/assets/media/psake/psake_open_nuget_console.png){:width="696px" height="331px"}

To install, simply run `install-package psake -version 4.5.0` - we are supplying the version here as all the scripts will reference a specific location, more on this later.

![Install PSake]({{ site.url }}/assets/media/psake/psake_nuget_install.png){:width="1204px" height="338px"}

Let's create our first PSake file, open up your favourite text editor and create `default.ps1` in the root of the repository with the following:

~~~
Framework "4.0"

task default -depends PrintHelloWorld

task PrintHelloWorld {
  Write-Host "Hello World"
}
~~~

To run this, we can use the Package Manager Console. By default it will be in the root directory where the solution file is, but our build scripts will be one folder higher, so change to it using `cd ..` and then run `Import-Module '.\src\packages\psake.4.5.0\tools\psake.psm1'; Invoke-psake '.\default.ps1' default` to invoke our PSake script.

![Run PSake]({{ site.url }}/assets/media/psake/psake_run_default_task.png){:width="919px" height="273px"}

Great! We are able to start build tasks. We will ultimately run this command on some kind of [CI (Continuous Integration)](https://en.wikipedia.org/wiki/Continuous_integration) [server](https://en.wikipedia.org/wiki/Comparison_of_continuous_integration_software) so we will need an easy way to invoke this command. It will likely be called from a Command Prompt so the full command will be:

~~~
powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& { Import-Module '.\src\packages\psake.4.5.0\tools\psake.psm1'; Invoke-psake '.\default.ps1' default;  if ($lastexitcode -ne 0) {write-host "ERROR: $lastexitcode" -fore RED; exit $lastexitcode} }"
~~~

Create a file called `build.bat` in the root of the repository with that content. Once created, you should still be able to call it from the Package Manager Console:

![Run PSake from batch file]({{ site.url }}/assets/media/psake/psake_run_with_batch_file.png){:width="919px" height="334px"}

Let's change the PSake script to do something useful, like building our solution:

~~~
Framework "4.0"

task default -depends Compile

task Compile {
  exec {
   & msbuild /t:Clean`;Rebuild /p:VisualStudioVersion=14.0 /v:q /nologo /p:Configuration=Release src\WebApi.Template.sln /p:NoWarn=1591 /p:Platform="Any CPU"
  }
}
~~~

![Simple PSake Build]({{ site.url }}/assets/media/psake/psake_simple_compile.png){:width="913px" height="305px"}

Now that we can build, let's look at pacakaging things. I currently use [MSDeploy](http://www.iis.net/downloads/microsoft/web-deploy) for any applications served by IIS. MSbuild has the ability to package a project for you in the format that MSDeploy expects as we showed in the previous post via the `Publish` command. Create an new task in `default.ps1` called `package` that calls the task `NuGetPackage`. The reason for splitting it like this is that it makes it easier to see which tasks should be called from the command line, i.e.

~~~
Framework "4.0"

task default -depends Compile
task package -depends Compile, NuGetPackage

task Compile {  
}

task NuGetPackage {
}
~~~

This is easier to read when you have a lot of tasks than this:

~~~
Framework "4.0"

task default -depends Compile

task Compile {  
}

task NuGetPackage -depends Compile {
}
~~~

In the 2nd example, you would need to scroll through the file to find out which tasks are available to you. By putting the ones you make available at the top, it is much easier to see which ones they are.

Now add the `package` and `NugetPackage` tasks:

~~~
Framework "4.0"

task default -depends Compile
task package -depends Compile, NuGetPackage

task Compile {
  exec {
   & msbuild /t:Clean`;Rebuild /p:VisualStudioVersion=14.0 /v:q /nologo /p:Configuration=Release src\WebApi.Template.sln /p:NoWarn=1591 /p:Platform="Any CPU"
  }
}

task NuGetPackage {
  exec {
    msbuild /t:Package /v:q /p:VisualStudioVersion=14.0 /p:Configuration=Release /p:PackageLocation=dist\WebApi.Template.zip /p:ProjectParametersXMLFile=src\WebApi.Template\parameters.xml /p:DeployIisAppPath=dist src\WebApi.Template\WebApi.Template.csproj
  }
}
~~~

And create another batch file `package.bat` containing:

~~~
powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& { Import-Module '.\src\packages\psake.4.5.0\tools\psake.psm1'; Invoke-psake '.\default.ps1' package;  if ($lastexitcode -ne 0) {write-host "ERROR: $lastexitcode" -fore RED; exit $lastexitcode} }"
~~~

![Simple PSake Package]({{ site.url }}/assets/media/psake/psake_simple_package.png){:width="919px" height="392px"}

Now that we can reliably build, we need start thinking about version numbers. In a [previous post]({% post_url 2015-04-04-GitFlow-SemVer-PSake %}), I showed how you would generate a semantic version number. That script has evolved into this:

~~~
~~~

 Getting the version number (ref older post)
 Building
 Running tests (unit + integration)
 Packaging
 Uploading
