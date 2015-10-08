package game
{
	import com.globals;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import dragonBones.animation.Animation;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	import renderer.r_camera;
	
	import starling.display.DisplayObjectContainer;

	/*========================================================================================
	Entity Implementation from abstract entity
	========================================================================================*/
	public class g_entity extends g_abstractentity
	{	
		/*===============
		PROTECTED
		===============*/
		/** Collision body, can be instantiated in any entity */
		protected var m_body							:Body;
		
		/** this only gets set if we want to apply some properties after the entity is done loading
		 * and is generally an automated property */
		protected var m_onInitProperties				:Object;
		
		/** collision group for nape, default is globals.GROUP_COLLISION which is 2 */
		protected var m_collisionGroup					:int = globals.GROUP_COLLISION;
		
		protected var m_isDestroyed						:Boolean;
		
		/*===============
		CONSTANTS
		===============*/
		/** The default for any entity */
		protected const DEFAULT_MASS					:Number = 2.5;
		
		
		public function g_entity(
			parent				:DisplayObjectContainer,
			asset				:String, 
			isSpriteSheet		:Boolean = false, 
			defaultFrames		:int = 120, 
			isArmature			:Boolean = false ) {
			//////////////////////////////////
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
			//if this is not a dragon bones entity, call setdefaults() right away
			//otherwise we need to wait till the factory is finished loading
			if ( !isArmature ) { SetDefaults(); }
		}
		
		override public function SetDefaults():void {
			m_isDestroyed = false;
			isLoaded = true;
			addChild( m_asset );
			Init();
		}
		
		override public function Destroy():void { 
			if ( m_body ) { globals.space.bodies.remove( m_body ); }
			m_parent.removeChild( this );
			g_dispatcher.instance.RemoveFromDispatch( Update );
			m_isDestroyed = true;
		}
		
		protected function CreateBody():void {
			m_body 					= new Body( BodyType.DYNAMIC, new Vec2( x,y ) );
			
			m_body.shapes.add( new Polygon(Polygon.rect(x,y,m_asset.width,m_asset.height), new Material(0, 0.55, 1, 1 ) ) );
			m_body.allowRotation 	= false;
			m_body.space			= globals.space;
			m_body.mass				= DEFAULT_MASS;
			m_body.shapes.at(0).filter.collisionGroup = m_collisionGroup;
			m_body.cbTypes.add( globals.CB_ENTITY );
		}
		
		/** Pass any properties to apply to this object when it has loaded */
		protected function ApplyProperties( properties:Object ):void {
			if ( this.isLoaded ) {
				for ( var key:* in properties ) {
					this[ key ] = properties[ key ];
				}
			}
			else { m_onInitProperties = properties; }
		}
		
		/** Call this to add properties to be applied once the object is loaded */
		public function StoreProperties( properties:Object ):void {
			if ( !m_onInitProperties ) { m_onInitProperties = properties; }
			else {
				for ( var key:* in properties ) {
					m_onInitProperties[ key ] = properties[ key ];
				}
			}
		}
		
		/** Initliazer, currently it tries to set any properties that we attempted to access
		 * before the asset was finished loading. (that really only happens with dragon bones assets)
		 * */
		override public function Init():void {
			if ( m_onInitProperties ) {
				ApplyProperties( m_onInitProperties );
			}
			m_isDestroyed = false;
			SetPosition( x, y );
		}
		
		/** @inheritDoc */
		override public function Draw():void { 
			if (!m_parent.contains(this) ) { 
				m_parent.addChild( this ); 
			} 
			visible = true;
		}
		
		/** @inheritDoc */
		override public function Update( elapsedTime:Number=NaN ):void {}
		
		/** @inheritDoc */
		override public function SetPosition(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
			if ( m_body ) {
				m_body.position.x = x;
				m_body.position.y = y;
			}
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		
		public function get animation():Animation { return m_armature.animation; }
		public function get asset():* { return m_asset; }
		public function get body():Body { return m_body; }
		public function get isDestroyed():Boolean { return m_isDestroyed; }
		public function get collisionGroup():int { return m_collisionGroup; }
		
		override public function get bounds():Rectangle { return m_asset ? m_asset.getBounds( stage ) : null; }
	}
}