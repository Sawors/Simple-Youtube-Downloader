
# YTDL
## Simple Command Line YouTube Downloader
The goal of this tool is to allow you to simply download the audio from YouTube videos directly from the command line using only the video title.

It works by performing a search using the title you provided and then proceeds to download the first result.
It also allows you to display the videos found by the search and then lets you select your desired result to download.
## Usage
### Downloading
Use `ytdl` followed by the title of the video to directly download it.
The audio will be downloaded where the command line is opened (cd/current directory)

    $ ytdl <args> [title of the video]
For instance this will download the song *Free Bird* by *Lynyrd Skynyrd* to a mp3 file, it is as simple as that :

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

	File located at /home/username/MusicSuper Mario Bros. Theme Song.mp3
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
