package com.bitsushi.utils
{ 
  import flash.display.DisplayObject; 
      public class FlashVarUtil 
      { 
  
           public static function getValue(who:DisplayObject, key:String, doEscape:Boolean = true):String 
           { 
		   		if (!doEscape) return escape(who.loaderInfo.parameters[key]);
                return who.loaderInfo.parameters[key]; 
           } 
  
  
           public static function hasKey(who:DisplayObject, key:String):Boolean 
           { 
                return FlashVarUtil.getValue(who,key) ? true : false; 
           } 
     } 
} 