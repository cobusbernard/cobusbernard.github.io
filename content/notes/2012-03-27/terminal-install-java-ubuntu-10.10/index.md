---
title: Install Java JDK using terminal
description: Notes on installing Java JDK using the terminal.
date: 2012-03-27
categories: [Linux]
tags: [java, linux]
aliases:
  - /linux/2012/03/27/Terminal-install-Java-Ubuntu-10.10
  - /linux/2012/03/27/Terminal-install-Java-Ubuntu-10.10.html
---
To install the Java JDK using only the terminal, follow the following steps:

Download the JDK from:

```bash
http://www.oracle.com/technetwork/java/javase/downloads/java-se-jdk-7-download-432154.html
```

Then run the following commands (change the filename as required):

```bash
tar -xvf jdk-7-linux-i586.tar.gz
sudo mv ./jdk1.7.0 /usr/lib/jvm/jdk1.7.0
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0/jre/bin/java 1
sudo update-alternatives --config java
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.7.0/bin/javac 1
sudo update-alternatives --config javac
```

To test that everything is working:

```bash
java -version
```

Should output:

```bash
java version "1.7.0"
Java(TM) SE Runtime Environment (build 1.7.0-b147)
Java HotSpot(TM) 64-Bit Server VM (build 21.0-b17, mixed mode)
```

```bash
javac -version
```

Should output:

```bash
javac 1.7.0
```
