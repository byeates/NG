package game
{
	import com.globals;
	
	import game.turret.gt_turretmelee;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	import starling.display.DisplayObjectContainer;
	
	/** g_coin */
	public class g_coin extends g_entity {
		/*===============
		PRIVATE
		===============*/
		
		/*===============
		PROTECTED
		===============*/
		protected var m_playerListener:InteractionListener;
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		static private const CB_COIN:CbType = new CbType();
		
		public function g_coin(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false)
		{
			super(parent, "coin", true, 21, false);
		}
		
		/** @inheritDoc */
		override public function SetDefaults():void {
			super.SetDefaults();
			CenterOrigin();
			m_collisionGroup = globals.GROUP_COIN;
			CreateBody();
		}
		
		/** @inheritDoc */
		override protected function CreateBody():void {
			m_body 					= new Body( BodyType.DYNAMIC, new Vec2( x,y ) );
			
			m_body.shapes.add( new Polygon(Polygon.rect(x,y,m_assetHalfWidth,m_assetHalfHeight), new Material(0, 0.55, 1, 1 ) ) );
			m_body.allowRotation 	= false;
			m_body.space			= globals.space;
			m_body.mass				= DEFAULT_MASS;
			m_body.shapes.at(0).filter.collisionGroup = m_collisionGroup;
			m_body.cbTypes.add( CB_COIN );
			
			m_body.shapes.at(0).filter.collisionMask = ~(globals.GROUP_MELEE|globals.GROUP_COIN|globals.GROUP_ENEMY_FAST);
		}
		
		override public function Destroy():void {
			globals.space.listeners.remove( m_playerListener );
			super.Destroy();
			m_body.shapes.clear();
		}
		
		/** @inheritDoc */
		override public function Init():void {
			super.Init();
			
			//PLAYER LISTENER
			m_playerListener = new InteractionListener( 
				CbEvent.BEGIN, 																			
				InteractionType.COLLISION, 																			
				globals.CB_PLAYER, 																
				CB_COIN, 																
				PlayerPickup );
			
			globals.space.listeners.add( m_playerListener );
			
			g_dispatcher.instance.AddToDispatch( Update );
		}
		
		/** @inheritDoc */
		override public function Draw():void {
			super.Draw();
			m_asset.gotoAndPlay( 1, 21 );
		}
		
		/** @inheritDoc */
		override public function Update( elapsedTime:Number=NaN ):void {
			x = m_body.position.x + m_assetHalfWidth/2;
			y = m_body.position.y + m_assetHalfHeight/2;
		}
		
		public function PlayerPickup( collision:InteractionCallback=null ):void {
			globals.player[ "AddCoin" ]();
			Destroy();
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		
	}
}