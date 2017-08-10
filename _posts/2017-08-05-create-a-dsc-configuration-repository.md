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

- An [Azure subscription](https://azure.microsoft.com/free) with
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

There are some properties that you can or must change in the steps below. Make
sure to use the same values throughout the steps.

- Public repository name: **DscConfigurationExample**
- Local root path for local repositories: **c:\source**
- Tenant ID for the Azure subscription.
- Subscription ID for the Azure subscription.
- Application ID for the Azure Active Directory application registration (in the
  Azure subscription).
- Application password (key) for the Azure Active Directory application registration
  above.

> **Note:** The repository name must not contain a hyphen ('-') because that will
> (currently) not be allowed when your configuration is uploaded to **Azure Automation**.
> See [issue PowerShell/TemplateConfig#7](https://github.com/PowerShell/TemplateConfig/issues/7)
> for more information.

## How to set up a repository using the templates and common tests

### Prepare a repository with the template

If you not already have and account on [GitHub](https://github.com/) then please
register for a free account.

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

If you not already have an Azure subscription then then please register for a
[30-day trial Azure subscription](https://azure.microsoft.com/free).

We need a new Azure Active Directory Application account that will be used to
login to Azure, it need to have the correct permission to create the resources
being used during testing.
Currently that permission needs to be Contributor on the entire subscription.

There are two ways to create the requirements for running the tests. I will show
both methods.

1. Using the Azure Portal.
1. Using PowerShell using the script that [@PlagueHO](https://github.com/PlagueHO)
   created [here](https://github.com/PowerShell/DscConfigurations/issues/5#issue-234996357).

#### Prepare Azure using Azure Portal

1. Login in to the [Azure Portal](https://portal.azure.com).
1. Create the Azure Active Directory application account.
   1. Go to **Azure Active Directory**.
      *I assume you are in the correct directory, if not, change to the correct directory*.
   1. Click on **App registrations**.
   1. Click on **New application registration**.
   1. Enter a descriptive name in the *Name* field. For example '**DscConfigurationExampleAppId**'.
      *This name is only for your records, and will only be used for setting*
      *permission later.*.
   1. Leave *Application type* as **Web app / API**.
   1. For the mandatory field *Sign-on URL* enter any URL. For example
      **https://dummy**. *This URL is not of interest since it will not be used*.
   1. Click on **Create**.
   1. On the list of application registrations, click on the newly created application.
   1. In the blade, look for **Application ID** and save this somewhere as your
      application id. We need this in a later step.
      Application ID looks something like this; 'ed978ce1-4d9c-4cd0-9374-4888e0fcab36'.
   1. On the **Settings** blade, click on **Keys**.
   1. Add a descriptive key description in the *Description* field. For example
      '**DscConfigurationExampleAppPassword**'.
   1. Choose when the key password will expire, in the *Expires* field. For example
      '**In 1 year**'.
   1. Click **Save**, and please, keep the blade open until you completed the following
      steps.
   1. From the value field, copy the password key to a secure location, for example
      a password manager. We need this in a later step.
      The password will look something like this 'B5zwEx6B+fj92mEk5LC7IPa4P+d28NY7QuqhLP1Dehs='.

      >**Note:** When leaving this blade you will not be able to see the key password
      >again. If you do then you need to create a new key password and optionally
      >delete the old one.

1. Copy the **Tenant ID** and save this somewhere. We need this in a later step.
   1. Go back to **Azure Active Directory**.
   1. Click on **Properties**.
   1. Look for the field *Directory ID*, this value is the same as your
      **Tenant ID**. Copy the **Directory ID** and save this somewhere as your
      tenant id.
      Tenant ID looks something like this; '84a06b73-5842-4d03-8123-ee27708b7f36'.
1. Copy the **Subscription ID** and save this somewhere. We need this in a later
   step.
   1. Go to **Subscriptions** (same place as Azure Active Directory)

      > **Note:** If you don't see subscriptions in the list, then you need to
      > click on **More services** and search for **Subscriptions**.

   1. Look for the field **Subscription ID** column. Copy and save this somewhere
      as your subscription id.
      Subscription ID looks something like this; '4de0edba-1816-4f9b-880f-db90ee863d11'.
1. Set the required permission for the Azure Active Directory Application on the
   subscription.
   1. While still in the subscriptions list, please click on the subscription with
      the same id as you copied above.
   1. Click on **Access control (IAM)**.
   1. Click **Add**.
   1. In the field *Role* select **Contributor**.
   1. In the field Select (the search box), write the name of the Azure Active
      Directory Application, for example '**DscConfigurationExampleAppId**'.
   1. When the name of the Azure Active Directory Application returns in search
      result, click on the name to move it to selected members.
   1. Click **Save**.

#### Prepare Azure using PowerShell

For this we are gonna use the script that [@PlagueHO](https://github.com/PlagueHO)
created [here](https://github.com/PowerShell/DscConfigurations/issues/5#issue-234996357)
with some minor modifications.
We will use the modified script [here](https://gist.github.com/johlju/301490cc813e4b490a3cecc1f010d921).

The script will login to Azure and create a new Azure Active Directory application
account and give the application account Contributor permission on the subscription.

1. Copy the script to a script file named 'New-AzureServicePrincipal.ps1'.

   {% gist 301490cc813e4b490a3cecc1f010d921 %}

1. Start a PowerShell session and change the directory to the location where you
   save the script file  'New-AzureServicePrincipal.ps1'.
1. If you already know your subscription id, skip to the next step.
   1. Run the following in the PowerShell session

      ```powershell
      Login-AzureRmAccount
      Get-AzureRmSubscription
      ```

   1. Look for the *Id* property, this is the **Subscription ID**.
      Copy the **Subscription ID** and save this somewhere.
      Subscription ID looks something like this; '4de0edba-1816-4f9b-880f-db90ee863d11'.
1. Run the following in the PowerShell session.
   - Change variable `$azureActiveDirectoryApplicationName` to something descriptive.

     >**Note:** The application name is only for your records, it will only show
     >as the account having permission on the subscription.

   - Change variable `$azureSubscriptionId` to the subscription id copied in the
     previous step.
   - Change variable `$azureDomain` to your domain name (this is optional).

     >**Note:** Domain is used to build the URL for the parameters home page and
     >identifiers URI but is is not of interest since it will not be used.

   - When the script is run, you will be asked for a password. This is the
     password key that will will need later to login using the application account.
     Save the password key to a secure location, for example a password manager.

   ```powershell
   $azureActiveDirectoryApplicationName = 'DscConfigurationExampleAppId'
   $azureSubscriptionId = '4de0edba-1816-4f9b-880f-db90ee863d11'
   $azureDomain = 'dummy'

   $getCredentialParameters = @{
      Message = 'Azure Active Directory Application password'
      UserName = $azureActiveDirectoryApplicationName
   }

   $applicationCredential  = Get-Credential @getCredentialParameters

   $newAzureServicePrincipalParameters = @{
     Name = $azureActiveDirectoryApplicationName
     SubscriptionId = $azureSubscriptionId
     ADDomain = $azureDomain
     ApplicationPassword = $applicationCredential.Password
   }

   .\New-AzureServicePrincipal.ps1 @newAzureServicePrincipalParameters
   ```

1. When `New-AzureServicePrincipal` successfully finishes it returns a hash table
   with values that we will need later. Please save these for later use.
   The result will look something like this.

   ```plaintext
   Name                           Value
   ----                           -----
   SubscriptionID                 4de0edba-1816-4f9b-880f-db90ee863d11
   ApplicationID                  ed978ce1-4d9c-4cd0-9374-4888e0fcab36
   TenantID                       84a06b73-5842-4d03-8123-ee27708b7f36
   ```

### Configure AppVeyor for running tests

If you not already have and account on [AppVeyor](https://www.appveyor.com/) then
please register for a free account.

#### Add repository as a AppVeyor project

1. Login in to [AppVeyor](https://ci.appveyor.com)
1. Once in AppVeyor, add the project.
   1. Go to the [Project tab](https://ci.appveyor.com/projects).
   1. Click **New Project**.
   1. Choose GitHub
   1. Hover over 'DscConfigurationExample' and click on Add.

#### Move encrypted environment variables to

If we look in the repository that we created above, the file appveyor.yml has
all the id's and password in that file. Even if they are stored encrypted, that
is not best security wise. Instead we need to remove the secure variables from the
appveyor.yml file and add them to your AppVeyor account.

>Note: If you want to keep the ID's and password encrypted in the appveyor.yml file,
>then you should encrypt the strings using [Encrypt configuration data](https://ci.appveyor.com/tools/encrypt).
>If you choose to keep the values in appveyor.yml, then you can skip this step.

1. Go back to your project in Visual Studio Code (or whatever editor you are using).
1. Remove the following block from the appveyor.yml.

   ```yml
   ApplicationID:
     secure: mHB9K9ItLkpdxUR7WgBnuBiBOl3qgJT1yizvFZDOgkRxvTV5KoZJ8QuAp+F+EbV0
   SubscriptionID:
     secure: fhB5mHXLFRRc1/iwqCA9ibCqwg7qKqkayknhebLsM+FdlrmL80HCRm1vJYafomei
   TenantID:
     secure: J/my7xsOE9jewR0DDhD+EU5jeo5Bp83/nmIK8a8QI0QLoZXStCOtk1vUjVsKylW2
   ApplicationPassword:
     secure: zV3r4bwG65rWRfF1L23RYLj7GXVxsMdZtasCsX0+pYA=
   ```

1. Add the environment variables to the AppVeyor project settings.
   1. If you just did the previous section, then you should have the correct page
      already up and can skip this step.
      1. Go to the [Project tab](https://ci.appveyor.com/projects).
      1. Click on the project name 'DscConfigurationExample'
   1. Click on Settings.
   1. Click on Environment.
   1. Add environment variable 'TenantID'.
      1. Under **Environment variables**, click **Add variable**.
      1. In the *Name* field, type **TenantId**.
      1. In the *Value* field, type the value for tenant id that you save in the
         previous step.
      1. Hover over the *Value* field and then click on the lock next to it to
         make it a encrypted value.

         >Note: If the value is not secure (encrypted), then anyone sending in a
         >pull request (PR) could compromise your variables.
         >Environment variables that are encrypted will not be available for
         >a pull request (PR).

   1. Repeat the previous step for the following environment variables, and make
      sure to secure each value. Use the values you save in the previous steps.

      - SubscriptionID
      - ApplicationID
      - ApplicationPassword

   1. Click **Save**.

## Issues with this article

If you find any issues with this blog article please comment, or
[submit an issue](https://github.com/johlju/johlju.github.io/issues/new?title=Article:%20{{page.title}})
at the blog repository.

## Related links

- You can read more about Desired State Configuration (DSC) in the article
  [Windows PowerShell Desired State Configuration Overview](https://docs.microsoft.com/en-us/powershell/dsc/overview).
