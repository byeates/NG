package com
{
	import flash.ui.Keyboard;

	/*========================================================================================
	KEY BINDINGS CLASS
		- setup values for all the relevant key binding properties, this can be changed
		  from a binding change menu
	========================================================================================*/
	public class bindings
	{
		/*===============
		PROTECTED
		===============*/
		//only the menu can change these	
		static protected var m_left				:uint = Keyboard.LEFT;
		static protected var m_right			:uint = Keyboard.RIGHT;
		static protected var m_up				:uint = Keyboard.UP;
		static protected var m_down				:uint = Keyboard.DOWN;
		static protected var m_turretMenuOpen	:uint = Keyboard.SHIFT;
		static protected var m_turretMenuClose	:uint = Keyboard.Z;
		static protected var m_turretSelect		:uint = Keyboard.X;
		
		/*===============
		PUBLIC			
		===============*/
		static public function get LEFT():uint 				{ return m_left; 			}
		static public function get RIGHT():uint 			{ return m_right; 			}
		static public function get UP():uint 				{ return m_up; 				}
		static public function get DOWN():uint 				{ return m_down; 			}
		static public function get TURRET_MENU_OPEN():uint 	{ return m_turretMenuOpen; 	}
		static public function get TURRET_MENU_CLOSE():uint { return m_turretMenuClose; }
		static public function get TURRET_SELECT():uint		{ return m_turretSelect;	}
	}
}