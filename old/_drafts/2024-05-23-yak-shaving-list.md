Just a short list of things I want to sort out in the next few weeks and write as I do them.

## Clean up my AWS accounts

I moved to Seattle at the end of 2021, and my AWS accounts are a bit of a mess - some have updating billing information with my US details, but not all, and I need to also set the MFA for all my root accounts. Then I need to double check my terraform that manages it all for me to ensure it is still working, and finally add it to a CI/CD pipeline.

## Set up CodeCatalyst CI/CD

I want to use CodeCatalyst for my terraform pipeline, and will leverage the multiple account setup I discussed at the XXX session at Re:Invent 2023.

## Automate homelab servers

At the start of this year, I set up TrueNAS on my HP Micro Gen10plus server, and transferred my old desktop to a 4U server case to run Proxmox. TrueNAS has been running without issue, but my Proxmox server randomly freezes every couple of days, I need to dig into what the issue is, and then see if I can use Terraform to manage the setup for both of these as well.