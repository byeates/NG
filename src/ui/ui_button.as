package ui
{
	import com.assets;
	import com.globals;
	
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import game.g_dispatcher;
	
	import renderer.r_spriteclip;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	
	/** ui_button */
	public class ui_button extends Sprite {
		/*===============
		PRIVATE
		===============*/
		/** current phase for the touch events */
		private var m_phaseState:String;
		private var m_bounds:Rectangle;
		
		/*===============
		PROTECTED
		===============*/
		protected var m_asset:DisplayObject;
		
		/*===============
		PUBLIC
		===============*/
		/** Function to run when mouse is over button */
		public var onHover:Function;
		
		/** Function to run when mouse leaves the button */
		public var onOut:Function;
		
		/** Function to run when mouse click is regestered */
		public var onClick:Function;
		
		/*===============
		CONSTANTS
		===============*/
		private const HOVER:String = "hover";
		private const NONE:String = "none";
		
		/** Creates a new button 
		 * @param asset - name of the asset to load
		 * @param isSpriteSheet - set to false by default
		 * @param defaultFrames - only set the amount of frames if the asset is a spritesheet
		 */
		public function ui_button( asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=-1 ) {
			m_asset = !isSpriteSheet ? new Image( assets.GetTexture( asset ) ) : new r_spriteclip( assets.GetSpriteSheet( asset ).getTextures(), defaultFrames );
			visible = false;
			m_asset.pivotX = m_asset.width/2;
			m_asset.pivotY = m_asset.height/2;
		}
		
		public function Init():void {
			g_dispatcher.instance.AddToDispatch( Hover, null, "touch", TouchPhase.HOVER );
			g_dispatcher.instance.AddToDispatch( Click, null, "touch", TouchPhase.ENDED );
			g_dispatcher.instance.AddToDispatch( Out, null, "touch", TouchPhase.MOVED );
			//g_dispatcher.instance.AddToDispatch( Ended, null, "touch", TouchPhase.HOVER );
		}
		
		public function Draw():void {
			if ( !contains( m_asset ) ) { 
				addChild( m_asset );
			}
			visible = true;
		}
		
		public function Destroy():void {
			removeChild( m_asset );
			this.parent.removeChild( this );
			
			g_dispatcher.instance.RemoveFromDispatch( Hover );
			g_dispatcher.instance.RemoveFromDispatch( Click );
			g_dispatcher.instance.RemoveFromDispatch( Out );
		}
		
		private function Hover( touch:Touch ):void {
			var pos:Point = touch.getLocation( this.parent );
			
			if ( HitTestPoint( pos ) ) {
				if ( onHover != null ) { onHover(); }
				m_phaseState = HOVER;
			}
		}
		
		private function Click( touch:Touch ):void {
			var pos:Point = touch.getLocation( this.parent );
			
			if ( HitTestPoint( pos ) ) {
				if ( onClick != null ) { onClick(); }
			}
		}
		
		private function Out( touch:Touch ):void {
			if ( m_phaseState != HOVER ) { return; }
			
			var pos:Point = touch.getLocation( this.parent );
			if ( HitTestPoint( pos ) ) {
				if ( onOut != null ) { onOut(); }
				m_phaseState = NONE;
			}
		}
		
		private function HitTestPoint( pos:Point ):Boolean {
			if ( pos.x >= m_bounds.left && pos.x <= m_bounds.right ) {
				if ( pos.y >= m_bounds.top && pos.y <= m_bounds.bottom ) {
					return true;
				}
			}
			return false;
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		private function SetBounds():void {
			m_bounds = new Rectangle( x - m_asset.pivotX, y - m_asset.pivotY, m_asset.width, m_asset.height );
		}
		
		override public function set x(value:Number):void {
			super.x = value;
			SetBounds();
		}
		
		override public function set y(value:Number):void {
			super.y = value;
			SetBounds();
		}
	}
}