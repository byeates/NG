package renderer
{
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	
	public class r_spriteclip extends MovieClip
	{
		protected var m_endFrame:int;
		protected var m_startFrame:int;
		protected var m_playHeadState:String;
		protected var m_onAnimationEnd:Function;
		
		protected const PLAYING:String = "playing";
		protected const STOPPED:String = "stopped";
		
		public function r_spriteclip(textures:__AS3__.vec.Vector.<starling.textures.Texture>, fps:Number=12)
		{
			super(textures, fps);
			m_endFrame = -1;
			m_playHeadState = STOPPED;
		}
		
		public function checkFrame():void {
			if ( m_endFrame >= 1 ) {
				if ( currentFrame < m_endFrame ) {
					return;
				} else {
					if ( m_onAnimationEnd ) { 
						m_onAnimationEnd(); 
					}
					currentFrame = m_startFrame;
				}
			}
		}
		
		public function remove():void {
			Starling.juggler.remove( this );
			visible = false;
		}
		
		/** @param onAnimationEnd - function to call when end frame is reached */
		public function gotoAndPlay( startFrame:int, endFrame:int, onAnimationEnd:Function=null ):void {
			visible = true;
			m_onAnimationEnd = onAnimationEnd;
			currentFrame = startFrame;
			m_startFrame = startFrame;
			m_endFrame = endFrame;
			if ( Starling.juggler.contains( this ) ) {
				Starling.juggler.remove( this );
			}
			Starling.juggler.add( this );
			m_playHeadState = PLAYING;
		}
		
		public function gotoAndStop( frame:int ):void {
			visible = true;
			if ( Starling.juggler.contains( this ) ) {
				Starling.juggler.remove( this );
			}
			currentFrame = frame;
			m_playHeadState = STOPPED;
		}
	}
}