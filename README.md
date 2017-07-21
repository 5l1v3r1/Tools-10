# Motivation

This repository contains some tools that are useful, with their descriptions and more info.

The objective for this repository is to have a list with all the tools that I (or someone else) may need. The ultimate goal is to be able to install and use all this tools on fresh installations of, at least, Debian-based distributions (specifically aimed at Ubuntu)



# Files and directories

## installer.sh
Shell script (POSIX complaint) to install all tools listed on __tools.json__

## tools.json
List, on JSON format, with an object with the following fields:

 1. __categories__: Categories to classify the tool and facilitate searching
 2. __config__: Object with information about the configuration of the tool. This object	can have these values:

    1. __custom__: Array with location of custom config files (on this repository)
    2. __default__: Array with location of the default configuration files (on the system)

 3. __description__: String with a biref description of the tool
 4. __package__: Name of the aptitude package (if any), to easily install it via `apt-get`, or the URL where the package can be downloaded and installed


## vim
Directory with a customized configuration file for Vim and a couple of files for syntax highlighting. Needs [Vundle](https://github.com/VundleVim/Vundle.vim)


The installed plugins are the following:

 - [Vundle](https://github.com/VundleVim/Vundle.vim) (required to manage every other plugin)
 - [UltiSnips](https://github.com/SirVer/ultisnips): Engine to allow suggestions for autocompletion

    - [Vim-Snippets](https://github.com/honza/vim-snippets): Actual snippets to be used with _UltiSnips_

 - [AutoTags](https://github.com/craigemery/vim-autotag): Automatic update of tags created with `ctags`
 - [YouCompleteMe](https://github.com/Valloric/YouCompleteMe): Code completion
 - [YCM-Generator](https://github.com/rdnetto/YCM-Generator): Generates _YouCompleteMe_ config files from the projects' _Makefiles_
 - [SuperTab](https://github.com/ervandew/supertab): Provides compatibility for _YouCompleteMe_ and _UltiSnips_, allowing autocompletion with <Tab>
 - [NERDTree](https://github.com/scrooloose/nerdtree): Tree explorer more advanced than the default one
 - [Vebugger](https://github.com/idanarye/vim-vebugger): Frontend compatible with _GDB_
 - [TagBar](https://github.com/majutsushi/tagbar): Displays tags of the current file on a side window
 - [Scala](https://github.com/derekwyatt/vim-scala): Integration of Scala into Vim
 - [PHPComplete](https://github.com/shawncplus/phpcomplete.vim): Improved PHP omnicompletion
 - [LOLCode](https://github.com/Xe/lolcode.vim): Syntax highlighting for LOLCode
 - [Java GetSet](https://github.com/vim-scripts/java_getset.vim): Implements some functions to add getters and setters to an attribute on Java
 - [JavaComplete 2](https://github.com/artur-shaik/vim-javacomplete2): Updated version of the plugin _javacomplete_
 - [HTML AutoCloseTag](https://github.com/vim-scripts/HTML-AutoCloseTag): Automatically closes HTML tags
 - [Android](https://github.com/hsanson/vim-android): Support for Android development

## aux_installers
Directory with installers for tools not provided with aptitude
