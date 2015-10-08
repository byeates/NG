package renderer
{
	import com.globals;
	
	import flash.geom.Point;
	
	import game.g_level;
	
	import nape.phys.Body;
	
	import starling.display.DisplayObject;

	/*=============================================================================
	camera class for the body and puzzle section
	=============================================================================*/
	public class r_camera
	{
		protected var m_x			:Number;
		protected var m_y			:Number;
		protected var m_width		:Number;
		protected var m_height		:Number;
		protected var m_target		:DisplayObject;
		
		/** cameras should have the world instance */
		protected var m_world		:r_world
		
		/** nape viewport for only updating bodies inside the view port rectangle */
		protected var m_viewport	:Body;
		
		/** singleton */
		static private var sm_instance:r_camera;
		
		public function r_camera( world:r_world ) {
			if ( sm_instance ) { throw new Error( "Camera instance already created, use instance property" ); }
			sm_instance = this;
			m_width 	= globals.stageWidth;
			m_height 	= globals.stageHeight;
			m_world 	= world;
		}
		
		public function Update():void {
			if ( m_target ) {
				x = globals.stageHalfWidth - m_target.x;
				y = globals.stageHalfHeight - m_target.y;
			}
		}
		
		public function SetTarget( target:DisplayObject ):void {
			m_target = target;
		}
		
		/*=============================================================================
		ANCILLARY
		=============================================================================*/
		public function get x():Number { return m_x; }
		public function get y():Number { return m_y; }
		public function get width():Number { return m_width; }
		public function get height():Number { return m_height; }
		
		public function set x( value:Number ):void {
			//only move the camera if theres an area to move to, ie. the level has to be larger than the view region
			if ( value < 0 && value <= -g_level.instance.levelWidth + m_width ) { value = -g_level.instance.levelWidth+m_width }
			else if ( value > 0 ) { value = 0; }
			
			m_x = value;
			m_world.x = value;
		}
		
		public function set y( value:Number ):void {
			if ( value < 0 && -value + m_height >= g_level.instance.levelHeight ) { return; }
			else if ( value > 0 ) { value = 0; }
			
			m_y = value;
			m_world.y = value;
		}
		
		static public function get instance():r_camera { return sm_instance; }
	}
}