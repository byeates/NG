package game.enemy
{
	import com.bs_internal;
	import com.globals;
	
	import dragonBones.events.AnimationEvent;
	
	import game.g_coinmanager;
	import game.g_dispatcher;
	import game.g_entity;
	import game.turret.gt_turretbomb;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import starling.display.DisplayObjectContainer;
	
	use namespace bs_internal;
	
	/*========================================================================================
	Base class for all enemies
	========================================================================================*/
	public class ge_enemy extends g_entity
	{
		/*===============
		PROTECTED
		===============*/
		/** health that decrements for unique collisions, leading to removal */
		protected var m_health						:int;
		
		/** type of enemy created */
		protected var m_type						:String;
		protected var m_moveState					:String;
		protected var m_hitDamage					:int;
		
		/*===============
		STATICS
		===============*/
		/** this function should be set to the RemoveEnemy from the enemy manger */
		static protected var m_onDestroyedCallback	:Function;
		static protected var m_floorListener		:InteractionListener;
		static protected var m_wallListener			:InteractionListener;
		static protected var m_playerListener		:InteractionListener;
		static protected var m_playerEndListener	:InteractionListener;
		
		/*===============
		CONSTANTS
		===============*/
		static protected const MASS					:int = 10;
		static public const TYPES					:Array = [ "fast" ];		
		
		public function ge_enemy(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false) {
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
		}
		
		/** @inheritDoc */
		override public function SetDefaults():void {
			super.SetDefaults();
			CenterOrigin();
			m_hitDamage = 1;
		}
		
		override public function Init():void {
			super.Init();
		}
		
		public function Reset():void {
			Init();
			//CreateBody();
			m_asset.visible = true;
			Draw();
		}
		
		/** @inheritDoc */
		override public function Destroy():void {
			m_onDestroyedCallback( this );
			super.Destroy();
		}
		
		public function Remove():void {
			m_onDestroyedCallback( this );
			m_parent.removeChild( this );
			g_dispatcher.instance.RemoveFromDispatch( Update );
			m_isDestroyed = true;
		}
		
		override public function Update(elapsedTime:Number=NaN):void {}
		
		/** @inheritDoc */
		override public function Draw():void {
			super.Draw();
			g_dispatcher.instance.AddToDispatch( Update );
		}
		
		/*========================================================================================
		EVENT HANDLING
		========================================================================================*/
		/** handles hits from turrets, projectiles, etc */
		public function HandleHit( damage:int=1 ):void {
			if ( m_health <= 0 ) { return; }
			m_health -= damage;
			CheckDeath();
			globals.echo( "HIT!" );
		}
		
		public function HandleBombCollision():void {
			if ( m_health <= 0 ) { return; }
			m_health -= gt_turretbomb.damage;
			CheckDeath();
		}
		
		protected function CheckDeath():void {
			if ( m_health <= 0 && m_moveState != globals.NONE ) {
				Death();
				m_speed = 0;
			}
		}
		
		/** Plays the death animation, then calls Destroy when that is finished */
		public function Death():void {
			g_dispatcher.instance.RemoveFromDispatch(Update);
			m_moveState = globals.NONE;
			
			m_armature.addEventListener(AnimationEvent.COMPLETE, function remove():void {
				m_armature.removeEventListener( AnimationEvent.COMPLETE, remove );
				m_asset.visible = false;
				g_coinmanager.instance.AddCoin( x, y );
				Remove();
				
			});
			if ( m_body ) {
				m_body.velocity.x = m_body.velocity.y = 0;
			}
			animation.gotoAndPlay( "death" );
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		/** function to call after destroy() */
		public function set onDestroyedCallback( f:Function ):void { m_onDestroyedCallback = f; }
		
		/** the amount of damage this enemy does on collision */
		public function get hitDamage():int { return m_hitDamage; }
		
		/** returns the type of enemy */
		public function get type():String { return m_type; }
		
		public function get health():int { return m_health; }
		public function set health(value:int):void { m_health = value; }
	}
}