---
layout: post
title: Securing AWS environments using role switching
exclude_comments: false
tagline: Separate environments, single login, granular permissions
image:
categories: [AWS]
tags: [aws, security]
fullview: false
---

I've been working with multiple AWS accounts for the last few months between various organisations. Logging into each one when I need to make a change quickly became tedious and slow. Each environment (dev, test, staging, production) has their own AWS account. The need to log in stems from taming the infrastructure with [Terraform](https://terraform.io) for systems that have been set up by hand and dealing with the discrepencies between them, so I tend to jump between dev and staging very often. Being in this is a very normal state of affairs as most people starting out with AWS haven't worked with any infrastructure creation automation. I will create another post detailing how to start this taming process.

The second benefit of having multiple environments is that you can [consolidate billing](http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/consolidated-billing.html) across all of them, benefit from [AWS volume discounts](http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/useconsolidatedbilling-discounts.html) and see the breakdown between environments between different accounts. You also have better isolation as permissions are delegated across accounts and you can easily create/lock an account, or in the event of a breach, isolate an entire environment by revoking permission.

We are going to set up 3 new AWS accounts, delegate billing to the master one and have cross account administrator access for a user.

![Multi-account layout]({{ site.url }}/assets/media/aws_multi_account/multi_account_sts.png){:width="575px" height="493px"}

First step is setting up 3 AWS accounts via the [signup page](https://aws.amazon.com/console/). As each account requires a unique email address, the use of a `+` in an email address is very useful (allowed via [RFC 2822](https://tools.ietf.org/html/rfc2822#section-3.4.1)). For `amazon@yourdomain.com`, I suggest something like:

 * `amazon+master@yourdomain.com`
 * `amazon+development@yourdomain.com`
 * `amazon+production@yourdomain.com`

This will allow you to have all the emails in a single inbox. For security, I would advise to have different emails for each account, but it complicates things for this demo.

When you click on register, it will ask you for your name, use something like `AWS Master` for the master account as it will make identifying the accounts in the console easier, see the screenshot below. For the rest of the registration, use your proper details (name / surname). Registration will require you to provide a credit card (they will charge with $1.00 to confirm it is valid) and a valid phone number. During registration, they will call you on this number and you have to type in the on-screen pin to verify the phone number. For the support plan, choose the basic one for now - it is free. Your account is now ready, but you are not logged in, do so now. Spend some time reading through the [free tier](https://aws.amazon.com/free/) documentation, you get a decent amount for the first 12 months to help you start out. Log out and create accounts for `development` and `production` as well.

This is where the account name goes:

![Account signup]({{ site.url }}/assets/media/aws_multi_account/account_signup.png){:width="761px" height="420px"}


And this is how it will display on the top-right side of the screen after logging in:

![Account name]({{ site.url }}/assets/media/aws_multi_account/account_name.png){:width="257px" height="40px"}

First thing we want to do is set up the consolidated billing. This is done on the master account only, click on your account name on the top-right of the screen, then on `Billing & Cost Management`:

![Delegated Billing Link]({{ site.url }}/assets/media/aws_multi_account/delegate_billing_link.png){:width="215px" height="212px"}

On the following screen, click on `Consolidated Billing` on the lefthand side:

![Delegated Billing Setup]({{ site.url }}/assets/media/aws_multi_account/delegate_billing_page_1.png){:width="1000px" height="251px"}

Enable delegated billing by clicking on the `Sign up for Consolidated Billing`. The button text will change to indicate it is being set up and, once complete, a green notification will dropdown in the top-middle of the screen. The button will revert back to `Sign up for Consolidated Billing`, you will need to refresh the page to configure it. Click the `Send a Requst` button, enter the development account's email address, i.e. `amazon+development@example.com`, and click on send. Do the same for the production account. You now need to log out of the master account, go to your email and click on the link there to enable the billing consolidation. The link will take you to the console sign-in page, use the credentials for the development / production account, depending on which link you clicked on first. After logging in, you will need to click on the `Accept request` button. It wil grey out and indicate it is processing. Once complete, you will see the accepted state:

![Delegated Billing Setup]({{ site.url }}/assets/media/aws_multi_account/delegate_billing_page_2.png){:width="384px" height="281px"}

When you log back into your `master` account, you will see the following in the consolidated billing section:

![Delegated Billing Setup]({{ site.url }}/assets/media/aws_multi_account/delegate_billing_page_3.png){:width="1000px" height="215px"}

Write down the account Id values for `development` and `production`, we will need them for the role delegation. Now it is time for setting up your daily account. You should never log in with your root account credentials unless something has happened to this account we are about to set up. By default, user accounts (even ones with administrator roles), cannot access the billing section as a security measure. With the root credentials, a malicious person can change your password and the email used to log in with, locking you out of your account completely. They can then abuse it until you realise this and contact AWS support to regain access to your account - this takes time and will further increase your bill. You should also set up [multi-factor authentication](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html) on you account.

The cross account permission delegation has two components to it, the first is where the root account grants access to another root account to assume a role inside itself. I.e. the development root account has a role `administrator` that has the built-in `AdministratorAccess` IAM policy attached to it. This role is then set up to allow the master account to assume it. On the master account side, you will create a new group with permissions to assume this role and add a user to this group. The layered security here has 2 benefits:

* If your master account is compromised, you can revoke access to the environments from their accounts by removing the role permission.
* If you need to add or remove a user's access to your systems, it is done in a single place (your master account)

Log back in into your master account. Click on `Services` on the top-left side, then 'All AWS Services', then `IAM`. It is also useful to click on the `edit` button and add the services you access regularly - they will also be visible at the top of the console. Create a new policy by clicking on `Policies` on the left, then the `Create Policy` button. Choose `Create your own policy`. Use `development_administrator` for the name, any description you want, i.e. `Allows assuming the development administration role on the development account.` and the policy itself as (remember to replace `developmenta_acocunt_id` with your account id):

~~~
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::development_account_id:role/administrator"
  }
}
~~~

Do the same for `production`. Go to `Groups` on the left and create a new group called `development_administrator`. On then next screen, click on `Policy Type` and select `Customer Managed Policies`. You will see the `development_administrator` and `production_administrator` ones there, click on the check box to the left of the development one. Click on next. A final confirmation screen will appear, showing:

![IAM Group creation]({{ site.url }}/assets/media/aws_multi_account/iam_group_confirm.png){:width="613px" height="156px"}

After clicking on `Create Group`, it will show up in the list:

![IAM Group list]({{ site.url }}/assets/media/aws_multi_account/iam_group_list.png){:width="472px" height="206px"}

Again, do the same for the `production` account. Create a new user for yourself, I will call mine `cobus` by clicking on `Users` on the left-hand side and then on `Create New User`. The tick box for `Generate access key for each user` will be ticket by default. Click on `next` and then on the arrow to show your credentials. Copy the values, or download the file - I prefer to copy and paste to a safe location immediately instead of downloading the file as you might leave it in your download folder and forget about it. For now, place them in the file `~/.aws/credentials`:

~~~
[demo-master-cobus]
aws_access_key_id=AKIAJA6ZCX6DGYD2IJJQ
aws_secret_access_key=Q/5Rb4UV1B7sMayNJDBL3Au1wZBTiypBQO+dszZi
~~~

(The credentials above have already been revoked, I decided to include actual ones to avoid formatting confusion). This allows you to interact with the [AWS CLI](https://aws.amazon.com/cli/) via `aws --profile demo-master-cobus`. It is safer to not set a `[default]` profile as the CLI will use that when you do not specify `--profile`. As I work with many accounts, this is a risk that I prefer to avoid. Click on `close` twice to create the user. Select the user from the list and go to the `Security Credentials` tab.


![IAM user cobus]({{ site.url }}/assets/media/aws_multi_account/iam_user.png){:width="1000px" height="625px"}

Here you can see the user and that it hasn't been assigned a password yet. Click on `Manage Password` and generate one for the user. You can decide to provide one, or have it generated. Entirely up to your preference. Once again, copy & paste the credentials to a safe place - I use [1password](https://1password.com/) religiously for this. You will also want to have administrator rights on the master account, so create a new group called `master_administrator` and attach the built-in `AdministratorAccess` policy to it. Now that we have a user, it is time to give it some permissions via groups. Click on the `Groups` tab, tick both of the groups you created earlier and click on `Add to groups`.

![IAM add user to groups]({{ site.url }}/assets/media/aws_multi_account/iam_user_add_to_group.png){:width="1000p×" height="196px"}

It is almost time to log in with the user, but first, let's make that easier. Go back to the top level of `IAM` by clicking on `Dashboard` on the left. You will see the following:

![IAM dashboard]({{ site.url }}/assets/media/aws_multi_account/iam_dashboard_1.png){:width="967p×" height="502px"}

You will see a number in the link, this is your account ID for the master account, write it down for later. Click on the `customize` link at the top/mid-right of the screen. This will allow you to choose a friendly name for your login, i.e. `https://friendly-name.signin.aws.amazon.com/console`. Choose something sensible for your account. You will be using this link to log in in future.

We still haven't given our master account permission to assume roles in the other two accounts, let's do this now. Log out of this account and back into the development one. Go to the `IAM` section, and then to `Roles` and finally click on `Create New Role`. Use `administrator` for this role - this needs to match what you specified in the policy earlier for your `development_administrator` policy. On the next screen, select `Role for Cross-Account Access` and then `Provide access between AWS accounts you own`. Enter the master account ID on the next screen. You can tick the `Require MFA` option - this will force the user to have MFA enable on their user in the master account before being allowed to switch to this role. In the next step, choose the built-in `AdministratorAccess` policy. On the last step, you can review the setup, it should look like this:

![IAM cross account role]({{ site.url }}/assets/media/aws_multi_account/iam_cross_account_role.png){:width="620p×" height="327px"}

Copy the link provided, log out and do the same for the production account. It is finally time to use the new login. Enter the friendly url you created earlier after logging out of the production account, i.e. `https://friendly-name.signin.aws.amazon.com/console`:

![IAM account log in]({{ site.url }}/assets/media/aws_multi_account/iam_login_screen.png){:width="587p×" height="396px"}

You will see your IAM account name and friendly login name at the top right as `cobus @ friendly-name`. In a new tab, paste the link you copied when creating the cross account role: `https://signin.aws.amazon.com/switchrole?account=development_account_id&roleName=administrator`. It will bring up 3 boxes to fill in, the `Account` and `Role` will already be populated with values. Choose a short name for the development account, i.e. `Development` and a colour - I use green for dev, yellow for staging / uat and red for production environments. You will see why when we go back to the first tab. Click on `Switch role`, wait for the screen to load, then close that tab. Open another new one and do the same for production. Close the tab when done.

![IAM add cross account role]({{ site.url }}/assets/media/aws_multi_account/iam_switch_role_1.png){:width="349p×" height="182px"}

Go back to your first tab and refresh the page. There will be a dialog indicating that says:

![IAM add cross account role]({{ site.url }}/assets/media/aws_multi_account/iam_log_in_again.png){:width="302p×" height="182px"}

You will see a red oval top-right with `Production` in it, when you click on it, you will see:

![IAM add cross account role]({{ site.url }}/assets/media/aws_multi_account/iam_switch_role_2.png){:width="369p×" height="360px"}

You are now able to switch between development and production without having to log in! If you want to go back to the master account, simply click on `Back to cobus` in that menu. What is happening in the background is the console uses your master account user to generate temporary credentials on the development / production account via the [STS service](http://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) and using them to access the other environments.

Finally, you want to configure profiles to do the role switching for you when using the CLI. To do this, you can configure them in `~/.aws/config`

~~~
[profile demo-master-cobus]
region = us-west-2

[profile demo-development-cobus]
role_arn = arn:aws:iam::<development_account_id>:role/administrator
source_profile = demo-master-cobus

[profile demo-production-cobus]
role_arn = arn:aws:iam::<production_account_id>:role/administrator
source_profile = demo-master-cobus
~~~

This will allow you to add `--profile <target>` to your CLI commands, i.e. `aws --profile demo-master-cobus s3 cp s://my-bucket/myfile.txt ./` to copy from a bucket created in the `master` account. Or if you want to copy from a bucket in the `development` account: `aws --profile demo-development-cobus s3://my-dev-bucket/myfile.txt ./`. You are now able to update each individual AWS root account using a single crednetial set. When managing many users, this becomes very powerful as you only have a single location to look at to assess what a user's rights are across all your environments.
