---
layout: post
title: Creating a NuGet package for your build scripts.
tagline: Using NuGet to allow installing build scripts for all new projects.
image:
exclude_comments: false
categories: [dotnet]
tags: [msbuild, nuget, git, csharp]
fullview: false
---

I've been building a lot of functionality into a C# build script the last few months and kept copying it to each project by hand. This meant that any improvement also needs to be copied manually. It stopped making sense when we hit around 5 projects with this approach and currently we are on ~50. The POC has grown into a [protoduction](http://blog.codinghorror.com/new-programming-jargon/) system, time to fix this.

The first attempt was to create a new Git repo and add it as a sub-module to each project requiring it. The biggest problem with this was that the Windows build slaves would not consistently do the checkout. Tried various fixes, but ended up abandoning that idea.

The next attempt was to use NuGet to install a package to a project that would pull in the build system and also create scripts to build the solution. We wanted the repo layout to be as follow:
{% highlight text %}
<root>
|-src
| |-Your.Project.sln
|-build.bat (for local developer builds)
|-ci.bat (for Jenkins builds)
|-package.bat (creates package via msbuild publish)
{% endhighlight %}

The first step is to create a new `nuspec` file by running
{% highlight powershell %}
nuget spec Your.Project.Name
{% endhighlight %}

This will create the following:
{% highlight xml %}
<?xml version="1.0"?>
<package >
  <metadata>
    <id>Your.Project.Name</id>
    <version>1.0.0</version>
    <authors>Cobus Bernard</authors>
    <owners>Cobus Bernard</owners>
    <licenseUrl>http://LICENSE_URL_HERE_OR_DELETE_THIS_LINE</licenseUrl>
    <projectUrl>http://PROJECT_URL_HERE_OR_DELETE_THIS_LINE</projectUrl>
    <iconUrl>http://ICON_URL_HERE_OR_DELETE_THIS_LINE</iconUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Package description</description>
    <releaseNotes>Summary of changes made in this release of the package.</releaseNotes>
    <copyright>Copyright 2015</copyright>
    <tags>Tag1 Tag2</tags>
    <dependencies>
      <dependency id="SampleDependency" version="1.0" />
    </dependencies>
  </metadata>
</package>
{% endhighlight %}

Set/remove the relevant values and add in any dependencies, in my case this is the final version:
{% highlight xml %}
<?xml version="1.0"?>
<package >
  <metadata>
    <id>Your.Project.Name</id>
    <version>1.0.0</version>
    <authors>Cobus Bernard</authors>
    <owners>Blue Battleship</owners>
    <projectUrl>http://some.url/Your.Project.Name</projectUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Installs the CSharp build tools for a project.</description>
    <releaseNotes>Initial release.</releaseNotes>
    <copyright>Copyright 2015</copyright>
    <tags>Build CSharp</tags>
    <dependencies>
      <dependency id="psake" version="4.4.1" />
      <dependency id="AliaSQL" version="1.3.1" />
      <dependency id="NUnit.Runners" version="2.6.4" />
    </dependencies>
  </metadata>
</package>
{% endhighlight %}

From the [NuGet documentation](https://docs.nuget.org/create/creating-and-publishing-a-package)
{% highlight %}
To create a package in this way, you can layout a directory structure that follows the NuGet conventions.

  tools - The tools folder of a package is for powershell scripts and programs accessible from the Package Manager Console. After the folder is copied to the target project, it is added to the $env:Path (PATH) environment variable.
  lib - Assemblies (.dll files) in the lib folder are added as assembly references when the package is installed.
  content - Files in the content folder are copied to the root of your application when the package is installed.
  build - The build folder of a package is for MSBuild targets files that are automatically inserted into the .csproj file of the application.
{% endhighlight %}

The first issue arose when adding in the file `content\default.ps1` - this is the [psake](https://github.com/psake/psake) build script with the tasks to execute for building, testing and packaging. The warning indicates that this script will not be executed, which is what we want. The reason for not putting it in `Content\` is that it will then be added to the project itself in the solution explorer - if you want this, then it is fine.
{% highlight %}
WARNING: 1 issue(s) found with package 'Your.Project.Name'.

Issue: Unrecognized PowerShell file.
Description: The script file 'tools\default.ps1' is not recognized by NuGet and hence will not be executed during installation of this package.
Solution: Rename it to install.ps1, uninstall.ps1 or init.ps1 and place it directly under 'tools'.
{% endhighlight %}

Add in the required build script wrappers `build.bat`, `ci.bat` and `package.bat` to the `tools` directory.

Next we create a local folder to use as a NuGet store - you don't need to create and run a webserver for this. This works really well for a domain, we allow the Jenkins user write access to the NuGet repository folder and developers read access. To pack and upload the NuGet package, run:

{% highlight %}
mkdir c:\nuget
nuget.exe pack Some.Project.Build.nuspec
nuget.exe push Some.Project.Build.\*.nupkg -s c:\nuget
{% endhighlight %}

To test that this works as expected, we need to add the directory `c:\nuget` as a NuGet source and upload the package:
{% highlight %}
nuget sources add -Name local -Source c:\nuget
Package Source with Name: local added successfully.
{% endhighlight %}

Finally, in Visual Studio, [open up a NuGet Package Manager Console](https://docs.nuget.org/consume/package-manager-console) and add the newly uploaded package to your project:
{% highlight csharp %}
install-package Your.Project.Name
Attempting to resolve dependency 'psake (≥ 4.4.1)'.
Attempting to resolve dependency 'AliaSQL (≥ 1.3.1)'.
Attempting to resolve dependency 'NUnit.Runners (≥ 2.6.4)'.
Installing 'Your.Project.Name 1.0.0'.
Successfully installed 'Your.Project.Name 1.0.0'.
Adding 'Your.Project.Name 1.0.0' to Your.Project.Api.
Successfully added 'Your.Project.Name 1.0.0' to Your.Project.Api.
{% endhighlight %}

This places the files in `src\packages\Your.Project.Name.1.0.0\tools`, which is not easy to remember for the developers - we are striving for _Check out the project, run build.bat_ to allow them to easily start working on a project. To move the scripts to the root of the repo, we need to add in `tools\install.ps1` with the following content:
{% highlight powershell %}
param($installPath, $toolsPath, $package, $project)

Copy-item $toolsPath\default.ps1 $toolsPath\..\..\..\..\
Copy-item $toolsPath\build.bat $toolsPath\..\..\..\..\
Copy-item $toolsPath\ci.bat $toolsPath\..\..\..\..\
Copy-item $toolsPath\package.bat $toolsPath\..\..\..\..\
{% endhighlight %}

The first line contains the parameters provided when NuGet install the package from within Visual Studio (these are *not* available when installing from the command line outside of VS).

Each project might have a non-convetional name as we are retrofitting older projects - it is much easier to establish a convention and have everyone stick to it. I.e. the project to build for the packaging task should be name <Something>.Api. Until we reach that point, we will need to get input from the user about which project to package. Luckily, the first line in the `install.ps1` script will provide the name of the project and [some other values](https://msdn.microsoft.com/en-us/library/51h9a6ew(v=VS.80).aspx). You can add normal powershell to the script, i.e.:
{% highlight powershell %}
write-host ""
write-host "========================"
write-host "Setting up build scripts"
write-host "========================"
write-host ""
write-host "Please provide the following values, defaults are shown in brackets."
$project_name           = "$($project.Name)"
$project_name           = Read-Host " - What is the deployable project's name? [$project_name]"

$project_short_name     = "$project_name"
$project_short_name     = Read-Host " - What is the project's short name? [$project_short_name]"

$build_parameters = "'projectName'='$project_name';'shortProjectName'='$project_short_name'"
$build_properties = "'versionTagMustMatchRevision'='$false';'databaseName'='$project_integration_db'"

gci -r -include "\*.bat" ..\..\..\..\ |
 foreach-object { $a = $_.fullname; ( get-content $a ) |
	foreach-object
  {
    $_ -replace "#build_parameters#", "$build_parameters"
    $_ -replace "#build_properties#", "$build_properties"
  }  | set-content $a }

{% endhighlight %}
