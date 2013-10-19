package com.bitsushi.utils
{
	import flash.net.*;
	import flash.text.*;
	
  public class Helpers
  {
    public function Helpers()
    {
    }
    
    /**
     * Will return either True or False with
     * 50/50 probability
     */    
    public static function coinToss():Boolean
    {
      return Math.random() >= 0.5 ? true : false;
    }
	
	// returning -1 if the first date is before the second, 0 if the dates are equal, or 1 if the first date is after the second:
	public static function compareDates (date1 : *, date2 : * = null) : int
	{
		var date1Timestamp : Number;
		var date2Timestamp : Number;
		
		if (date1 is Date) date1Timestamp = date1.getTime();
		else date1Timestamp = Date.parse(date1);
		
		if (date2 == null) {
			date2 = new Date();
		}
		
		if (date2 is Date) date2Timestamp = date2.getTime();
		else date2Timestamp = Date.parse(date2);
		
		trace( date1Timestamp + ' ' + date2Timestamp);

		var result : Number = -1;

		if (date1Timestamp == date2Timestamp)
		{
			//trace('date is equal');
			result = 0;
		}
		else if (date1Timestamp > date2Timestamp)
		{
			//trace('first date is greater');
			result = 1;
		} else {
			//trace('first date is lower');
		}

		return result;
	}

	public static function objectToURLVars(parameters:Object):URLVariables {
		var paramsToSend:URLVariables = new URLVariables();
		for(var i:String in parameters) {
			if(i!=null) {
				if(parameters[i] is Array) paramsToSend[i] = parameters[i];
				else paramsToSend[i] = parameters[i].toString();
			}
		}
		return paramsToSend;
	}
	
	public static function openURL($url:String,$parameters:Object=null,$o:Object=null):void
	{
		var url:URLRequest = new URLRequest($url);
		var str:String;
		if ($parameters != null) {
			var uv:URLVariables = Helpers.objectToURLVars($parameters);
			//url.method = o.method ? o.method : "GET";
			
			if ($o != null) {
				if ($o.hasOwnProperty('method')) url.method = $o.method;
				else url.method = 'GET';
			}
			
			url.data = uv;
		}
		var target:String = '_self';//$o.target ? $o.target : '_self';
		
		if (url.method == 'GET') navigateToURL(url, target);
	  
	}
	
	public static function substitute(t:TextField,o:Object):void
		{
			// take the initial textfield that contains {{variable}}
			var str:String = t.text;
			var replace:RegExp = /{{(\w+)}}/ig;
			var result:Object = replace.exec(str);
			while (result != null) {
				// loop through each {{variable}} and replace with object parameter
				t.text = t.text.replace(result[0],o[result[1]]);
				result = replace.exec(str);
			}
		}
	
  }
}