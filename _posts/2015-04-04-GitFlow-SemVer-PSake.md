---
layout: post
title: Using the Git tag as a version number via PSake
tagline: With GitFlow, releases should be SemVer'ed - use PSake to extract this version and compile it in.
image:
exclude_comments: false
categories: [dotnet]
tags: [msbuild, psake, git]
fullview: false
---

I have been spending most of my time splitting up a [monolithic system](http://en.wikipedia.org/wiki/Monolithic_system) into separately deployable [NuGet](https://www.nuget.org/) packages. The system is monolithic in the sense that there are multiple domains that are deployed as independent WCF services, but all reference the same set of base projects. This means that all the source sits in the same repository. The first step has been to move these common libraries into NuGet packages served from a local network folder and referencing them in each of these solutions as a package rather than project.


This is done fairly easily
: * Create a new solution with a [Class Library project](https://msdn.microsoft.com/en-us/library/f1yh62ef%28v=vs.90%29.aspx) in a new Git repo.
* Copy the classes from the old project to the new location and include in the project.
* Resolve any references - [ReSharper](https://www.jetbrains.com/resharper/) for the system libs, NuGet restore for the others and then finally installing the newly created packages if the current package depends on it. (More on this later).
* Add a NuSpec file to the project.
* Build, package and push with NuGet.

Also, if you aren't using ReSharper yet, just give it a try - it will open your eyes. Or as they mentioned in the [Coding Blocks podcast](http://www.codingblocks.net/podcast/episode-21-our-favorite-tools/): **"Using ReSharper on legacy code is like walking into your hotel room with a black light"** - it will show you how bad it really is.

Before we get to the actual implementation, just a quick overview of the Git-Flow branching model:

![GitFlow]({{ site.url }}/assets/media/git_flow_release_cycle.png){:height="380px" width="614px"}

All development is done on feature branches cut from `develop` and merged back in when done. When you have enough features for a release, you cut a short-lived `release` branch from `develop`. After this branch has been vetted, it will be merged into `master` and `develop` (to ensure any fixes are also merged back into you development stream). When merging into `master`, a tag with the new version number will be created. This will increment either the minor or major version number, depending on how big the release is. For hotfixes, you would branch from `master` directly, fix the issue and then merge it back into `master` as well as `develop`. Every time you merge into `master`, you update the version number and tag the source - this is the version that you want to use to stamp the releases with.

The command for the build & push with NuGet are (ignore the versioning and poking for further down):

{% highlight powershell %}
task NuGetPackage -depends Init {
  $version = Generate-Semantic-Version-Number
  write-host "Building the package with version: [$version]"

  poke-xml $NuGetSpecFile "//e:id" $projectName @{"e" = ""}
  poke-xml $NuGetSpecFile "//e:version" $version @{"e" = ""}

  exec {
    & $NuGet pack $source_dir\$projectName\$projectName.csproj -NoPackageAnalysis -Build -Symbols -verbosity detailed -o $build_dir -Version $version  -p Configuration="release"
  }

  exec {
    & $NuGet push $build_dir\$projectname.$version.nupkg -s \\networkserver\NuGet
  }
}
{% endhighlight %}

This will result in the Class Library being packaged as a single NuGet package and pushed to the network share. This is the point where the [PSake](https://github.com/psake/psake), [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/) and [Semantic Versions](http://semver.org/) come in. When you use GitFlow, there is a very specific way to create new releases / hotfixes - this ties in perfectecly with SemVer. If you are just doing a minor feature release, you would increment the minor version number in the `<major>.<minor>.<hotfix>` version of the release. Same with major / hotfix numbers. The catch is that you want to also stamp your package with this version and ultimately enforce this via the build server to prevent accidental releases of incorrect versions. Part of the GitFlow release / hotfix workflow is to specify the tag name. Using the git command `git describe --exact-match --abbrev=0` as part of the PSake function:

{% highlight powershell %}
function global:Generate-Semantic-Version-Number {
    $result = & "git" describe --exact-match --abbrev=0 | Out-String
    if ([string]::IsNullOrEmpty($result))
    {
      $result = "1.0.0"
    }

    $result = $result -replace "`n","" -replace "`r",""

    return $result
}
{% endhighlight %}

you are able to extract the last tag on a branch that matches the current commit hash. When done on the `master` branch, you will always end up with the latest version - the only way for code to be merged into `master` in GitFlow is via a feature or hotfix finish. The build process that builds the library has write-access to the network share, ensuring that only builds that were created via the build server are pushed to your private NuGet repository.

The last part of the puzzle is to also use this version number in the Nuspec file and the various assemblies. Here are the handy PowerShell functions that I have run into that will update the assemblies:

{% highlight powershell %}
function global:Update-AssemblyInfoFiles ([string] $version) {
    $commonAssemblyInfo = "$source_dir\CommonAssemblyInfo.cs"

    $assemblyDescriptionPattern = 'AssemblyDescription\("(.*?)"\)'
    $assemblyDescription = 'AssemblyDescription("' + $env:buildlabel + '")';

    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $assemblyVersion = 'AssemblyVersion("' + $version + '")';

    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $fileVersion = 'AssemblyFileVersion("' + $version + '")';

    Get-ChildItem $source_dir -r -filter AssemblyInfo.cs | ForEach-Object {
        $filename = $_.Directory.ToString() + '\' + $_.Name
        $filename + ' -> ' + $version

        # If you are using a source control that requires to check-out files before
        # modifying them, make sure to check-out the file here.
        # For example, TFS will require the following command:
        # tf checkout $filename

        (Get-Content $commonAssemblyInfo) | ForEach-Object {
            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
            % {$_ -replace $assemblyDescriptionPattern, $assemblyDescription } |
            % {$_ -replace $fileVersionPattern, $fileVersion }
        } | Set-Content $filename
    }
}
{% endhighlight %}

And the function to update the Nuspec xml file:

{% highlight powershell %}
function script:poke-xml($filePath, $xpath, $value, $namespaces = @{}) {
    [xml] $fileXml = Get-Content $filePath

    if($namespaces -ne $null -and $namespaces.Count -gt 0) {
        $ns = New-Object Xml.XmlNamespaceManager $fileXml.NameTable
        $namespaces.GetEnumerator() | %{ $ns.AddNamespace($_.Key,$_.Value) }
        $node = $fileXml.SelectSingleNode($xpath,$ns)
    } else {
        $node = $fileXml.SelectSingleNode($xpath)
    }

    if($node -eq $null) {
        return
    }

    if($node.NodeType -eq "Element") {
        $node.InnerText = $value
    } else {
        $node.Value = $value
    }

    $fileXml.Save($filePath)
}
{% endhighlight %}


The actual xml update is done via:

{% highlight powershell %}
$version = Generate-Semantic-Version-Number
write-host "Building the package with version: [$version]"

poke-xml $NuGetSpecFile "//e:id" $projectName @{"e" = ""}
poke-xml $NuGetSpecFile "//e:version" $version @{"e" = ""}
{% endhighlight %}

Combining all of these together will allow you to release reliably versioned NuGet packages easily and the only dependency is PSake, PowerShell and git. This allows you to choose whatever flavour of build server you fancy. The obvious way to circumvent this is by committing directly to `master` and creating a tag by hand, but that is a human issue that the angry dev mob will sort out with their pitchforks.
