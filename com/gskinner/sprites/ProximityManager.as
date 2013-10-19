﻿/*** ProximityManager (AS3 Version) by Grant Skinner. Jan 4, 2008* Visit www.gskinner.com/blog for documentation, updates and more free code.** You may distribute and modify this class freely, provided that you leave this header intact,* and add appropriate headers to indicate your changes. Credit is appreciated in applications* that use this code, but is not required.** Please contact info@gskinner.com for more information.*/package com.gskinner.sprites {		import flash.utils.Dictionary;	import flash.display.DisplayObject;		public class ProximityManager {			// public properties:		public var gridSize:uint;			// private properties:		public var displayObjects:Dictionary;		private var positions:Array;		private var cachedResults:Array;			// initialization:		public function ProximityManager(gridSize:uint=25) {			this.gridSize = gridSize;			displayObjects = new Dictionary(true);			positions = [];			cachedResults = [];		}			// public methods:		public function getNeighbors(mc:DisplayObject):Array {			var off:uint = gridSize*1024;			var index:uint = ((mc.x+off)/gridSize)<<11|((mc.y+off)/gridSize); // max of +/- 2^10 (1024) rows and columns.						if (cachedResults[index]) { return cachedResults[index]; }						var p:Array = positions;			var r:Array = p[index];			if (r == null) { r = []; }						if (p[index-2048-1]) { r = r.concat(p[index-2048-1]); }			if (p[index-1]) { r = r.concat(p[index-1]); }			if (p[index+2048-1]) { r = r.concat(p[index+2048-1]); }						if (p[index-2048]) { r = r.concat(p[index-2048]); }			if (p[index+2048]) { r = r.concat(p[index+2048]); }						if (p[index-2048+1]) { r = r.concat(p[index-2048+1]); }			if (p[index+1]) { r = r.concat(p[index+1]); }			if (p[index+2048+1]) { r = r.concat(p[index+2048+1]); }						cachedResults[index] = r;						return r;		}				public function addItem(mc:DisplayObject):void {			displayObjects[mc] = -1;		}				public function removeItem(mc:DisplayObject):void {			delete(displayObjects[mc]);		}				public function refresh():void {			// calculate grid positions:			var m:Dictionary = displayObjects;			var p:Array = [];			var gs:uint = gridSize;			var off:uint = gridSize*1024;			for (var o:Object in m) {				var mc:DisplayObject = o as DisplayObject;				var index:uint = ((mc.x+off)/gridSize)<<11|((mc.y+off)/gridSize); // max of +/- 2^10 (1024) rows and columns.								if (p[index] == null) { p[index] = [o]; continue; }				(p[index] as Array).push(o);			}			cachedResults = [];			positions = p;		}	}}