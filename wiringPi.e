--****
-- = wiringPi
--
-- == About
--
-- WiringPi is a GPIO access library written in C for the BCM2835 used in the **Raspberry Pi**.
-- It's released under the [[http://www.gnu.org/copyleft/lesser.html|GNU LGPLv3]] license and
-- is usable from C and C++ and many other languages with suitable wrappers (See below) It's
-- designed to be familiar to people who have used the Arduino "wiring" system.
--
-- See the [[http://wiringpi.com/|wiringPi website]] for more information.
--

namespace wiringPi

include std/dll.e
include std/machine.e

ifdef not ARM then

	include std/error.e
	error:crash( "Platform not supported by wiringPi" )

end ifdef

atom wiringPi = open_dll( "libwiringPi.so" )

public constant
	TRUE	= (1=1),
	FALSE	= (not TRUE),
$

public constant
	-- wiringPi modes
	WPI_MODE_PINS			=  0,
	WPI_MODE_GPIO			=  1,
	WPI_MODE_GPIO_SYS		=  2,
	WPI_MODE_PHYS			=  3,
	WPI_MODE_PIFACE			=  4,
	WPI_MODE_UNINITIALISED	= -1,
$

public constant
	-- Pin modes
	INPUT					=  0,
	OUTPUT					=  1,
	PWM_OUTPUT				=  2,
	GPIO_CLOCK				=  3,
	SOFT_PWM_OUTPUT			=  4,
	SOFT_TONE_OUTPUT		=  5,
	PWM_TONE_OUTPUT			=  6,
$

public constant
	LOW						=  0,
	HIGH					=  1,
$

public constant
	-- Pull up/down/none
	PUD_OFF					=  0,
	PUD_DOWN				=  1,
	PUD_UP					=  2,
$

public constant
	-- PWM
	PWM_MODE_MS				=  0,
	PWM_MODE_BAL			=  1,
$

public constant
	-- Interrupt levels
	INT_EDGE_SETUP			=  0,
	INT_EDGE_FALLING		=  1,
	INT_EDGE_RISING			=  2,
	INT_EDGE_BOTH			=  3,
$

-- PI model types and version numbers
-- Intended for the GPIO program  Use at your own risk.

public constant
	PI_MODEL_A				=  0,
	PI_MODEL_B				=  1,
	PI_MODEL_AP				=  2,
	PI_MODEL_BP				=  3,
	PI_MODEL_2				=  4,
	PI_ALPHA				=  5,
	PI_MODEL_CM				=  6,
	PI_MODEL_07				=  7,
	PI_MODEL_3				=  8,
	PI_MODEL_ZERO			=  9,
$

public constant
	PI_VERSION_1			=  0,
	PI_VERSION_1_1			=  1,
	PI_VERSION_1_2			=  2,
	PI_VERSION_2			=  3,
$

public constant
	PI_MAKER_SONY			=  0,
	PI_MAKER_EGOMAN			=  1,
	PI_MAKER_MBEST			=  2,
	PI_MAKER_UNKNOWN		=  3,
$

function peek_string_array( atom ptr, integer limit = 0 )

	sequence array = {}

	atom str = peek4u( ptr )
	while str != NULL do

		sequence string = peek_string( str )
		array = append( array, string )

		ptr += sizeof( C_POINTER )
		str = peek4u( ptr )

		if length( array ) = limit then
			exit
		end if

	end while

	return array
end function

constant
	_piModelNames		= define_c_var( wiringPi, "piModelNames" ),
	_piRevisionNames	= define_c_var( wiringPi, "piRevisionNames" ),
	_piMakerNames		= define_c_var( wiringPi, "piMakerNames" ),
	_piMemorySize		= define_c_var( wiringPi, "piMemorySize" ),
$

public constant
	piModelNames 	= peek_string_array( _piModelNames,    16 ),
	piRevisionNames	= peek_string_array( _piRevisionNames, 16 ),
	piMakerNames	= peek_string_array( _piMakerNames,    16 ),
	piMemorySize	= peek4s({ _piMemorySize, 8 }),
$

public constant
	-- Failure modes
	WPI_FATAL		= (1=1),
	WPI_ALMOST		= (1=2),
$

-- wiringPiNodeStruct
--  This describes additional devices nodes in the extended wiringPi
--  2.0 scheme of things.
--  It's a simple linked list for now, but will hopefully migrate to
--  a binary tree for efficiency reason - but then again, the changes
--  of more than 1 or 2 devices being added are fairly slim, so who
--  knows....

constant
	wiringPiNodeStruct__pinBase			=  0, -- int
	wiringPiNodeStruct__pinMax			=  4, -- int
	wiringPiNodeStruct__fd				=  8, -- int
	wiringPiNodeStruct__data0			= 12, -- unsigned int
	wiringPiNodeStruct__data1			= 16, -- unsigned int
	wiringPiNodeStruct__data2			= 20, -- unsigned int
	wiringPiNodeStruct__data3			= 24, -- unsigned int
	wiringPiNodeStruct__pinMode			= 28, -- call_back
	wiringPiNodeStruct__pullUpDnControl	= 32, -- call_back
	wiringPiNodeStruct__digitalRead		= 36, -- call_back
	wiringPiNodeStruct__digitalWrite	= 40, -- call_back
	wiringPiNodeStruct__pwmWrite		= 44, -- call_back
	wiringPiNodeStruct__analogRead		= 48, -- call_back
	wiringPiNodeStruct__analogWrite		= 52, -- call_back
	wiringPiNodeStruct__next			= 56, -- wiringPiNodeStruct*
	SIZEOF_WIRINGPINODESTRUCT			= 60,
$

public enum
	WPI_NODE_PINBASE,
	WPI_NODE_PINMAX,
	WPI_NODE_FD,
	WPI_NODE_DATA0,
	WPI_NODE_DATA1,
	WPI_NODE_DATA2,
	WPI_NODE_DATA3,
	WPI_NODE_PINMODE,
	WPI_NODE_PULLUPDNCONTROL,
	WPI_NODE_DIGITALREAD,
	WPI_NODE_DIGITALWRITE,
	WPI_NODE_PWMWRITE,
	WPI_NODE_ANALOGREAD,
	WPI_NODE_ANALOGWRITE,
	WPI_NODE_LAST,
$

function peek_wiringPiNodes( atom ptr )

	sequence nodes = {}

	while ptr != NULL do

		atom pinBase         = peek4s( ptr + wiringPiNodeStruct__pinBase )
		atom pinMax          = peek4s( ptr + wiringPiNodeStruct__pinMax )
		atom fd              = peek4s( ptr + wiringPiNodeStruct__fd )
		atom data0           = peek4u( ptr + wiringPiNodeStruct__data0 )
		atom data1           = peek4u( ptr + wiringPiNodeStruct__data1 )
		atom data2      	 = peek4u( ptr + wiringPiNodeStruct__data2 )
		atom data3           = peek4u( ptr + wiringPiNodeStruct__data3 )
		atom pinMode         = peek4u( ptr + wiringPiNodeStruct__pinMode )
		atom pullUpDnControl = peek4u( ptr + wiringPiNodeStruct__pullUpDnControl )
		atom digitalRead     = peek4u( ptr + wiringPiNodeStruct__digitalRead )
		atom digitalWrite    = peek4u( ptr + wiringPiNodeStruct__digitalWrite )
		atom pwmWrite        = peek4u( ptr + wiringPiNodeStruct__pwmWrite )
		atom analogRead      = peek4u( ptr + wiringPiNodeStruct__analogRead )
		atom analogWrite     = peek4u( ptr + wiringPiNodeStruct__analogWrite )
		atom next            = peek4u( ptr + wiringPiNodeStruct__next )

		nodes = append( nodes, {pinBase, pinMax, fd, data0, data1, data2, data3, pinMode,
			pullUpDnControl, digitalRead, digitalWrite, pwmWrite, analogRead, analogWrite} )

		ptr = next
	end while

	return nodes
end function

constant
	_wiringPiNodes = define_c_var( wiringPi, "wiringPiNodes" ),
$

public constant wiringPiNodes = peek_wiringPiNodes( _wiringPiNodes )


-- Function prototypes

constant
    _analogRead         = define_c_func( wiringPi, "analogRead", {C_INT}, C_INT ),
    _analogWrite        = define_c_proc( wiringPi, "analogWrite", {C_INT,C_INT} ),
    _digitalRead        = define_c_func( wiringPi, "digitalRead", {C_INT}, C_INT ),
    _digitalReadByte    = define_c_func( wiringPi, "digitalReadByte", {}, C_INT ),
    _digitalWrite       = define_c_proc( wiringPi, "digitalWrite", {C_INT,C_INT} ),
    _digitalWriteByte   = define_c_proc( wiringPi, "digitalWriteByte", {C_INT} ),
    _getAlt             = define_c_func( wiringPi, "getAlt", {C_INT}, C_INT ),
    _gpioClockSet       = define_c_proc( wiringPi, "gpioClockSet", {C_INT,C_INT} ),
    _physPinToGpio      = define_c_func( wiringPi, "physPinToGpio", {C_INT}, C_INT ),
    _piBoardId          = define_c_proc( wiringPi, "piBoardId", {C_POINTER,C_POINTER,C_POINTER,C_POINTER,C_POINTER} ),
    _piBoardRev         = define_c_func( wiringPi, "piBoardRev", {}, C_INT ),
    _pinMode            = define_c_proc( wiringPi, "pinMode", {C_INT,C_INT} ),
    _pinModeAlt         = define_c_proc( wiringPi, "pinModeAlt", {C_INT,C_INT} ),
    _pullUpDnControl    = define_c_proc( wiringPi, "pullUpDnControl", {C_INT,C_INT} ),
    _pwmSetClock        = define_c_proc( wiringPi, "pwmSetClock", {C_INT} ),
    _pwmSetMode         = define_c_proc( wiringPi, "pwmSetMode", {C_INT} ),
    _pwmSetRange        = define_c_proc( wiringPi, "pwmSetRange", {C_UINT} ),
    _pwmToneWrite       = define_c_proc( wiringPi, "pwmToneWrite", {C_INT,C_INT} ),
    _pwmWrite           = define_c_proc( wiringPi, "pwmWrite", {C_INT,C_INT} ),
    _setPadDrive        = define_c_proc( wiringPi, "setPadDrive", {C_INT,C_INT} ),
    _waitForInterrupt   = define_c_func( wiringPi, "waitForInterrupt", {C_INT,C_INT}, C_INT ),
    _wiringPiFailure    = define_c_func( wiringPi, "wiringPiFailure", {C_INT,C_POINTER}, C_INT ),
    _wiringPiFindNode   = define_c_func( wiringPi, "wiringPiFindNode", {C_INT}, C_POINTER ),
    _wiringPiISR        = define_c_func( wiringPi, "wiringPiISR", {C_INT,C_INT,C_POINTER}, C_INT ),
    _wiringPiNewNode    = define_c_func( wiringPi, "wiringPiNewNode", {C_INT,C_INT}, C_POINTER ),
    _wiringPiSetup      = define_c_func( wiringPi, "wiringPiSetup", {}, C_INT ),
    _wiringPiSetupGpio  = define_c_func( wiringPi, "wiringPiSetupGpio", {}, C_INT ),
    _wiringPiSetupPhys  = define_c_func( wiringPi, "wiringPiSetupPhys", {}, C_INT ),
    _wiringPiSetupSys   = define_c_func( wiringPi, "wiringPiSetupSys", {}, C_INT ),
    _wpiPinToGpio       = define_c_func( wiringPi, "wpiPinToGpio", {C_INT}, C_INT ),
$

--****
-- == Setup
--
-- There are four ways to initialise wiringPi.
--
-- * [[:wiringPiSetup]]()
-- * [[:wiringPiSetupGpio]]()
-- * [[:wiringPiSetupPhys]]()
-- * [[:wiringPiSetupSys]]()
--
-- One of the setup functions must be called at the start of your program or your program will
-- fail to work correctly. You may experience symptoms from it simply not working to segfaults
-- and timing issues.
--
-- **Note:** **//wiringPi//** version 1 returned an error code if these functions failed for
-- whatever reason. Version 2 returns always returns zero. After discussions and inspection of
-- many programs written by users of **//wiringPi//** and observing that many people don't
-- bother checking the return code, I took the stance that should one of the wiringPi setup
-- functions fail, then it would be considered a fatal program fault and the program execution
-- will be terminated at that point with an error message printed on the terminal.
--
-- //If you want to restore the v1 behaviour, then you need to set the environment variable:
-- **{{WIRINGPI_CODES}}** (to any value, it just needs to exist).//
--



--**
--
--
public function wiringPiSetup()
	return c_func( _wiringPiSetup, {} )
end function

public function wiringPiSetupGpio()
	return c_func( _wiringPiSetupGpio, {} )
end function

public function wiringPiSetupSys()
	return c_func( _wiringPiSetupSys, {} )
end function

public function wiringPiSetupPhys()
	return c_func( _wiringPiSetupPhys, {} )
end function


public function wiringPiFailure( atom fatal, sequence message, object data = {} )
	if not equal( data, {} ) then message = sprintf( message, data ) end if
	return c_func( _wiringPiFailure, {fatal,allocate_string(message,1)} )
end function

public function wiringPiFindNode( atom pin )
	return c_func( _wiringPiFindNode, {pin} )
end function

public function wiringPiNewNode( atom pinBase, atom numPins )
	return c_func( _wiringPiNewNode, {pinBase,numPins} )
end function

public procedure pinModeAlt( atom pin, atom mode )
	c_proc( _pinModeAlt, {pin,mode} )
end procedure

public procedure pinMode( atom pin, atom mode )
	c_proc( _pinMode, {pin,mode} )
end procedure

public procedure pullUpDnControl( atom pin, atom pud )
	c_proc( _pullUpDnControl, {pin,pud} )
end procedure

public function digitalRead( atom pin )
	return c_func( _digitalRead, {pin} )
end function

public procedure digitalWrite( atom pin, atom value )
	c_proc( _digitalWrite, {pin,value} )
end procedure

public procedure pwmWrite( atom pin, atom value )
	c_proc( _pwmWrite, {pin,value} )
end procedure

public function analogRead( atom pin )
	return c_func( _analogRead, {pin} )
end function

public procedure analogWrite( atom pin, atom value )
	c_proc( _analogWrite, {pin,value} )
end procedure

-- On-Board Raspberry Pi hardware specific stuff

public function piBoardRev()
	return c_func( _piBoardRev, {} )
end function

public function piBoardId()

	atom p_model      = allocate_data( sizeof(C_INT), 1 )
	atom p_rev        = allocate_data( sizeof(C_INT), 1 )
	atom p_mem        = allocate_data( sizeof(C_INT), 1 )
	atom p_maker      = allocate_data( sizeof(C_INT), 1 )
	atom p_overVolted = allocate_data( sizeof(C_INT), 1 )

	c_proc( _piBoardId, {p_model,p_rev,p_mem,p_maker,p_overVolted} )

	atom model      = peek4s( p_model ) + 1
	atom rev        = peek4s( p_rev   ) + 1
	atom mem        = peek4s( p_mem   ) + 1
	atom maker      = peek4s( p_maker ) + 1
	atom overVolted = peek4s( p_overVolted )

	return {model,rev,mem,maker,overVolted}
end function

public function wpiPinToGpio( atom wpiPin )
	return c_func( _wpiPinToGpio, {wpiPin} )
end function

public function physPinToGpio( atom physPin )
	return c_func( _physPinToGpio, {physPin} )
end function

public procedure setPadDrive( atom group, atom value )
	c_proc( _setPadDrive, {group,value} )
end procedure

public function getAlt( atom pin )
	return c_func( _getAlt, {pin} )
end function

public procedure pwmToneWrite( atom pin, atom freq )
	c_proc( _pwmToneWrite, {pin,freq} )
end procedure

public procedure digitalWriteByte( atom value )
	c_proc( _digitalWriteByte, {value} )
end procedure

public function digitalReadByte()
	return c_func( _digitalReadByte, {} )
end function

public procedure pwmSetMode( atom mode )
	c_proc( _pwmSetMode, {mode} )
end procedure

public procedure pwmSetRange( atom range )
	c_proc( _pwmSetRange, {range} )
end procedure

public procedure pwmSetClock( atom divisor )
	c_proc( _pwmSetClock, {divisor} )
end procedure

public procedure gpioClockSet( atom pin, atom freq )
	c_proc( _gpioClockSet, {pin,freq} )
end procedure

-- Interrupts
--  (Also Pi hardware specific)

public function waitForInterrupt( atom pin, atom mS )
	return c_func( _waitForInterrupt, {pin,mS} )
end function

public function wiringPiISR( atom pin, atom mode, atom func )
	return c_func( _wiringPiISR, {pin,mode,func} )
end function

