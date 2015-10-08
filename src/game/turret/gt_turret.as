package game.turret
{
	import com.globals;
	
	import dragonBones.events.AnimationEvent;
	
	import game.g_dispatcher;
	import game.g_entity;
	
	import starling.display.DisplayObjectContainer;
	
	/** gt_turret */
	public class gt_turret extends g_entity {
		/*===============
		PRIVATE
		===============*/
		
		/*===============
		PROTECTED
		===============*/
		protected var m_health:int;
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		protected const START_HEALTH:int = 3;
		
		public function gt_turret(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false) {
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
		}
		
		/** Plays the death animation, then calls Destroy when that is finished */
		public function Death():void {
			g_dispatcher.instance.RemoveFromDispatch(Update);
			m_isDestroyed = true;
			
			m_armature.addEventListener(AnimationEvent.COMPLETE, function remove():void {
				m_armature.removeEventListener( AnimationEvent.COMPLETE, remove );
				m_asset.visible = false;
				Destroy();
			});
			if ( m_body ) {
				m_body.velocity.x = m_body.velocity.y = 0;
			}
			animation.gotoAndPlay( "death" );
		}
		
		public function HandleHit( damage:int=1 ):void {
			m_health -= damage;
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		public function set health( value:int ):void { m_health = value; }
		public function get health():int { return m_health; }
	}
}