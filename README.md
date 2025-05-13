# Friday Night Funkin': Paper Engine
A Psych Engine 0.7.3 fork focusing mostly on optimizing! Inspired by: [Codename Engine](https://github.com/CodenameCrew/CodenameEngine) & [NightmareVision Engine](https://github.com/DuskieWhy/NightmareVision)

Originally created for [FCR Alternate Timelines (Github page currently private)](https://github.com/paigefnf/FCR-Alternate-Timelines-Source)

# Building The Engine

NOTE: YOU NEED TO INSTALL THE LATEST VERSION OF HAXE IN ORDER TO INSTALL THE HAXE LIBRARIES!!!!

[Haxe download](https://haxe.org/download/)

Open the "setup" folder and you should see the .bat files and a SH file

If you're on Windows, follow these steps here:

* Run the "setup-msvc-win.bat" file to install MSVSC (MS Visual Studio Community), this is required as it also installs the necessary components in order to compile the mod

* After MSVSC finished installing, run the "setup-windows.bat" file, this will install all the haxe libraries required to build the mod

* Once all the haxe libraries have been installed, open up the terminal and type either "lime test windows" (release builds) or "lime test windows -debug" (test builds) and press enter, you should now be able to compile the mod (which usually takes about 30 minutes or less if this is the first time compiling, which happens to every other open source FNF mods)

* Once it's done compiling, the game will launch and now you can start modding!

(**FOR WINDOWS ONLY:** Alternatively, you can go to the "art" folder and run the "build" bats, if you're on a 32 bit PC (for some reason still using 32 bit), run the "build_x32", if on a 64 bit PC, run "build_x64"
or the "build_x64-debug" for test builds (there's no 32 bit version sorry lol))

If you're on Mac or Linux, follow these steps here:

* Run the "setup-msvc-win.bat" file to install MSVSC (MS Visual Studio Community), this is required as it also installs the necessary components in order to compile the mod

* After MSVSC finished installing, run the "setup-unix.sh" file, this will install all the haxe libraries required to build the mod

* Once all the haxe libraries have been installed, open up the terminal and type either "lime test windows" (release builds) or "lime test windows -debug" (test builds) and press enter, you should now be able to compile the mod (which usually takes about 30 minutes or less if this is the first time compiling, which happens to every other open source FNF mods)

* Once it's done compiling, the game will launch and now you can start modding!

# Downloading The Engine
[You can download the engine/latest version of the engine by clicking here](https://github.com/paigefnf/FNF-Paper-Engine/actions)
