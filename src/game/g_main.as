package game
{
	import com.assets;
	import com.globals;
	
	import flash.utils.getTimer;
	
	import dragonBones.animation.WorldClock;
	
	import game.enemy.ge_enemymanager;
	import game.misc.gm_chatbubble;
	
	import renderer.r_camera;
	import renderer.r_world;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import ui.ui_menu;
	
	public class g_main extends Sprite
	{
		/*===============
		PRIVATE			
		===============*/
		private var m_world			:r_world
		private var m_player		:g_player;
		private var m_startMenu		:ui_menu;
		private var m_levelState	:String;
		
		//used to update elapsed time between frames
		private var m_deltaTime		:int;
		private var m_currentTime	:int;
		private var m_previousTime	:int;
		
		public function g_main() {
			addEventListener( Event.ADDED_TO_STAGE, OnAdded );
		}
		
		private function OnAdded( e:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, OnAdded );
			globals.stageWidth 		= stage.stageWidth;
			globals.stageHeight 	= stage.stageHeight;
			
			DEBUG::enabled {
				assets.LoadAll( Init );
			}
			DEBUG::disabled {
				Init();
			}
		}
		
		/** Menu section */
		private function Init():void {
			g_state.instance.SetState( globals.MENU );
			globals.CreateOverlay( stage );
			m_startMenu = new ui_menu( globals.overlay );
			m_startMenu.AddButton( "button_play", false, -1, globals.stageHalfWidth, globals.stageHalfHeight, "click", Start );
			m_startMenu.Draw();
			AddListeners();
			
			//start loading the level
			m_levelState = globals.NONE;
			m_world = new r_world( OnLevelLoaded );
			addChild( m_world );
		}
		
		/** Start is called after we are finished with the menu */
		public function Start():void {
			m_startMenu.Destroy();
			g_state.instance.SetState( globals.GAME_RUNNING );
			if ( m_levelState == globals.READY ) {
				AddElements();
				m_world.Init();
			}
			//globals.FadeIn();
		}
		
		private function OnLevelLoaded():void {
			if ( g_state.instance.state == globals.GAME_RUNNING ) {
				AddElements();
				m_world.Init();
			}
			m_levelState = globals.READY;
		}
		
		/** Resets the level */
		public function Reset():void {
			m_player.Reset();
			Draw();
		}
		
		/** Really only used if the player has died, this will move them back to the staging screen where
		 * the player can select to replay the level or go to shop
		 * */
		public function Staging():void {
			g_state.instance.SetState( globals.MENU );
			ge_enemymanager.instance.Destroy();
			g_state.instance.Start 	= Reset;
		}
		
		private function OnTouch( e:TouchEvent ):void {
			var touch:Touch = e.getTouch( stage );
			if ( touch ) {
				g_state.instance.StateHandler( touch );
			}
		}
		
		private function Update( e:Event ):void {
			if ( m_player && m_player.isDestroyed && g_state.instance.state == globals.GAME_RUNNING ) {
				Staging();
			} 
			else if ( g_state.instance.state == globals.GAME_RUNNING ) {
				m_currentTime = getTimer();
				m_deltaTime = m_currentTime - m_previousTime;
			
				g_state.instance.UpdateHandler( m_deltaTime );
				m_previousTime = m_currentTime;
			}
			WorldClock.clock.advanceTime(-1);
		}
		
		private function OnKeyEvent( e:KeyboardEvent ):void {
			g_state.instance.StateHandler( e );
		}
		
		/** Add elements should add things that aren't normally parsed with the level, like the player */
		private function AddElements():void {
			//globals.FadeIn();
			m_player = new g_player( globals.midground, "player", false, 0, true, Draw );
		}
		
		/** g_entity types should have their Draw() called so they become visible */
		private function Draw():void {
			m_player.SetPosition( g_level.instance.GetPlayerStart().x, g_level.instance.GetPlayerStart().y );
			m_player.Draw();
			
			var bubble:gm_chatbubble = new gm_chatbubble( globals.midground, m_player, "Hollar!" );
			bubble.Open();
			bubble.Close(0.5, 3);
			r_camera.instance.SetTarget(m_player);
			
			g_scriptparser.instance.Init();
		}
		
		private function AddListeners():void {
			stage.addEventListener( TouchEvent.TOUCH, OnTouch );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, OnKeyEvent );
			stage.addEventListener( KeyboardEvent.KEY_UP, OnKeyEvent );
			addEventListener( Event.ENTER_FRAME, Update );
		}
		
		private function RemoveListeners():void {
			stage.removeEventListener( TouchEvent.TOUCH, OnTouch );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, OnKeyEvent );
			stage.removeEventListener( KeyboardEvent.KEY_UP, OnKeyEvent );
			removeEventListener( Event.ENTER_FRAME, Update );
		}
	}
}
