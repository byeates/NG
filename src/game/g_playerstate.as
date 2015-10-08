package game
{
	import com.bindings;
	
	import flash.utils.Dictionary;
	
	import dragonBones.animation.WorldClock;
	import dragonBones.events.AnimationEvent;
	
	import game.turret.gt_turretmanager;
	
	import nape.callbacks.InteractionCallback;
	
	import starling.events.KeyboardEvent;
	
	import ui.ui_turretmenu;
	
	/*========================================================================================
	PLAYER STATE HANDLER
	========================================================================================*/
	public class g_playerstate implements g_istatemachine
	{
		/*===============
		PROTECTED			
		===============*/
		protected var m_player				:g_player;
		protected var m_elapsedTime			:Number;
		protected var m_direction			:int;
		//key press container
		protected var keys					:Dictionary;
		
		//states
		protected var m_jumpState			:String;
		protected var m_moveState			:String;
		protected var m_animState			:String;
		protected var m_menuState			:String;
		
		/*===============
		CONSTANTS			
		===============*/
		static protected const JUMPING		:String = "jumping";
		static protected const RUNNING		:String	= "running";
		static protected const WALL_JUMP	:String	= "walljump";
		static protected const READY		:String	= "ready";
		static protected const NONE			:String	= "none";
		static protected const OPEN			:String = "open";
		static protected const CLOSED		:String = "closed";
		static protected const PLAY_LEFT	:String = "playleft";
		static protected const PLAY_RIGHT	:String = "playright";
		static protected const PLAY_IDLE	:String = "playidle";
		static protected const PLAY_FALL	:String = "playfall";
		static protected const PLAY_LAND	:String = "playland";
		
		/** player state needs to reference to player for correct handling */
		public function g_playerstate( player:g_player ) { m_player = player; }
		
		public function Init():void {
			keys = new Dictionary;
			//set states
			m_menuState = CLOSED
			m_jumpState = m_moveState = READY;
			
			//add listeners to dispatch
			g_dispatcher.instance.AddToDispatch( OnKeyDown, null, "keyboard", KeyboardEvent.KEY_DOWN );
			g_dispatcher.instance.AddToDispatch( OnKeyUp, null, "keyboard", KeyboardEvent.KEY_UP );
			g_dispatcher.instance.AddToDispatch( UpdateHandler );
		}
		
		/** Typically the state handler will decide what to do with a given input */
		public function StateHandler( input:* ):void {
			
		}
		
		
		public function HandleFloorCollision( collision:InteractionCallback ):void {
			m_player.animation.gotoAndPlay("land");
			m_animState = PLAY_LAND;
			
			m_player.armature.addEventListener(AnimationEvent.COMPLETE, function playidle():void {
				m_player.armature.removeEventListener(AnimationEvent.COMPLETE, playidle);
				m_animState = READY;
				UpdatePlayerAnimation();
			});
			
			//if we are still colliding with a wall, detach
			if ( m_jumpState == WALL_JUMP ) {
				m_player.DetachedFromWall();
			}
			
			m_jumpState = m_moveState = READY;
			m_player.body.gravMass = 1.2;
		}
		
		public function HandleWallCollision( collision:InteractionCallback ):void {
			m_jumpState = READY;
			m_moveState = WALL_JUMP;
			m_player.AttachedToWall();
			//int1 will be the wall, int2 will be the player
			m_direction = collision.int1[ "bounds" ].x < collision.int2[ "bounds" ].x ? 1 : -1;
			m_player.animation.gotoAndPlay("wallGrab");
		}
		
		public function HandleWallBreak( collision:InteractionCallback ):void {
			m_jumpState = m_moveState = READY;
			m_player.DetachedFromWall();
			m_direction = 0;
			UpdatePlayerAnimation();
		}
		
		public function HandleEnemyCollision():void {
			ResetKeys();
			m_jumpState = m_moveState = READY;
		}
		
		public function ResetKeys():void {
			keys[ bindings.LEFT ] 	= false;
			keys[ bindings.RIGHT ] 	= false;
			keys[ bindings.DOWN ] 	= false;
		}
		
		public function UpdateHandler( elapsedTime:Number ):void {
			//handle current key presses
			if ( keys[ bindings.LEFT ] || keys[ bindings.RIGHT ] ) {
				//don't continue movement if attached to a wall in the same direction
				var dir:int = keys[ bindings.LEFT ] ? -1 : 1;
				if ( m_moveState != WALL_JUMP || m_moveState == WALL_JUMP && m_direction != -dir ) {
					m_player.Move( dir, elapsedTime );
				}
			}
			else if ( m_moveState == RUNNING && m_jumpState != JUMPING && m_jumpState != WALL_JUMP ) {
					m_moveState = READY;
					m_player.body.velocity.x *= 0.3;
			}
			UpdatePlayerAnimation();
			m_elapsedTime = elapsedTime;
			
			//update the player, no reason to have this function add to the dispatcher
			m_player.Update( elapsedTime );
		}
		
		/** Keyboard event, applied with relative touch phases
		 * e.g. - g_dispatcher.instance.AddToDispatch( OnKeyDown, null, "keyboard", KeyboardEVent.KEY_DOWN ); 
		 * */
		protected function OnKeyDown( e:KeyboardEvent ):void {
			switch( e.keyCode ) {
				case bindings.UP:					JumpState( bindings.UP );
					break;
				
				case bindings.LEFT:					MoveState( bindings.LEFT );
					break;
				
				case bindings.DOWN:					SlideState( bindings.DOWN );
					break;
				
				case bindings.RIGHT:				MoveState( bindings.RIGHT );
					break;
			}
		}
		
		/** Keyboard event, applied with relative touch phases
		 * e.g. - g_dispatcher.instance.AddToDispatch( OnKeyDown, null, "keyboard", KeyboardEVent.KEY_DOWN ); 
		 * */
		protected function OnKeyUp( e:KeyboardEvent ):void {
			keys[ e.keyCode ] = false
			switch( e.keyCode ) {
				case bindings.UP:					//probably control animation here
					break;
				
				case bindings.LEFT:					//probably control animation here
					break;
				
				case bindings.DOWN:					if ( m_moveState == WALL_JUMP ) { m_player.WallSlide( false ); }
					break;
				
				case bindings.RIGHT:				//probably control animation here
					break;
				
				case bindings.TURRET_MENU_CLOSE:	TurretMenuState( true );
					break;
				
				case bindings.TURRET_MENU_OPEN:		TurretMenuState();
					break;
				
				case bindings.TURRET_SELECT:		SelectTurret();
					break;
			}
		}
		
		/** Determines which animation to play, will need to be more robust as we create more animations */
		protected function UpdatePlayerAnimation():void {
			//cache the velocities
			var velocityX:Number = m_player.body.velocity.x;
			var velocityY:Number = m_player.body.velocity.y;
			
			//play the fall animation if the player is floating in the air or descending
			if ( velocityY > 0 && m_moveState != WALL_JUMP && m_animState != PLAY_FALL ) {
				m_animState = PLAY_FALL;
				m_player.animation.gotoAndPlay( "fall" );
			}
			//if we are at a stand still, play the idle
			else if ( m_moveState != WALL_JUMP && Math.abs( velocityX ) < 10 && velocityY == 0 ) {
				if ( m_animState != PLAY_LAND && m_animState != PLAY_IDLE ) {
					m_animState = PLAY_IDLE;
					m_player.animation.gotoAndPlay( "idle" );
				}
				//we are playing the idle animation, return
				else { return; }
			}
			// only play the run animations if we are not falling
			else if ( velocityY <= 0 ) {
				if ( velocityX < 0 && m_player.asset.scaleX < 0 && m_animState != PLAY_LEFT ) {
					m_animState = PLAY_LEFT;
					m_player.animation.gotoAndPlay( "run" );
				} 
				else if ( velocityX > 0 && m_player.asset.scaleX > 0 && m_animState != PLAY_RIGHT ) {
					m_animState = PLAY_RIGHT
					m_player.animation.gotoAndPlay( "run" );
				}
			}
		}
		
		/** Handles when a new move event is triggered */
		protected function MoveState( key:uint ):void {
			if ( keys[ key ] ) { return; }
			//
			keys[ key ] = true;
			//don't change the move state if we are still ready for a wall jump
			m_moveState = m_moveState != WALL_JUMP ? RUNNING : m_moveState;
			//UpdatePlayerAnimation();
		}
		
		/** Handles standard and wall jumps */
		protected function JumpState( key:uint ):void {
			if ( m_jumpState == JUMPING || keys[ bindings.UP ] ) { return; }
			//
			keys[ key ] = true;
			m_jumpState = JUMPING;
			m_player.body.gravMass = 1.2;
			
			//check for air jump
			if ( m_moveState == WALL_JUMP ) {
				m_moveState = m_jumpState = READY;
				m_player.WallJump( m_direction );
			} 
			else {
				m_player.Jump();
			}
			m_player.animation.gotoAndPlay( "jump" );
		}
		
		/** Handles display of the turret menu */
		protected function TurretMenuState( close:Boolean=false ):void {
			//closing the menu?
			if ( close && m_menuState == OPEN ) {
				m_player.CloseTurretMenu();
				m_menuState = CLOSED;
				keys[ bindings.TURRET_MENU_CLOSE ] = false;
			}
			//opening the menu?
			else if ( m_menuState == CLOSED ) {
				m_player.OpenTurretMenu();
				m_menuState = OPEN;
				keys[ bindings.TURRET_MENU_OPEN ] = true;
			}
			//cycling the menu?
			else {
				m_player.CycleTurretMenu();
			}
		}
		
		/** Attempt to drop a turret 
		 * TODO: Can drop a turret if they have enough of turret resource, cannot drop turret if it is bomb or melee and they are in the air
		 * */
		protected function SelectTurret():void {
			if ( gt_turretmanager.instance.TURRET_TYPES[ gt_turretmanager.instance.activeTurret ].search( "bomb|melee" ) != -1 && m_jumpState != READY ) { return; }
			m_menuState = CLOSED;
			m_player.DropTurret();
			m_player.CloseTurretMenu();
			keys[ bindings.TURRET_MENU_OPEN ] = keys[ bindings.TURRET_MENU_CLOSE ] = false;
		}
		
		/** Handles sliding when player is attached to a wall */
		protected function SlideState( key:uint ):void {
			if ( keys[ key ] || m_moveState != WALL_JUMP ) { return; }
			//
			keys[ key ] = true;
			m_player.WallSlide();
		}
	}
}