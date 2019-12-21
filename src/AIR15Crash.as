/**
 * Created by mobitile on 10/15/14.
 */
package
{
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Rectangle;
import flash.media.CameraRollBrowseOptions;
import flash.system.Capabilities;
import flash.text.StageText;

import starling.core.Starling;
import starling.events.Event;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;

[SWF(width="320",height="480",frameRate="60",backgroundColor="#4a4137")]
public class AIR15Crash extends Sprite
{
    public function AIR15Crash()
    {
        super();

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        var text:StageText = new StageText();
        text.viewPort = new Rectangle(0, 0, 100, 100);

        text.stage = this.stage;

//        text.text = "Test";

        var bmd:BitmapData = new BitmapData(text.viewPort.width, text.viewPort.height);

//        text.stage = null;

        text.drawViewPortToBitmapData(bmd);

        var stageWidth:int   = 320;
        var stageHeight:int  = 480;

        Starling.multitouchEnabled = true;  // useful on mobile devices

        Starling.handleLostContext = true;

        var viewPort:Rectangle = RectangleUtil.fit(
                new Rectangle(0, 0, stageWidth, stageHeight),
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),
                ScaleMode.SHOW_ALL);

        _starling = new Starling(Main, stage, viewPort);
        _starling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
        _starling.stage.stageHeight = stageHeight; // <- same size on all devices!
        _starling.simulateMultitouch  = false;
        _starling.enableErrorChecking = Capabilities.isDebugger;

        _starling.addEventListener(starling.events.Event.ROOT_CREATED,
           function(event:Object, app:Main):void
           {
               _starling.removeEventListener(starling.events.Event.ROOT_CREATED, arguments.callee);

               _starling.start();
           });
    }

    private var _starling:Starling;
}
}

////////////////////////////////////////////////////////////////////////////////
//
//  Main
//
////////////////////////////////////////////////////////////////////////////////

import feathers.controls.Button;
import feathers.controls.TextInput;
import feathers.themes.MetalWorksMobileTheme;

import flash.media.CameraRoll;

import starling.core.Starling;

import starling.display.Sprite;
import starling.events.Event;

class Main extends Sprite
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function Main()
    {
        super();

        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    protected var input:TextInput;

    protected var button:Button;

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    protected function addedToStageHandler(event:Event):void
    {
        this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

        new MetalWorksMobileTheme();

//        var input:TextInput = new TextInput();
//        addChild(input);
//        input.y = -2000;

        // create input

        this.input = new TextInput();
        this.input.addEventListener(Event.CHANGE, input_changeHandler);
        this.input.prompt = "Enter something to enable 'CameraRoll' button.";
        this.addChild(this.input);
        this.input.validate();
        this.input.x = Math.round((this.stage.stageWidth - this.input.width) / 2);
        this.input.y = 20;

        // create button

        this.button = new Button();
        this.button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
        this.button.label = "CameraRoll";
//        this.button.isEnabled = false;
        this.addChild(this.button);
        this.button.validate();
        this.button.x = Math.round((this.stage.stageWidth - this.button.width) / 2);
        this.button.y = Math.round((this.stage.stageHeight - this.button.height) / 2);
    }

    //-------------------------------------
    //  Event handlers: input
    //-------------------------------------

    private function input_changeHandler(event:Event):void
    {
        // #1 we need texture in TextInput
        this.button.isEnabled = Boolean(this.input.text);
    }

    //-------------------------------------
    //  Event handlers: button
    //-------------------------------------

    protected function button_triggeredHandler(event:Event):void
    {
        // #2 TextInput should be removed
        this.removeChild(this.input);

        if (CameraRoll.supportsBrowseForImage)
        {
            Starling.current.stop(true);

            var cameraRoll:CameraRoll = new CameraRoll();
            cameraRoll.addEventListener("cancel",
                function cameraRoll_cancelHandler(event:Object):void
                {
                    cameraRoll.removeEventListener("cancel", cameraRoll_cancelHandler);

                    Starling.current.start();
                });

            cameraRoll.browseForImage();
        }
    }
}