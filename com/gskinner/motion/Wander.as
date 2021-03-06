/**
 * Wander by Grant Skinner. Oct 28, 2009
 * Visit www.gskinner.com/blog for documentation, updates and more free code.
 *
 *
 * Copyright (c) 2009 Grant Skinner
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/

package com.gskinner.motion {
	import flash.display.DisplayObject;
	import flash.events.Event;

	
	/**
	 * <b>Wander ©2009 Grant Skinner, gskinner.com. Visit www.gskinner.com/blog/ for documentation, updates and more free code. Licensed under the MIT license - see the source file header for more information.</b>
	 * <hr/>
	 * Applies wander motion to a target display object, rotating and moving it according to a wide set of properties.
	 **/
	public class Wander {
		
	// Static interface:
		/** @private **/
		protected static const pi:Number = Math.PI;
		/** @private **/
		protected static const pi2:Number = pi*2;
		/** @private **/
		protected static const degToRad:Number = pi/180;
		
		/** Helper function that returns the shortest equivalent rotation value. For example, -90deg is a shorter equivalent of 270deg, and 15deg is equivalent to 375deg. **/
		public static function getShortRotation(rot:Number):Number {
			rot %= pi2;
			if (rot > pi) { rot -= pi2; }
			else if (rot < -pi) { rot += pi2; }
			return rot;
		}
		
		
	// Public properties:
		/** The display object to move. **/
		public var target:DisplayObject;
		/** The x position the target will trend towards or NaN to disable. **/
		public var targetX:Number;
		/** The y position the target will trend towards or NaN to disable. **/
		public var targetY:Number;
		/** A display object whose x/y will be used as targetX / targetY (ie. the wander will follow the targetObject). Set to null to disable. **/
		public var targetObject:DisplayObject;
		/** The rotation in degrees the target will trend towards or NaN to disable. **/
		public var targetRotation:Number;
		/** The radius (from targetX and/or targetY) within which the target does not trend towards the target position. **/
		public var innerRadius:Number;
		/** The maximum distance (from targetX and/or targetY) the target can wander from the target position. The strength of this trend increases exponentially as the target wanders away from the innerRadius and approaches the outerRadius. **/
		public var outerRadius:Number;
		/** The distance the target will travel each frame. **/
		public var speed:Number;
		/** The amount that the speed will vary randomly each frame. For example, with a speed of 4 and varySpeed of 0.5, the speed will vary from 2 to 4. **/
		public var varySpeed:Number;
		/** The amount that the target will vary rotation randomly (ie. wander). For example, a value of 0.5 would let the rotation vary by +/- 45 degrees each frame. **/
		public var varyRotation:Number;
		/** The constant 0-1 strength applied to all active trends (based on targetX, targetY, or targetRotation). This is additive with strengths calculated from outerRadius and count. **/
		public var strength:Number;
		/** As the internal counter approaches count, it adds a exponentially derived value to strength, such that when the internal counter equals count, the trend strength will be 1. **/
		public var count:uint;
		/** Allows you to delay the effect of the count property by the specified number of frames. **/
		public var delayCount:uint;
		/** Allows you to associate arbitrary data with this wander instance. **/
		public var data:Object;
		/** Limits the maximum rotation change that the wander can make per update. Set to NaN to disable. **/
		public var rotationLimit:Number;
		
		/** Returns the previous x position of the target. **/
		public var oldX:Number;
		/** Returns the previous y position of the target. **/
		public var oldY:Number;
		/** Returns the previous rotation of the target. **/
		public var oldRotation:Number;
		
		/** This callback is called each frame while the wander is active. **/
		public var onComplete:Function;
		/** This callback is called when count . **/
		public var onChange:Function;
		
		
	// Protected properties:
		/** @private **/
		protected var _autoUpdate:Boolean;
		/** @private **/
		protected var _count:Number;
		
		
	// Construction:
		/**
		 * Creates a new wander instance.
		 * 
		 * @param target Specifies the DisplayObject to move.
		 * @param props Shortcut for setting properties on the new instance. All properties on this object are copied to the new instance. ex. {targetRotation:0, strength:0.1}
		 **/
		public function Wander(target:DisplayObject,props:Object=null) {
			this.target = target;
			if (!(autoUpdate in props)) { props.autoUpdate = true; }
			reset(props);
		}
		
		
	// Public getter/setters:
		/** Specifies whether the wander updates each frame automatically. True by default. This can be used to pause / resume the motion. It can also be set to false and you can call .update() directly - for example, in a game with a central "tick" dispatcher. **/
		public function get autoUpdate():Boolean {
			return _autoUpdate;
		}
		public function set autoUpdate(value:Boolean):void {
			_autoUpdate = value;
			if (value) { target.addEventListener(Event.ENTER_FRAME, handleTick); }
			else { target.removeEventListener(Event.ENTER_FRAME, handleTick); }
		}
		
		
	// Public methods:
		/** Resets all of the instance's default properties except target, and applies the specified props. **/
		public function reset(props:Object=null):void {
			targetObject = null;
			targetX = targetY = targetRotation = NaN;
			innerRadius = outerRadius = varySpeed = strength = count = delayCount = _count = 0;
			speed = 4;
			varyRotation = 0.2;
			
			if (props) {
				for (var n:String in props) {
					this[n] = props[n];
				}
			}
			oldX = target.x;
			oldY = target.y;
		}
		
		/** Runs the next "frame" of the wander - varying the rotation according to the instance properties and moving forwards. This is called every frame when autoUpdate is true, or can be called directly. **/
		public function update():void {
			oldRotation = target.rotation;
			oldX = target.x;
			oldY = target.y;
			
			var rotation:Number = target.rotation/180*pi;
			var oldR:Number = rotation;
			rotation += pi*varyRotation*0.5-pi*varyRotation*Math.random();
			
			// calculate strength:
			var str:Number = strength;
			var complete:Boolean = false;
			if (count > 0) {
				_count++;
				var c:Number = (_count-delayCount)/count;
				if (c > 1) { c = 1; }
				if (c > 0) { str += (1-str)*c*c; }
				if (c == 1) { complete=true; }
			}
			
			// targetRotation:
			if (str > 0 && !isNaN(targetRotation)) {
				rotation += getShortRotation(targetRotation*degToRad-rotation)*str;
				if (complete || count == 0) { complete = Math.abs(targetRotation-rotation)<1; }
			}
			
			// target position / object:
			if ((str > 0 || outerRadius > 0) && (targetObject || !isNaN(targetX) || !isNaN(targetY))) {
				var tx:Number = targetObject ? targetObject.x : isNaN(targetX) ? target.x : targetX;
				var ty:Number = targetObject ? targetObject.y :isNaN(targetY) ? target.y : targetY;
				var dx:Number = tx-target.x;
				var dy:Number = ty-target.y;
				var d:Number = Math.sqrt(dx*dx+dy*dy);
				var a:Number = Math.atan2(dy,dx);
				var pstr:Number = str;
				
				if (outerRadius > 0) {
					var dstr:Number = (d-innerRadius)/(outerRadius-innerRadius);
					if (dstr > 1) { dstr = 1; }
					if (dstr > 0) { pstr += (1-pstr)*(dstr*dstr); }
				}
				rotation += getShortRotation(a-rotation)*pstr;
				complete = c>0 && _count > 1 && d<speed;
			}
			
			// limit rotation:
			if (!isNaN(rotationLimit)) {
				var rotationD:Number = rotation-oldR;
				if (Math.abs(rotationD) > rotationLimit*degToRad) { 
					rotation = oldR+rotationLimit*degToRad*(rotationD<0?-1:1);
				}
			}
			
			if (complete) {
				if (!isNaN(targetX)) { target.x = targetX; }
				if (!isNaN(targetY)) { target.y = targetY; }
				if (!isNaN(targetRotation)) { target.rotation = targetRotation; }
			} else {
				var sp:Number = speed-speed*varySpeed*Math.random();
				target.x += Math.cos(rotation)*sp;
				target.y += Math.sin(rotation)*sp;
				target.rotation = rotation/degToRad;
			}
			
			if (onChange != null) { onChange(this); }
			if (complete && onComplete != null) { onComplete(this); }
		}
		
		
	// Protected methods:
		protected function handleTick(evt:Event):void {
			update();
		}
		
	}
}