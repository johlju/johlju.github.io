---
title:  Create a dsc configuration repository
excerpt: "Publish your DSC configurations"
date: 2017-08-05 00:00:00
categories: [PowerShell, DSC]
tags: [PowerShell, DSC]
comments: true
published: true
image:
 header: /images/johlju.jpg
---

{% include toc %}

<!-- markdownlint-disable MD002 -->

## Abstract

The Microsoft PowerShell DSC Team has provided a GitHub repository
[DscConfigurations](https://github.com/PowerShell/DscConfigurations)
which, together with the community, will provide a structured list, or a
connection point if you will, for community created DSC configurations.

This blog post is the first of a series that will explain how to create a DSC
configuration repository using the templates and common tests provided in the
[DscConfigurations](https://github.com/PowerShell/DscConfigurations) repository.

We will setup a DSC configuration that will configure two target nodes (servers),
where the first configuration will create and configure a local group on the first
server, and on the second server we will change the power plan.

## Preparations

This assumes that you have all the required software installed on the client you
will be working on. And that you have all the necessary accounts on dependent
services.

> This blog is only tested on Windows but will hopefully work on any platform with
> PowerShell installed.

### Services that are required

- An [Azure subscription](https://azure.microsoft.com/sv-se/free/) with administrator
  permission.
- [GitHub](https://github.com/) free account.
- [AppVeyor](https://www.appveyor.com/) free account

> GitHub and AppVeyor is free for public open source repositories.
> For this you only need a free account, since the whole point of this is that
> this repository should be publicly shared with and by the community.
>
> Azure subscriptions comes in different flavours, you can get a 30-day trial,
> or you get one thru the MSDN subscription, or maybe your company has a subscription
> that you are allowed to use. I would recommended having an MSDN subscription.

### Software required on the client

- Git (can be downloaded [here](https://git-scm.com/downloads).
- Any text editor (preferably [Visual Studio Code](https://code.visualstudio.com/)
  which is awesome and free on every platform).
- AzureRm PowerShell Modules (see this article
  [Install and configure Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0))
  on how to install the modules.

### Properties used

There are some properties that can be changed, but if you change any
of these properties, then use the same values throughout the steps.

> Note the repository name must not contain a hyphen ('-') because that will
> (currently) not be allowed when the configuration is uploaded to Azure Automation.

- Public repository name:
  DscConfigurationExample
- Local root path for local repositories:
  c:\source

## How to set up a repository using the templates and common tests
### Prepare a repository with the template

If you not already have and account on [GitHub](https://github.com/) then please
go register for a free account.

1. Browse to [GitHub](https://github.com/) and log in.
1. Create a new repository named 'DscConfigurationExample'.
   1. Add a optional description (can be left empty).
   1. Leave the repository type as 'Public'.
   1. Check the box for 'Initialize this repository with a README'.
   1. Leave the choice for .gitignore as 'None'.
   1. Add correct license for your repository, normally MIT is used for
      Open Source Software (OSS).
1. Clone the repository.

   ```powershell
   cd 'c:\source'
   git clone https://github.com/johlju/DscConfigurationExample
   ```

1. Clone the template repository.

   ```powershell
   cd 'c:\source'
   git clone https://github.com/PowerShell/TemplateConfig
   ```

1. Copy everything except the LICENSE and README.md from the template folder.

   ```powershell
   cd c:\source

   $copyItemParameters = @{
      Path = '.\TemplateConfig\*'
      Destination = '.\xFailOverClusterIntegration '
      Exclude = 'LICENSE','README.md'
      Recurse = $true
   }

   Copy-Item @copyItemParameters
   ```

1. Enter you newly cloned repository

   ```powershell
   cd 'xFailOverClusterIntegration'
   ```

1. Open in VS Code

   ```powershell
   code .
   ```

1. We need to remove the secure variables from the appveyor.yml file and instead
   add them to our AppVeyor account. If you don't have AppVeyor, you can register
   for free (public open source projects). Just register at the
   [AppVeyor web site](https://www.appveyor.com/).
1. Once in AppVeyor, add the project.
   1. Go to the [Project tab](https://ci.appveyor.com/projects).
   1. Click **New Project**.
   1. Choose GitHub
   1. Hover over 'xFailOverClusterIntegration' and click on Add.
   1. Click Settings.
   1. Click Environment.
   1. Under Environment variables, click Add variable.
   1. Hover over value and then click on the lock to make it a encrypted value.
      Add the following variables, and make sure to click the lock after the value
      field to make it secure. _Note: If the value is not secure, then anyone
      sending in a PR could compromise your variables._

      - TenantID
      - SubscriptionID
      - ApplicationID
      - ApplicationPassword

## Related links

- You can read more about Desired State Configuration (DSC) in the article
  [Windows PowerShell Desired State Configuration Overview](https://docs.microsoft.com/en-us/powershell/dsc/overview).
