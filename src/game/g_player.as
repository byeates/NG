package game
{
	import com.globals;
	
	import flash.utils.getTimer;
	
	import dragonBones.Armature;
	
	import game.enemy.ge_enemy;
	import game.turret.gt_turretmanager;
	import game.turret.gt_turretranged;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	import renderer.r_camera;
	
	import starling.display.DisplayObjectContainer;
	
	import ui.ui_turretmenu;
	
	/*========================================================================================
	Player entity
	========================================================================================*/
	public class g_player extends g_entity
	{	
		/*===============
		PROTECTED			
		===============*/
		protected var m_state				:g_playerstate;
		protected var m_turretMenu			:ui_turretmenu;
		protected var m_turrets				:Vector.<gt_turretranged>;
		/** the current currency count */
		protected var m_coins				:int;
		/** the current active turret to repair, if possible */
		protected var m_repairTurret		:int;
		protected var m_repairTime			:int;
		
		//collision listeners
		protected var m_floorListener		:InteractionListener;
		protected var m_wallListener		:InteractionListener;
		protected var m_wallBreakListener	:InteractionListener;
		
		/*===============
		PRIVATE	
		===============*/
		/** Function to call if passed through constructor, when asset is finished loading */
		private var m_onLoadedCallback		:Function;
		private var m_health				:int;
		
		/*===============
		CONSTANTS			
		===============*/
		protected const SPEED				:Number = 3;
		protected const MAX_SPEED			:int 	= 400;
		protected const WALL_KICK_SPEED		:int 	= 400;
		protected const SLIDE_SPEED			:int	= 150;
		protected const JUMP_HEIGHT			:int	= -500;
		protected const WALL_JUMP_HEIGHT	:int	= -450;
		protected const MASS				:Number = 2.3;
		protected const GRAV_MASS			:Number = 1.2;
		protected const REPAIR_DELAY		:uint 	= 1700;
		
		/** this is the speed the player slides down a wall */
		protected const WALL_SPEED			:Number = 0.015;
		
		public function g_player(
			parent				:DisplayObjectContainer, 
			asset				:String, 
			isSpriteSheet		:Boolean = false, 
			defaultFrames		:int = 120,
			isArmature			:Boolean = false,
			onCompleteCallback	:Function = null ) {
			//////////////////////////////////
			m_onLoadedCallback = onCompleteCallback;
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
		}
		
		/** @inheritDoc */
		override public function SetDefaults():void {
			m_state 				= new g_playerstate( this );
			m_turretMenu 			= new ui_turretmenu( this );
			m_turrets				= new Vector.<gt_turretranged>;
			m_speed 				= 0;		
			m_health 				= 1000;
			m_collisionGroup		= globals.GROUP_PLAYER;
			globals.player 			= this;
			m_repairTurret			= -1;
			
			CreateBody();
			
			addChild( m_turretMenu );
			super.SetDefaults();
			
			CenterOrigin();
			if ( m_onLoadedCallback ) { m_onLoadedCallback(); }
			
			m_turretMenu.x 		= -m_assetHalfWidth;
			m_turretMenu.y 		= -m_asset.height;
		}
		
		public function Reset():void {
			CreateBody();
			animation.gotoAndPlay("idle");
		}
		
		override protected function CreateBody():void {
			m_body 					= new Body( BodyType.DYNAMIC, new Vec2( x,y ) );
			
			m_body.shapes.add( new Polygon(Polygon.rect(x+10,y+10,m_asset.width-10,m_asset.height-10), new Material(0, 0.55, 1, 1 ) ) );
			m_body.allowRotation 	= false;
			m_body.space			= globals.space;
			m_body.mass				= MASS;
			m_body.gravMass			= GRAV_MASS;
			m_body.shapes.at(0).filter.collisionGroup = m_collisionGroup;
			
			m_body.cbTypes.add( globals.CB_PLAYER );
		}
		
		/** @inheritDoc */
		override public function Init():void {
			m_state.Init();
			
			//FLOOR LISTENER
			m_floorListener = new InteractionListener( 
				CbEvent.BEGIN, 																			
				InteractionType.COLLISION, 																			
				globals.CB_FLOOR, 																
				globals.CB_PLAYER, 																
				m_state.HandleFloorCollision );
			
			//WALL HIT LISTENER
			m_wallListener = new InteractionListener( 
				CbEvent.BEGIN, 
				InteractionType.COLLISION, 
				globals.CB_WALL, 
				globals.CB_PLAYER, 
				m_state.HandleWallCollision );
			
			//WALL SEPARATION LISTENER
			m_wallBreakListener = new InteractionListener( 
				CbEvent.END, 
				InteractionType.COLLISION, 
				globals.CB_WALL, 
				globals.CB_PLAYER, 
				m_state.HandleWallBreak );
			
			globals.space.listeners.add( m_floorListener );
			globals.space.listeners.add( m_wallListener );
			globals.space.listeners.add( m_wallBreakListener );
		}
		
		/** @inheritDoc */
		override public function Update( elapsedTime:Number=NaN ):void {
			x 					= m_body.position.x + m_assetHalfWidth;
			y 					= m_body.position.y + m_assetHalfHeight;
			m_asset.rotation 	= m_body.rotation;
			CheckTurretRepairs();
		}
		
		protected function CheckTurretRepairs():void {
			var i:int;
			var activeTurrets:int = gt_turretmanager.instance.turrets.length;
			var dx:Number = 0;
			var thisPos:Vector2D = new Vector2D( x, y );
			
			m_repairTurret = -1;
			for ( ; i < activeTurrets; ++i ) {
				dx = Vector2D.Distance( thisPos, new Vector2D( gt_turretmanager.instance.turrets[i].x, gt_turretmanager.instance.turrets[i].y ) );
				
				//TODO: replace 100 with user settings value, add variable m_repairDistance
				if ( dx <= 100 ) {
					m_repairTurret = i 
				}
			}
			if ( m_repairTurret >= 0 ) {
				RepairTurret();
			}
		}
		
		/** Move in +/- x direction 
		 * @param direction - pass either -1, 1, 0
		 * */
		public function Move( direction:int, elapsedTime:Number ):void {
			m_body.velocity.x += SPEED * direction * elapsedTime;
			
			if ( Math.abs(m_body.velocity.x) >= MAX_SPEED ) {
				m_body.velocity.x = MAX_SPEED * direction;
			}
			scaleX = direction;
		}
		
		/** Basic standard jump */
		public function Jump():void {
			m_body.velocity.y = JUMP_HEIGHT;
		}
		
		/** Jump from a wall in a specified direction 
		 * @param direction - either -1 or 1
		 * */
		public function WallJump( direction:int ):void {
			m_body.velocity.y = WALL_JUMP_HEIGHT;
			m_body.velocity.x = WALL_KICK_SPEED * direction;
			scaleX = direction;
		}
		
		/** Whenever a player attaches to a wall, call this function */
		public function AttachedToWall():void {
			m_body.velocity.y = 0;
			m_body.gravMass = WALL_SPEED;
		}
		
		/** Whenever a player detaches to a wall, call this function */
		public function DetachedFromWall():void {
			m_body.gravMass = GRAV_MASS;
		}
		
		/** Constant slide rate when key is pressed while attached to a wall */
		public function WallSlide( enabled:Boolean=true ):void {
			m_body.velocity.y = enabled ? SLIDE_SPEED : m_body.velocity.y - SLIDE_SPEED;
		}
		
		/** Display the turret menu */
		public function OpenTurretMenu():void {
			m_turretMenu.Show();
		}
		
		/** Hide the turret menu */
		public function CloseTurretMenu():void {
			m_turretMenu.Hide();
		}
		
		/** Cycle the active turret */
		public function CycleTurretMenu():void {
			m_turretMenu.Cycle();
		}
		
		/** Turret selected, drop the turret at players location */
		public function DropTurret():void {
			var turret:g_entity = gt_turretmanager.instance.AddTurret( m_parent, x, y - m_assetHalfHeight );
			turret.Draw();
		}
		
		public function RepairTurret():void {
			if ( m_repairTime == 0 || getTimer() - m_repairTime >= REPAIR_DELAY ) {
				m_repairTime = getTimer();
				gt_turretmanager.instance.turrets[ m_repairTurret ].Repair();
				globals.echo( "REPAIRING TURRET! : " + gt_turretmanager.instance.turrets[ m_repairTurret ], "HEALTH: " + gt_turretmanager.instance.turrets[ m_repairTurret ].health );
			}
		}
		
		/** Increments the coin total */
		public function AddCoin():void {
			++m_coins;
			globals.echo( "Player has: " + m_coins + " coins." );
		}
		
		/*========================================================================================
		EVENT HANDLING
		========================================================================================*/
		/** Called whenever an enemy hits the player */
		public function HandleEnemyCollision( enemy:ge_enemy ):void {
			m_health -= enemy.hitDamage;
			m_body.gravMass = GRAV_MASS;
			if ( m_health <= 0 ) {
				Destroy();
			}
			m_state.HandleEnemyCollision();
		}
		
		/** When player is hit with a projectile */
		public function HandleHit():void {
			m_health -= 1;
			m_body.gravMass = GRAV_MASS;
			if ( m_health <= 0 ) {
				Destroy();
			}
			m_state.HandleEnemyCollision();
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		public function get armature():Armature { return m_armature; }
	}
}