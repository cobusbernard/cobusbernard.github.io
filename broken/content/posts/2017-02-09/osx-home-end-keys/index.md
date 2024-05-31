---
title: Remapping the Home and End keys on OSX
description: After 3 years on a Macbook, I still can't remember how to get to the start of end of a line, so I'm remapping keys.
date: 2017-02-09
categories: [OSX]
tags: [osx]
aliases:
  - /linux/2017/02/05/Yak_shaving_Makefiles
---

## The Problem

As I was pasting something into Chrome this morning, I, once again, expected the `Home` key to take me to the start of the URL. It. Did. Not. So I decided that I won't be able to change this ingrained behaviour and need to fix it. First Google hit led me to a post by [Damian Guard](https://damieng.com/blog/2015/04/24/make-home-end-keys-behave-like-windows-on-mac-os-x) that I will be pasting below to keep as notes for myself. Everything from here on is from his post.

## Make Home & End keys behave like Windows on Mac OS X

*If, like me, you want Home to send you to the start of the line and not to the top of the document then create a file called DefaultKeyBinding.dict in your ~/Library/KeyBindings folder (might need to create that folder too) with the following contents:*

```text
{
    "\UF729"  = moveToBeginningOfParagraph:; // home
    "\UF72B"  = moveToEndOfParagraph:; // end
    "$\UF729" = moveToBeginningOfParagraphAndModifySelection:; // shift-home
    "$\UF72B" = moveToEndOfParagraphAndModifySelection:; // shift-end
    "^\UF729" = moveToBeginningOfDocument:; // ctrl-home
    "^\UF72B" = moveToEndOfDocument:; // ctrl-end
    "^$\UF729" = moveToBeginningOfDocumentAndModifySelection:; // ctrl-shift-home
    "^$\UF72B" = moveToEndOfDocumentAndModifySelection:; // ctrl-shift-end
}
```

*This remapping does the following in most Mac apps including Chrome (some apps do their own key handling):*
* *`Home` and `End` will go to start and end of line*
* *`Shift+Home` and `Shift+End` will select to start and end of line*
* *`Ctrl+Home` and `Ctrl+End` will go to start and end of document*
* *`Shift+Ctrl+Home` and `Shift+Ctrl+End` will select to start and end of document*
