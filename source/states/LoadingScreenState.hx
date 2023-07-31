package states;

#if desktop
import backend.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import lime.system.ThreadPool;
import sys.FileSystem;
import sys.io.File;
import backend.ClientPrefs;
import backend.CoolUtil;
import backend.Paths;

using StringTools;

class LoadingScreenState extends FlxState {
	var checker:FlxBackdrop;
    var bg:FlxSprite;
	var PsychEngineLogo:FlxSprite;
	var beginTween:FlxTween;
	var bottomPanel:FlxSprite;
	var randomTxt:FlxText;
	var loadingSpeen:FlxSprite;
	var loadingTxt:FlxText;
	var isTweening:Bool = false;
	var lastString:String = '';

	override function create() {
		FlxG.worldBounds.set(0, 0);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Starting game...", null);
		#end

		super.create();

        bg = new FlxSprite().loadGraphic(Paths.image("BgArrows"));
		bg.screenCenter();
		bg.y -= 60;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.alpha = 0;
		bg.scale.x = 0;
		bg.scale.y = 0;
		add(bg);

		psychEngineLogo = new FlxSprite().loadGraphic(Paths.image("Psych_Logo"));
		psychEngineLogo.screenCenter();
		psychEngineLogo.y -= 60;
		psychEngineLogo.antialiasing = ClientPrefs.globalAntialiasing;
		psychEngineLogo.alpha = 0;
		psychEngineLogo.scale.x = 0;
		psychEngineLogo.scale.y = 0;
		add(psychEngineLogo);

		bottomPanel = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

		randomTxt = new FlxText(20, FlxG.height - 80, 1000, "", 26);
		randomTxt.scrollFactor.set();
		randomTxt.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(randomTxt);

		loadingSpeen = new FlxSprite().loadGraphic(Paths.image("loading_speen"));
		loadingSpeen.screenCenter(X);
		loadingSpeen.setGraphicSize(Std.int(loadingSpeen.width * 0.89));
		loadingSpeen.x = FlxG.width - 91;
		loadingSpeen.y = FlxG.height - 91;
		loadingSpeen.angularVelocity = 180;
		loadingSpeen.antialiasing = backend.ClientPrefs.globalAntialiasing;
		add(loadingSpeen);

		loadingTxt = new FlxText(12, FlxG.height - 30, 0, "", 8);
		loadingTxt.scrollFactor.set();
		loadingTxt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingTxt.borderSize = 1.25;
		loadingTxt.text = "Loading psych Engine Forever v" + MainMenuState.psychEngineforeverVersion + " (Psych Engine v" + MainMenuState.psychEngineVersion + " ). Please be patient...";
		add(loadingTxt);

		FlxTween.tween(psychEngineLogo, {alpha: 1}, 0.75, {ease: FlxEase.quadInOut});
		beginTween = FlxTween.tween(psychEngineLogo.scale, {x: 1, y: 1}, 0.75, {ease: FlxEase.quadInOut});

		#if desktop
		FlxG.mouse.visible = false;
		#end

		new FlxTimer().start(10, function(tmr:FlxTimer) {
			goToTitleScreenState();
		});

		super.create();
	}

	var selectedSomething:Bool = false;

	var timer:Float = 0;

	override function update(elapsed:Float) {
		if (!selectedSomething) {
			if (isTweening) {
				randomTxt.screenCenter(X);
				timer = 0;
			} else {
				randomTxt.screenCenter(X);
				timer += elapsed;
				if (timer >= 3) {
					changeText();
				}
			}
		}
		super.update(elapsed);
	}

	function goToTitleScreenState() {
    FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() {
		FlxG.switchState(new TitleScreenState());
	    });
	}

	function changeText() {
		var selectedText:String = '';
		var textArray:Array<String> = CoolUtil.coolTextFile(SUtil.getPath() + Paths.txt('psychEngineforeverTip'));

		randomTxt.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(randomTxt, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(freak:FlxTween) {
				if (selectedText != lastString) {
					randomTxt.text = selectedText;
					lastString = selectedText;
				} else {
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					randomTxt.text = selectedText;
				}

				randomTxt.alpha = 0;

				FlxTween.tween(randomTxt, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(freak:FlxTween) {
						isTweening = false;
					}
				});
			}
		});
	}
}