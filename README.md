rhbase
======

A package that allows R developers to use Hadoop HBase, developed as part of the RHadoop project. Please see the [RHadoop wiki](https://github.com/RevolutionAnalytics/RHadoop/wiki) for information. 

This forked version is meant to make HBase easier and more intuitive to use (at least for myself :) ). It includes all necessary materials that I will/have presented at STRATA and will hopefully make your life easier. I have included a walk through tutorial in the "examples" directory that will take you through loading and unloading HBase intelligently and potentially at scale using whatever homemade beautiful #rstats you have made.

**Check out the "tutorial" of using rhbase in the examples directory**

All feedback, comments, questions, and help are appreciated.

Also, I'm not sure where my declaration needs to go that I have changed files, but I have changed some files... thanks Apache2

Also, as of right now, provided you have fulfilled the requirements of rhbase, you should be able to download this package by using devtools:
```
install_packages("devtools")
devtools::install_github("aaronbenz/rhbase")
```