package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.mappings.MayflashWiiRemoteMapping;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

using StringTools;

#if sys
import smTools.SMFile;
#end
#if windows
import Discord.DiscordClient;
#end
#if cpp
import sys.thread.Thread;
#end

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var code:Int = 0;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod'], frameworkParams: {}});
		#end

		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}

		PlayerSettings.init();

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());

		trace('hello');

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		KadeEngineData.initSave();

		// var file:SMFile = SMFile.loadFile("file.sm");
		// this was testing things

		Highscore.load();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var logoBlBUMP:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(5, 0, 0.7);
		}

		Conductor.changeBPM(190);
		persistentUpdate = true;

		bg = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('NewTitleMenuBG', 'exe');
		bg.animation.addByPrefix('idle', "TitleMenuSSBG instance 1", 24);
		bg.animation.play('idle');
		bg.alpha = .75;
		bg.scale.x = 3;
		bg.scale.y = 3;
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		logoBlBUMP = new FlxSprite(0, 0);
		logoBlBUMP.loadGraphic(Paths.image('Logo', 'exe'));
		logoBlBUMP.antialiasing = true;

		logoBlBUMP.scale.x = .5;
		logoBlBUMP.scale.y = .5;

		logoBlBUMP.screenCenter();

		add(logoBlBUMP);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(0, 0);
		titleText.frames = Paths.getSparrowAtlas('titleEnterNEW');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin instance 1", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED instance 1", 24, false);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		// credGroup.add(credTextShit);

		FlxG.sound.play(Paths.sound('TitleLaugh'), 1, false, null, false, function()
		{
			skipIntro();
		});
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (FlxG.keys.justPressed.UP)
			if (code == 0)
				code = 1;
			else
				code == 0;

		if (FlxG.keys.justPressed.DOWN)
			if (code == 1)
				code = 2;
			else
				code == 0;

		if (FlxG.keys.justPressed.LEFT)
			if (code == 2)
				code = 3;
			else
				code == 0;

		if (FlxG.keys.justPressed.RIGHT)
			if (code == 3)
				code = 4;
			else
				code == 0;

		if (pressedEnter && !transitioning && skippedIntro && code != 4)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.RED, 0.2);
			FlxG.sound.play(Paths.sound('menumomentclick', 'exe'));
			FlxG.sound.play(Paths.sound('menulaugh', 'exe'));

			FlxTween.tween(bg, {alpha: 0}, 1);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxTween.tween(logoBlBUMP, {alpha: 0}, 1);
			});

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;

			new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				// Get current version of Kade Engine

				var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");
				var returnedData:Array<String> = [];

				var video:MP4Handler = new MP4Handler();
				video.playMP4(Paths.video('bothCreditsAndIntro'));
				video.finishCallback = function()
				{
					LoadingState.loadAndSwitchState(new MainMenuState());
				}

				http.onData = function(data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf(';'));
					returnedData[1] = data.substring(data.indexOf('-'), data.length);

					// FlxG.switchState(new VideoState('assets/videos/sonic1.webm', new MainMenuState()));
				}

				http.onError = function(error)
				{
					trace('error: $error');
					FlxG.switchState(new MainMenuState()); // fail but we go anyway
				}

				http.request();
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}
		else if (pressedEnter && !transitioning && skippedIntro && code == 4)
		{
			transitioning = true;

			PlayStateChangeables.nocheese = false;
			PlayState.SONG = Song.loadFromJson('milk', 'milk');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 1;
			FlxG.camera.fade(FlxColor.WHITE, 0.5, false);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			if (!FlxG.save.data.songArray.contains('milk') && !FlxG.save.data.botplay)
				FlxG.save.data.songArray.push('milk');
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function playBoop1()
	{
		if (!skippedIntro)
		{
			FlxG.sound.play(Paths.sound('boop1', 'shared'));
		}
	}

	function playBoop2()
	{
		if (!skippedIntro)
		{
			FlxG.sound.play(Paths.sound('boop2', 'shared'));
		}
	}

	function playShow()
	{
		if (!skippedIntro)
		{
			FlxG.sound.play(Paths.sound('showMoment', 'shared'), .4);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		/*logoBl.animation.play('bump');
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');

			FlxG.log.add(curBeat);

				switch (curBeat)
				{
					case 10:
						playBoop1();
						createCoolText(['RightBurst', 'MarStarBro', 'Razencro', 'Comgaming_Nz', 'Zekuta', 'Crybit']);
					case 11:
						playBoop1();
						addMoreText('present');
					case 12:
						playBoop2();
						deleteCoolText();
					case 13:
						playBoop1();
						createCoolText(['Programming']);
					case 14:
						playBoop1();
						addMoreText('by');
					case 15: 
						playBoop1();
						addMoreText('Razencro and Crybit');
					case 16:
						playBoop1();
						addMoreText('Mod Idea');
					case 17:
						playBoop1();
						addMoreText('and Art by');
					case 18:
						playBoop1();
						addMoreText('Rightburst');
					case 19:
						playBoop2();
						deleteCoolText();
					case 20:
						playBoop1();
						createCoolText(['Art by']);
					case 21:
						playBoop1();
						addMoreText('Comgaming_Nz');
					case 22:
						playBoop1();
						addMoreText('Music by');
					case 23:
						playBoop1();
						addMoreText('MarStarBro');
					case 24:
						playBoop1();
						addMoreText('Art by');
					case 25:
						playBoop1();
						addMoreText('Zekuta');
					case 26:
						playBoop2();
						deleteCoolText();
					case 27:
						if (curWacky[0] != null || curWacky[0] != '') playBoop1();
						createCoolText([curWacky[0]]);
					case 28:
						if (curWacky[1] != null || curWacky[1] != '') playBoop1();
						addMoreText(curWacky[1]);
					case 29:
						if (curWacky[2] != null || curWacky[2] != '') playBoop1();
						addMoreText(curWacky[2]);
					case 30:
						if (curWacky[3] != null || curWacky[3] != '') playBoop1();
						addMoreText(curWacky[3]);
					case 31:
						playBoop2();
						deleteCoolText();
					case 32:
						playBoop1();
						createCoolText(['Friday']);
					case 33:
						playBoop1();
						addMoreText('Night');
					case 34:
						playBoop1();
						addMoreText('Funkin');
					case 35:
						playShow();
						skipIntro();
			}
		 */
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.sound.play(Paths.sound('showMoment', 'shared'), .4);

			FlxG.camera.flash(FlxColor.RED, 2);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
