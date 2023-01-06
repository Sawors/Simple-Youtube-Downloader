
# YTDL
## Simple Command Line YouTube Downloader
The goal of this tool is to allow you to download the audio of YouTube videos directly from the command line using just the video title.

It works by performing a search using the title you provided and then proceeds to download the first result found.
It also allows you to display the videos found by the search and then lets you select your desired result for downloading.
## Usage
### Downloading
Use `ytdl` followed by the title of the video to directly download it, it is as simple as that.
The audio will be downloaded where the command line is opened (cd/current directory)

    $ ytdl <args> [title of the video]
For instance this will download the song *Free Bird* by *Lynyrd Skynyrd* to a mp3 file :

	$ ytdl free bird
Arguments :
- **-ogg** : Will download the file in ogg instead of the default mp3 format
- **-mp3** : Will download the file in mp3, usually this is useless since the file is already in mp3 by default
- -**ls** : Enables **`List Mode`**
- **-list** : Enables **`List Mode`**

Usage example (command executed in `/home/username/Music`): 

    $ ytdl mario theme
    
	Downloading "Super Mario Bros. Theme Song"...

	Successfully downloaded "Super Mario Bros. Theme Song" !

	File located at /home/username/Music/Super Mario Bros. Theme Song.mp3
	Channel : ultragamemusic
	Duration : 01:23

### List Mode
The **`List Mode`** allows you to chose in a list of videos the video you want to download in case the default `ytdl` would find the wrong one.
Usually this mode can be avoided by using a more precise search, sending for instance `$ ytdl thriller michael jackson` instead of `$ ytdl thriller`.

	$ ytdl -ls thriller
	
	Searching for "thriller"...
	Videos found while searching for "thriller" :
	  [1] "Michael Jackson - Thriller (Official 4K Video)" - 13:42
	  [2] "Michael Jackson - Thriller (Official Video - Shortened Version)" - 03:22
	  [3] "Thriller (2003 Edit)" - 05:12
	  [4] "Michael Jackson - Thriller (Lyrics)" - 05:58
	  [5] "Michael Jackson - Thriller - Thriller" - 05:58
	              [page 1] -n->

	Enter "N", "n" or "next" to go to the next page,
	Enter "P", "p" or "previous" to go to the previous page,
	Enter "x", "e" or "exit" to exit
	Or enter the number of the video you want to download

	Action : |
	
	
### How to install
This tool can be used right after downloading without the need for an installation (portable).
However if you want to use it from the command line using directly `ytdl` regardless of the directory you need to go through a few extra steps.
For the moment you have to perform the installation by hand, an installer will be provided eventually.

#### Windows :
- On Windows place the ytdl.exe in a proper directory, for instance `C:\Program Files\Simple Youtube Downloader\`.
- After this go to your environement variables and edit `Path` to add the directory where ytdl.exe is installed. [how to edit environement variables on Windows](https://www.wikihow.com/Change-the-PATH-Environment-Variable-on-Windows)
- Usually you will have to restart you computer for this change to take effect
