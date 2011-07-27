package ${TM_CLASS_PATH}
{
	import flash.events.Event;
	
	/**
	 * 
	 * @author 	${TM_FULLNAME}
	 * @site	www.lazylady.se
	 * @since	${TM_DATE}
	 * @version	1.0
	 */
	public class ${TM_NEW_FILE_BASENAME} extends Event
	{
		public static const EVENT_NAME:String = "customEvent";
	
		public function ${TM_NEW_FILE_BASENAME}(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public override function clone():Event
		{
			return new ${TM_NEW_FILE_BASENAME}(type, bubbles, cancelable);
		}
	}

}
