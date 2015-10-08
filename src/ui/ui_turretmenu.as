package ui
{
	import com.assets;
	import com.globals;
	import com.math;
	import com.greensock.TweenLite;
	
	import game.turret.gt_turretmanager;
	
	import renderer.r_spriteclip;
	
	import starling.display.DisplayObjectContainer;
	
	/*========================================================================================
	TURRET SELECTION MENU ASSOCIATED WITH THE PLAYER CLASS
	========================================================================================*/
	public class ui_turretmenu extends ui_menu
	{
		/*===============
		PUBLIC
		===============*/
		/** set this to half the Max of player width and height + any padding */
		public var iconradius			:int;
		
		/*===============
		PROTECTED
		===============*/
		/** turret icons */
		protected var m_turreticons		:Vector.<r_spriteclip>;
		protected var m_selectedicon	:r_spriteclip;
		protected var m_cycleRotation	:Number;
		protected var m_numturrets		:int;
		protected var m_activeTurret	:int;
		
		/** turret menu is a silent singleton in that you create it using the new keyword, but use the instance property afterwards */
		public function ui_turretmenu( parent:DisplayObjectContainer ) {
			if ( !m_instance ) {
				super(parent);
				m_turreticons = new Vector.<r_spriteclip>;
				AddTurretIcons();
				m_instance = this;
			} else {
				throw new Error( "Already instantiated turret menu, use the instance property instead. " );
			}
		}
		
		override public function Init():void {}
		
		protected function AddTurretIcons():void {
			var length:int = gt_turretmanager.instance.NUM_TURRETS;
			var i:int;
			for ( ; i < length; ++i ) {
				//TODO: change this to movieclip when we have a sprite sheet.
				var icon:r_spriteclip = new r_spriteclip( assets.GetSpriteSheet( "turret" ).getTextures(), 4 );
				m_turreticons.push( icon );
				addChild( icon );
			}
			m_selectedicon = new r_spriteclip( assets.GetSpriteSheet( "selected_turret").getTextures(), 32 );
			m_selectedicon.visible = false;
			addChild( m_selectedicon );
		}
		
		/** Show the turret icons around the player. Set the iconradius property before attempting show */
		override public function Show():void {
			//only organize them if the turrets have changed
			if ( m_numturrets == gt_turretmanager.instance.NUM_TURRETS ) { return; }
			
			m_numturrets = gt_turretmanager.instance.availableTurrets.length;
			if ( m_numturrets == 0 ) { return; }
			
			//set turret menu to visible
			visible = true;
			
			var i:int;
			var rotation:Number = -math.pi_div2;
			for ( ; i < m_numturrets; ++i ) {
				//
				var icon:r_spriteclip 	= m_turreticons[ i ];
				icon.x 					= icon.width * Math.cos( rotation );
				icon.y 					= icon.width * Math.sin( rotation );
				rotation 				+= i <= 0 ? math.pi_div2 : math.pi;
				icon.gotoAndStop(i < 1 ? i : i == 1 ? 2 : i+1);
				if ( rotation > math.pi ) { rotation -= math.pi_2pi; }
			}
			SetActiveTurret();
		}
		
		public function Cycle():void {
			m_selectedicon.visible = false;
			
			m_activeTurret = m_activeTurret-1 < 0 ? m_turreticons.length-1 : m_activeTurret-1;
			
			var i:int;
			var rotation:Number = m_activeTurret == 1 ? math.pi : m_activeTurret == 0 ? -math.pi_div2 : 0;
			for ( ; i < m_turreticons.length; ++i ) {
				var icon:r_spriteclip 	= m_turreticons[ i ];
				
				var dx:Number 			= icon.width * Math.cos( rotation );
				var dy:Number 			= icon.width * Math.sin( rotation );
				rotation 				+= i <= 0 ? math.pi_div2 : math.pi;
				if ( rotation > math.pi ) { rotation -= math.pi_2pi; }
				
				if ( i == m_turreticons.length-1 ) {
					TweenLite.to( icon, 0.5, { x: dx, y:dy, onComplete: SetActiveTurret } );
				} else {
					TweenLite.to( icon, 0.5, { x: dx, y:dy } ); 
				}
			}
		}
		
		/** Callback after a cycle or show */
		private function SetActiveTurret():void {
			var index:int;
			gt_turretmanager.instance.activeTurret = m_activeTurret > 0 ? m_turreticons.length-m_activeTurret : 0;
			m_selectedicon.visible = true;
			m_selectedicon.x = m_turreticons[ m_activeTurret ].x - m_selectedicon.width *.1;
			m_selectedicon.y = m_turreticons[ m_activeTurret ].y - m_selectedicon.height *.55;
			m_selectedicon.gotoAndPlay(1,12);
		}
	}
}