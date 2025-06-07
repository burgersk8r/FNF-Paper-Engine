#if !macro
//Discord API
#if DISCORD_ALLOWED
import funkin.backend.Discord;
#end

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import funkin.backend.system.Achievements;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import funkin.backend.assets.Paths;
import funkin.backend.system.Controls;
import funkin.backend.system.Achievements;
import funkin.data.CoolUtil;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatSubstate;
import funkin.backend.CustomFadeTransition;
import funkin.data.ClientPrefs;
import funkin.backend.system.Conductor;
import funkin.backend.assets.BaseStage;
import funkin.backend.system.Difficulty;
import funkin.backend.assets.Mods;
import funkin.backend.assets.BaseStage;
import funkin.backend.system.Main;

import funkin.objects.Alphabet;
import funkin.objects.BGSprite;

import funkin.game.PlayState;
import funkin.game.LoadingState;

#if flxanimate
import flxanimate.*;
#end
#if !html5
import funkin.backend.animation.flxanimate.PsychFlxAnimate as FlxAnimate;
#end
//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;
#end