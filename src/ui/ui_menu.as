package ui
{
	import game.g_idrawable;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;

	/*========================================================================================
	BASE CLASS FOR MENU SYSTEMS
	========================================================================================*/
	public class ui_menu extends Sprite implements g_idrawable
	{
		/*===============
		PROTECTED
		===============*/
		/** parent for the menu */
		protected var m_parent				:DisplayObjectContainer;
		
		/** there is only ever a single instance of a menu */
		static protected var m_instance		:ui_menu;
		
		public function ui_menu( parent:DisplayObjectContainer ) {
			visible = false;
			m_parent = parent;
		}
		
		public function Init():void {
			
		}
		
		/** Creates an interactable button 
		 * @param asset - the name of the button asset to use
		 * @param isSpriteSheet - if the asset is a spritesheet, set to true and give the amount of frames
		 * @param bx - the button x location
		 * @param by - the button y location
		 * @param eventType - if you want the button to do something on event such as "click", "hover", "out"
		 * @param eventFunction - the eventFunction to call for the event type
		 * 
		 * <p>Note: You <u>must</u> pass an eventFunction if you set the eventType to something other than none</p>
		 * */
		public function AddButton( asset:String, isSpriteSheet:Boolean=false, frames:int=-1, bx:Number=0, by:Number=0, eventType:String="none", eventFunction:Function=null ):void {
			var button:ui_button = new ui_button( asset, isSpriteSheet, frames );
			button.x = bx;
			button.y = by;
			if ( eventType != "None" && eventFunction != null ) {
				eventType = eventType.substring(0,1).toUpperCase() + eventType.substring( 1 );
				button[ "on" + eventType ] = eventFunction;
			}
			addChild( button );
			button.Init();
			button.Draw();
		}
		
		public function Draw():void {
			if ( !m_parent.contains( this ) ) {
				m_parent.addChild( this );
			}
			visible = true;
		}
		
		public function Destroy():void {
			m_parent.removeChild( this );
		}
		
		public function Show():void {
			visible = true;
		}
		
		public function Hide():void {
			visible = false;
		}
		
		public function get instance():ui_menu { return m_instance; }
	}
}