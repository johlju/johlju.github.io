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

> This blog is only tested on Windows, but will hopefully work on any platform with
> PowerShell installed.

### Services that are required

- An [Azure subscription](https://azure.microsoft.com/sv-se/free/) with
  [administrator permission](https://docs.microsoft.com/en-us/azure/billing/billing-add-change-azure-subscription-administrator).
- [GitHub](https://github.com/) free account.
- [AppVeyor](https://www.appveyor.com/) free account

> **GitHub** and **AppVeyor** is free for public open source repositories.
> For this you only need a free account, since the whole point of this is that
> this repository should be publicly shared with and by the community.
>
> An **Azure subscription** comes in different flavours, you can get a 30-day trial,
> or you get one thru the MSDN subscription, or maybe your company has a subscription
> that you are allowed to use. To test this, it's enough to have the trial, for
> a real project I would recommended having an MSDN subscription.

### Software that are required on the client

- Git (can be downloaded [here](https://git-scm.com/downloads)).
- Your favorite text editor (Or [Visual Studio Code](https://code.visualstudio.com/)
  which I think is awesome, and free on every platform).
- AzureRm PowerShell Modules (see this article
  [Install and configure Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0)
  on how to install the modules).

### Properties used by this article

There are some properties that can be changed in the steps below, but if you change
any of these properties, make sure to use the same values throughout the steps.

- Public repository name: **DscConfigurationExample**
- Local root path for local repositories: **c:\source**

> **Note:** The repository name must not contain a hyphen ('-') because that will
> (currently) not be allowed when your configuration is uploaded to **Azure Automation**.
> See [issue PowerShell/TemplateConfig#7](https://github.com/PowerShell/TemplateConfig/issues/7)
> for more information.

## How to set up a repository using the templates and common tests

### Prepare a repository with the template

If you not already have and account on [GitHub](https://github.com/) then please
go register for a free account.

1. Browse to [GitHub](https://github.com/) and log in.
1. Create a new repository named 'DscConfigurationExample'.
   1. Add a optional description (can be left empty).
   1. Leave the repository type as 'Public'.
   1. Check the box for 'Initialize this repository with a README'.
   1. Leave the choice for ".gitignore" as 'None'.
   1. Add correct license for your repository, normally MIT is used for
      Open Source Software (OSS).
1. Clone the repository locally. This will make a local copy of the repository on
   your hard drive. *Note: Please replace **USERNAME** with you github account
   username, for example, my account username is 'johlju'.*

   ```powershell
   cd 'c:\source'
   git clone https://github.com/USERNAME/DscConfigurationExample
   ```

1. Clone the template repository locally.

   ```powershell
   cd 'c:\source'
   git clone https://github.com/PowerShell/TemplateConfig
   ```

1. Copy everything except the LICENSE and README.md from the template folder.

   ```powershell
   cd c:\source

   $copyItemParameters = @{
      Path = '.\TemplateConfig\*'
      Destination = '.\DscConfigurationExample'
      Exclude = 'LICENSE','README.md'
      Recurse = $true
   }

   Copy-Item @copyItemParameters
   ```

1. Enter you newly cloned repository

   ```powershell
   cd 'DscConfigurationExample'
   ```

1. Start you favorite code editor. I will assume VS Code :wink:.
   If you are using any other editor, please open the project (repository) at this
   folder location 'c:\source\DscConfigurationExample'.

   ```powershell
   code .
   ```

1. If everything worked, it should look like this.

   In the PowerShell console running **git**.

   ```powershell
   git status -u
   ```

   ```plaintext
   PS> git status -u
   On branch master
   Your branch is up-to-date with 'origin/master'.
   Untracked files:
   (use "git add <file>..." to include in what will be committed)

        ConfigurationData/TemplateConfig.ConfigData.psd1
        TemplateConfig.ps1
        TemplateConfigModule/TemplateConfigModule.psd1
        TemplateConfigModule/Tests/Acceptance/TemplateConfig.Acceptance.Tests.ps1
        appveyor.yml

   nothing added to commit but untracked files present (use "git add" to track)
   ```

   In Visual Studio Code click on the Source Control icon
   (![Visual Studio Source Control Icon]({{ site.url }}/images/VisualStudioCode/VisualStudioCodeSourceControlIcon.PNG)).

   ![Untracked files in Visual Studio Code]({{ site.url }}/images/2017-08-05-create-a-dsc-configuration-repository/VisualStudioCodeTemplateUntrackedFiles.PNG)

### Preparing Azure subscription

### Configure AppVeyor for running tests

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

## Issues with this article

If you find any issues with this blog article please comment, or
[submit an issue](https://github.com/johlju/johlju.github.io/issues/new?title=Article:%20{{page.title}})
at the blog repository.

## Related links

- You can read more about Desired State Configuration (DSC) in the article
  [Windows PowerShell Desired State Configuration Overview](https://docs.microsoft.com/en-us/powershell/dsc/overview).
