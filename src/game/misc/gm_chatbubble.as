package game.misc
{
	import com.assets;
	import com.greensock.TweenMax;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import game.g_dispatcher;
	import game.g_idrawable;
	
	import renderer.r_spriteclip;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/** gm_chatbubble */
	public class gm_chatbubble extends Sprite implements g_idrawable {
		/*===============
		PRIVATE
		===============*/
		static private var sm_instance:gm_chatbubble;
		
		/*===============
		PROTECTED
		===============*/
		protected var m_text:String;
		protected var m_bubblepointer:Image;
		protected var m_chatbubble_drawer:flash.display.Sprite;
		protected var m_chatbubble:Sprite;
		protected var m_parent:Sprite;
		/** the target to place the chat bubble above */
		protected var m_target:Sprite;
		protected var m_textField:TextField;
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		
		/** Creates a new chat bubble at the target, this positions accordingly so the bubble appears at the target.y - this.height */
		public function gm_chatbubble( parent:Sprite, target:Sprite, text:String="" ) {
			if ( sm_instance ) { throw new Error( "Already created a chat bubble, use the static public instance property instead." ); }
			assets.RegisterBitmapFont( "consolas" );
			m_bubblepointer = new Image( assets.GetTexture( "chatbubble_pointer" ) );
			addChild( m_bubblepointer );
			
			m_parent 	= parent;
			m_text 		= text;
			visible 	= false;
			this.alpha	= 0;
			m_target 	= target;
			x 			= m_target.x - m_bubblepointer.width/2;
			y 			= m_target.y - m_bubblepointer.height;
			
			m_chatbubble_drawer = new flash.display.Sprite();
			m_chatbubble_drawer.graphics.beginFill(0x0F7C94);
			m_chatbubble_drawer.graphics.drawRoundRect(0,0,300,50,5,5);
			m_chatbubble_drawer.graphics.endFill();

			var bmd:BitmapData = new BitmapData( m_chatbubble_drawer.width, m_chatbubble_drawer.height, true, 0 );
			bmd.draw( m_chatbubble_drawer );
			
			var bubbleImage:Image = new Image( Texture.fromBitmapData( bmd ) );
			m_chatbubble = new Sprite();
			addChild( m_chatbubble );
			m_chatbubble.addChild( bubbleImage );
			
			m_chatbubble.x = -m_chatbubble_drawer.width/1.25 + m_bubblepointer.width;
			m_chatbubble.y = -m_chatbubble_drawer.height+2; //+2 for subpixel cracking
			UpdateTextField();
			
			Draw();
			Init();
			
			sm_instance = this;
		}
		
		public function SetText( value:String ):void {
			m_text = value;
			UpdateTextField();
		}
		
		public function Draw():void {
			if ( !m_parent.contains( this ) ) {
				m_parent.addChild( this );
			}
			visible = true;
		}
		
		public function Destroy():void {
			if ( parent.contains( this ) ) {
				parent.removeChild( this );
			}
			g_dispatcher.instance.RemoveFromDispatch( Update );
		}
		
		public function Init():void {
			g_dispatcher.instance.AddToDispatch( Update );
		}
		
		public function Update( elapsedTime:Number ):void {
			x = m_target.x - m_bubblepointer.width;
			y = m_target.y - m_target[ "halfHeight" ] - m_bubblepointer.height;
		}
		
		protected function UpdateTextField():void {
			if ( m_chatbubble.contains( m_textField ) ) {
				m_chatbubble.removeChild( m_textField );
			}
			m_textField		= new TextField(400, 100, m_text, "Consolass", 20, 0x000000);
			m_textField.x 	= m_chatbubble.width/2 - m_textField.width/2;
			m_textField.y 	= m_chatbubble.height/2 - m_textField.height/2;
			m_chatbubble.addChild(m_textField);
		}
		
		public function Close(fadeTime:Number=0.5, delay:Number=0):void {
			TweenMax.to( this, fadeTime, {delay: delay, alpha:0} );
		}
		
		public function Open(fadeTime:Number=0.5, delay:Number=0):void {
			TweenMax.to( this, fadeTime, {delay:delay, alpha:1} );
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		static public function get instance():gm_chatbubble { return sm_instance; }
	}
}