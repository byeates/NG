package game
{
	import com.assets;
	import com.globals;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.Point;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import renderer.r_spriteclip;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/*========================================================================================
	Entity Abstract Super
	========================================================================================*/
	public class g_abstractentity extends Sprite implements g_idrawable
	{	
		/*===============
		PROTECTED			
		===============*/
		/** asset can be an image, or a sprite, asset is attached to the class */
		protected var m_asset				:*;
		protected var m_assetName			:String;
		protected var m_assetHalfWidth		:Number;
		protected var m_assetHalfHeight		:Number;
		protected var m_parent				:DisplayObjectContainer;
		protected var m_velocity			:Vector2D;
		protected var m_direction			:Vector2D;
		protected var m_isDrawn				:Boolean;
		protected var m_isCenterOrigin		:Boolean;
		
		/** Factory only created for armature types */
		protected var m_factory				:StarlingFactory;
		/** Armature needed for dragon bones assets */
		protected var m_armature			:Armature;
		
		/** Speed is used in conjunction with velocity and elapsed time to stabilize variability in frame rates 
		 *  i.e. - Update() will calculate velocity = speed * elapsedTime since last frame udpate */
		protected var m_speed				:Number = 300;
		
		/** Damping will act as resistance */
		protected var m_damping				:Number;
		
		/*===============
		PUBLIC			
		===============*/
		/** isLoaded is set to true once we have passed SetDefaults and have an asset loaded */
		public var isLoaded					:Boolean;
		
		/** All drawables should have a parent and asset to load, 
		 * if it's a sprite sheet set how many frames for the animations,
		 * if it's an Armature (dragon bones formatted png), then the data should be in with the single image
		 * @param parent - the parent for the entity
		 * @param asset - the asset associated with the entity
		 * @param isSpriteSheet - set to true if the asset needs to be a spritesheet
		 * @param defaultFrames - the frames to cycle for the spritesheet animation
		 * @param isArmature - set to true if the asset is from dragon bones
		 * */
		public function g_abstractentity(
			parent				:DisplayObjectContainer, 					
			asset				:String, 							
			isSpriteSheet		:Boolean = false, 					
			defaultFrames		:int = 120, 
			isArmature			:Boolean = false ) {
			//////////////////////////////////
			m_parent = parent;
			m_assetName = asset;
			//either we are loading a static asset, a sprite sheet, or dragon bones texture
			if ( !isArmature ) 	{ 
				m_asset = !isSpriteSheet ? new Image( assets.GetTexture( asset ) ) : new r_spriteclip( assets.GetSpriteSheet( asset ).getTextures(), defaultFrames ); 
				m_assetHalfWidth = m_asset.width * 0.5;
				m_assetHalfHeight = m_asset.height * 0.5;
			} 
			else {
				m_factory = new StarlingFactory;
				m_factory.addEventListener( Event.COMPLETE, OnFactoryComplete );
				m_factory.parseData( assets.GetNewInstance( asset ) );
			}
			
			m_velocity = new Vector2D( 0, 0 );
			m_direction = new Vector2D( 0, 0 );
			m_damping = 1;
			m_speed	= 0;
		}
		
		/** Called once factory parseData() has complete */
		protected function OnFactoryComplete( e:Event ):void {
			m_factory.removeEventListener( Event.COMPLETE, OnFactoryComplete );
			m_armature = m_factory.buildArmature( m_assetName );
			m_asset = m_armature.display as Sprite;
			WorldClock.clock.add( m_armature );
			
			m_assetHalfWidth = m_asset.width * 0.5;
			m_assetHalfHeight = m_asset.height * 0.5;
			SetDefaults();
		}
		
		/** Set default values, then Init */
		public function SetDefaults():void { AbstractError(); }
		
		/** Init function to call */
		public function Init():void { AbstractError(); }
		
		/** Set the origin point to the center instead of top left */
		protected function CenterOrigin():void {
			m_asset.pivotX = m_assetHalfWidth;
			m_asset.pivotY = m_assetHalfHeight;
			m_isCenterOrigin = true;
		}
		
		/** Centers on the parent */
		protected function Center():void {
			x = m_parent.width * 0.5 - (width * 0.5 - m_asset.pivotX);
			y = m_parent.height * 0.5 - (height * 0.5 - m_asset.pivotY);
		}
		
		/** Centers on the stage */
		protected function AbsoluteCenter():void {
			x = globals.stageHalfWidth - (width * 0.5 - m_asset.pivotX);
			y = globals.stageHalfHeight - (height * 0.5 - m_asset.pivotY);
		}
		
		/** Set the position of the entity and its body if there is one */
		public function SetPosition( x:Number, y:Number ):void { AbstractError(); }
		
		/** Basic programmatic translation using tween */
		public function MoveTo( location:Point, timeInSeconds:int=1, center:Boolean=true ):void {
			location.x -= center ? m_assetHalfWidth : 0;
			location.y -= center ? m_assetHalfHeight : 0;
			
			var tween:Tween = new Tween( this, timeInSeconds );
			tween.animate( "x", location.x );
			tween.animate( "y", location.y );
			Starling.juggler.add( tween );
		}
		
		/** Update function - translations based on time, (i.e. - drawable.x += velocity.x * elapsedTime) */
		public function Update( elapsedTime:Number=NaN ):void { AbstractError(); }
		
		/** Remove from parent, nullify, garbage collection prep */
		public function Destroy():void { AbstractError(); }
		
		/** Draw function, add asset to class, class instance is added to parent */
		public function Draw():void { AbstractError();  }
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		/** returns true if asset origin is at the assets center instead of top left (0,0) */
		public function get isCenterOrigin():Boolean { return m_isCenterOrigin; }
		
		/** returns the assets half width */
		public function get halfWidth():Number { return m_assetHalfWidth; }
		
		/** returns the assets half height */
		public function get halfHeight():Number { return m_assetHalfHeight; }
		
		/** returns the elapsed time since the last frame */
		protected function get elapsedTime():Number { return g_state.instance.elapsedTime; }
		
		override public function set scaleX(value:Number):void {
			m_asset.scaleX = value;
			m_direction.x = value > 0 ? 1 : -1;
		}
		
		override public function set scaleY(value:Number):void {
			m_asset.scaleY = value;
			m_direction.y = value > 0  ? 1 : -1;
		}
		
		override public function get scaleX():Number { return m_asset.scaleX; }
		override public function get scaleY():Number { return m_asset.scaleY; }
		
		public function set direction( dir:Vector2D ):void { m_direction = dir; }
		public function get direction():Vector2D { return m_direction; }
		public function get position():Point { return new Point( x, y ); }
		
		private function AbstractError():void {
			var stack:Error = new Error();
			var log:String = stack.getStackTrace();
			var f:String = log.replace( /.*\/([a-zA-Z0-9_]+)\(\).*/, "$1()" );
			throw new IllegalOperationError( f + " must be overriden in subclass" );
		}
	}
}