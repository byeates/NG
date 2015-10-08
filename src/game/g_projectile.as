package game
{
	import com.math;
	
	import flash.geom.Rectangle;
	
	
	import nape.callbacks.CbType;
	
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	
	public class g_projectile extends g_entity
	{
		/*===============
		PROTECTED			
		===============*/
		/** when target is set, projectile is always chasing the target until collision */
		protected var m_target					:g_idrawable;
		
		/** set to true when projectile is live and receives updates */
		protected var m_enabled					:Boolean;
		
		/** this boolean, set true by default, keeps the projectile locked on to it's targets 
		 * <p>when set to false, this will force the projectile to only travel in the entities initial calculated direction</p>
		 * */
		protected var m_lockTarget				:Boolean;
		
		protected var m_targetAngle				:Number;
		
		/** function to call after collision occurs */
		protected var m_collisionCallback		:Function;
		
		/** static rectangle instances used with collision testing */
		static protected var PROJECTILE_RECT	:Rectangle = new Rectangle();
		static protected var TARGET_RECT		:Rectangle = new Rectangle();
		
		/*===============
		CONSTANTS			
		===============*/
		protected const DEFAULT_SPEED			:int = 250;
		
		public function g_projectile(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false) {
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
			m_speed = DEFAULT_SPEED;
			m_targetAngle = Infinity;
		}
		
		override public function SetDefaults():void {
			super.SetDefaults();
			CenterOrigin();
		}
		
		override public function Update( elapsedTime:Number=NaN ):void {
			if ( m_target && m_enabled && !m_target[ "isDestroyed" ] ) {
				if ( m_lockTarget || m_targetAngle == Infinity ) {
					m_targetAngle = Math.atan2( m_target[ "y" ] - y, m_target[ "x" ] - x );
					m_velocity.x = m_speed * Math.cos( m_targetAngle ) * (elapsedTime*.001);
					m_velocity.y = m_speed * Math.sin( m_targetAngle ) * (elapsedTime*.001);
				}
					
				x += m_velocity.x;
				y += m_velocity.y;
				
				m_asset.rotation = m_targetAngle + math.pi;
				
				PROJECTILE_RECT = new Rectangle( x, y, 15, 15 );
				m_target[ "asset"][ "getBounds" ]( m_parent, TARGET_RECT );
				
				//COLLISION CALLBACK MUST BE SET!
				if ( PROJECTILE_RECT.intersects( TARGET_RECT ) && m_enabled ) {
					m_enabled = false;
					m_target[ "HandleHit" ]();
					m_asset.gotoAndPlay(10,18,Clear);
				}
			}
			if ( x < -m_asset.width || x > g_level.instance.levelWidth + m_asset.width ) {
				Clear();
			}
			else if ( y < m_asset.width || y > g_level.instance.levelHeight + m_asset.height ) {
				Clear();
			}
		}
		
		public function Clear():void {
			m_collisionCallback( this );
			m_asset.remove();
		}
		
		public function SetTarget( target:g_idrawable, lock:Boolean=true ):void {
			m_target = target;
			m_lockTarget = lock;
			m_targetAngle = Infinity;
		}
		
		override public function Draw():void {
			super.Draw();
			m_asset.gotoAndPlay(1,9);
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		/** function to be called after a collision occurs */
		public function set onCollisionCallback( f:Function ):void { m_collisionCallback = f; }
		
		public function get enabled():Boolean 				{ return m_enabled; }
		public function get speed():int 					{ return m_speed; }
		
		/** enabling sets the projectile instance to receives updates */
		public function set enabled( value:Boolean ):void 	{ 
			m_enabled = value; 
			if ( enabled ) { 
				g_dispatcher.instance.AddToDispatch( Update );
				Draw();
			} else {
				g_dispatcher.instance.RemoveFromDispatch( Update );
				visible = false;
				m_target = null;
			}
		}
		public function set speed( value:int ):void 		{ m_speed = value; }
	}
}