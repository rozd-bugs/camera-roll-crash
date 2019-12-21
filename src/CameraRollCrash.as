package {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MediaEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.media.CameraRoll;
import flash.media.InputMediaStream;
import flash.media.MediaPromise;
import flash.system.System;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.IDataInput;

public class CameraRollCrash extends Sprite
{
    public function CameraRollCrash()
    {
//        if (CameraRoll.supportsBrowseForImage)
//        {
//            cameraRoll.addEventListener(MediaEvent.SELECT, selectHandler);
//
//            cameraRoll.browseForImage();
//        }

        this.stage.color = 0xFF0000;

        addChild(textField);

        new PlainButton(this, {label : "Open", y : 0}, function(event:Event):void
        {
            if (CameraRoll.supportsBrowseForImage)
            {
                cameraRoll.addEventListener(MediaEvent.SELECT, selectHandler);

                cameraRoll.browseForImage();
            }
        });
    }

    private var stream:FileStream;

    private var textField:TextField = new TextField();

    private var cameraRoll:CameraRoll = new CameraRoll();

    private function selectHandler(event:MediaEvent):void
    {
        cameraRoll.removeEventListener(MediaEvent.SELECT, selectHandler);

        var promise:MediaPromise = event.data;

//        var o:InputMediaStream = promise.open() as InputMediaStream;

        var stream:IDataInput = promise.open();

//        trace(stream == o);

        var read:Function = function():void
        {
            var bytes:ByteArray = new ByteArray();
            stream.readBytes(bytes);

            stage.color = 0x009900;

            // read ok
        };

        if (promise.isAsync)
        {
            IEventDispatcher(stream).addEventListener(Event.COMPLETE,
                function(event:Event):void
                {
                    IEventDispatcher(stream).removeEventListener(Event.COMPLETE, arguments.callee);

                    read();
                });

            IEventDispatcher(stream).addEventListener(ProgressEvent.PROGRESS,
                function(event:ProgressEvent):void
                {
                    if (event.bytesLoaded == event.bytesTotal)
                    {
                        IEventDispatcher(stream).removeEventListener(ProgressEvent.PROGRESS, arguments.callee);

                        read();
                    }
                    else
                    {
                        stage.color = 0x990077;
                    }

                    textField.text = event.bytesLoaded + " / " + event.bytesTotal;
                });
        }
        else
        {
            read();
        }
    }
}
}


import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class PlainButton extends Sprite
{
    function PlainButton(parent:DisplayObjectContainer=null, properties:Object=null, clickHandler:Function=null)
    {
        super();

        _props = properties;
        _label = properties ? (properties.label || "") : "";
        _color = properties ? (properties.color || 0) : 0;

        var textColor:uint = properties ? (properties.textColor || 0xFFFFFF) : 0xFFFFFF;

        textDisplay = new TextField();
        textDisplay.defaultTextFormat = new TextFormat("_sans", 24, textColor, null, null, null, null, null, TextFormatAlign.CENTER);
        textDisplay.selectable = false;
        textDisplay.autoSize = "center";
        addChild(textDisplay);

        x = _props.x || 0;
        y = _props.y || 0;

        if (parent)
            parent.addChild(this);

        if (clickHandler != null)
            addEventListener(MouseEvent.CLICK, clickHandler);

        sizeInvalid = true;
        labelInvalid = true;

        addEventListener(Event.ENTER_FRAME, renderHandler);
    }

    private var sizeInvalid:Boolean;
    private var labelInvalid:Boolean;

    private var _label:String;
    private var _color:uint;
    private var _props:Object;

    private var textDisplay:TextField;

    private function renderHandler(event:Event):void
    {
        if (labelInvalid)
        {
            labelInvalid = false;

            textDisplay.text = _label;
        }

        if (sizeInvalid)
        {
            sizeInvalid = false;

            var w:Number = _props.width || _props.w || 100;
            var h:Number = _props.height || _props.h || 40;

            graphics.clear();
            graphics.beginFill(_color);
            graphics.drawRect(0, 0, w, h);
            graphics.endFill();

            textDisplay.x = 0;
            textDisplay.width = w;
            textDisplay.y = (h - textDisplay.height) / 2;
        }
    }
}