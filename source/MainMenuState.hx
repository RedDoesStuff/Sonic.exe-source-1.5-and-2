package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var xval:Int = 100;

	var arrows:FlxSprite;

	var canTween:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var soundCooldown:Bool = true;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var bgdesat:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	
	var spikeUp:FlxSprite;
	var spikeDown:FlxSprite;

	override function create()
	{

		trace(FlxG.save.data.soundTestUnlocked);
		if (FlxG.save.data.soundTestUnlocked) optionShit.push('sound test');
		else optionShit.push('sound test locked');

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		PlayStateChangeables.nocheese = true;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('MainMenuMusic'));
		}

		FlxG.sound.playMusic(Paths.music('MainMenuMusic'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('backgroundlool'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * .5));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		bgdesat = new FlxSprite(-80).loadGraphic(Paths.image('backgroundlool2'));
		bgdesat.scrollFactor.x = 0;
		bgdesat.scrollFactor.y = 0;
		bgdesat.setGraphicSize(Std.int(bgdesat.width * .5));
		bgdesat.updateHitbox();
		bgdesat.screenCenter();
		bgdesat.visible = false;
		bgdesat.antialiasing = true;
		bgdesat.color = 0xFFfd719b;
		add(bgdesat);
		// bgdesat.scrollFactor.set();

		arrows = new FlxSprite(92, 182).loadGraphic(Paths.image('funniArrows'));
		arrows.scrollFactor.set();
		arrows.antialiasing = true;
		arrows.updateHitbox();
		add(arrows);
		FlxTween.tween(arrows, {y: arrows.y - 50}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

		spikeUp = new FlxSprite(0, -65).loadGraphic(Paths.image('spikeUp'));
		spikeUp.scrollFactor.x = 0;
		spikeUp.scrollFactor.y = 0;
		spikeUp.updateHitbox();
		spikeUp.antialiasing = true;
		

		spikeDown = new FlxSprite(-60 , 630).loadGraphic(Paths.image('spikeDown'));
		spikeDown.scrollFactor.x = 0;
		spikeDown.scrollFactor.y = 0;
		spikeDown.updateHitbox();
		spikeDown.antialiasing = true;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(xval, 40 + (i * 140));
			if (i % 2 == 0) menuItem.x -= 600 + i * 400;
			else menuItem.x += 600 + i * 400;

			FlxG.log.add(menuItem.x);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			if (firstStart)
				FlxTween.tween(menuItem,{x: xval},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						if(i == optionShit.length - 1)
						{
							finishedFunnyMove = true; 
							changeItem();
						}
					}});
			else
				menuItem.x = xval;

			xval = xval + 220;
		}

		add(spikeUp);
		add(spikeDown);

		firstStart = false;

		FlxG.camera.follow(camFollow, null);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var dataerase:FlxText = new FlxText(FlxG.width - 300, FlxG.height - 18 * 2, 300, "Hold DEL to erase ALL data (this doesn't include ALL options)", 3);
		dataerase.scrollFactor.set();
		dataerase.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dataerase);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.60);

		#if debug
		if (FlxG.keys.justPressed.R)
		{
			FlxG.save.data.storyProgress = 1;
			FlxG.save.data.soundTestUnlocked = true;
			FlxG.save.data.songArray = ["endless", 'cycles',"milk", "sunshine", 'faker', 'black-sun', "chaos"];
			FlxG.switchState(new MainMenuState());
		}
		#end

		if (FlxG.keys.justPressed.DELETE)
		{
			var urmom = 0;
			new FlxTimer().start(0.1, function(hello:FlxTimer)
			{
				urmom += 1;
				if (urmom == 30)
				{
					FlxG.save.data.storyProgress = 0; // lol.
					FlxG.save.data.soundTestUnlocked = false;
					FlxG.save.data.songArray = [];
					FlxG.switchState(new MainMenuState());
				}
				if (FlxG.keys.pressed.DELETE)
				{
					hello.reset();
				}
			});
		}


		if (canTween)
		{
			canTween = false;
			FlxTween.tween(spikeUp, {x: spikeUp.x - 60}, 1, {
				onComplete: function(twn:FlxTween)
				{
					spikeUp.x = 0;
					canTween = true;
				}
			});
			FlxTween.tween(spikeDown, {x: spikeDown.x + 60}, 1, {
				onComplete: function(twn:FlxTween)
				{
					spikeDown.x = -60;
				}
			});
		}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin && finishedFunnyMove)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());

			}


			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else if (optionShit[curSelected] == 'sound test locked')
				{
					if (soundCooldown)
					{
						soundCooldown = false;
						FlxG.sound.play(Paths.sound('deniedMOMENT'));
						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							soundCooldown = true;
						});
					}
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(bgdesat, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, .3, {
								ease: FlxEase.expoOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							//FlxTween.tween(spr, {x: 465, y: 280}, .4);
							FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.expoOut});
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});	
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
				trace("going to da options");
			case 'sound test':
				FlxG.switchState(new SoundTestMenu());
				trace("going to da sound test menu");
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			/*
			if (huh != 0) 
			{
				FlxTween.cancelTweensOf(spr);
			}
			FlxTween.tween(spr, {x: 100 + ((curSelected * -1 + spr.ID + 1) * 220) , y: 40 + ((curSelected * -1 + spr.ID + 1) * 140)}, 0.2);
			*/

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
