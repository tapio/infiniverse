#pragma once

#include "crt.bi"

'' we don't need C's variables
#undef socket
#undef TRUE
#undef FALSE

const as integer TRUE = (0 = 0), FALSE = (0 = 1)

#include "chisock-system.bi"

#undef quick_len
#define quick_len(_s) cast(integer ptr, @_s)[1]

#macro DECLARE_SOCKET_GET(t)
	declare function get overload _ 
		( _ 
			byref data_ as t, _
			byref elems as integer = 1, _ 
			byval time_out as integer = ONLY_ONCE, _ 
			byval peek_only as integer = FALSE _
		) as integer
#endmacro
		
#macro DECLARE_SOCKET_PUT(t)
	declare function put overload _ 
		( _ 
			byref data_ as t, _
			byref elems as integer = 1, _ 
			byval time_out as integer = 0 _ 
		) as integer
#endmacro

#undef CR_LF		
const as string CR_LF = chr(13, 10)

#define BUILD_IP( _1, _2, _3, _4 ) _ 
	( ( ( _4 and 255 ) shl 24 ) or _ 
	  ( ( _3 and 255 ) shl 16 ) or _ 
	  ( ( _2 and 255 ) shl  8 ) or _ 
	  ( ( _1 and 255 ) shl  0 ) )

#define BREAK_IP( _octet, _addr ) ( ( _addr shr ( 8 * _octet ) ) and 255 )

namespace chi
	
	type socket_lock
		
		declare constructor( byval lock_ as any ptr )
		declare destructor( )
		
		lock as any ptr
		
	end type
	
	type socket
		
		enum ACCESS_METHOD
		
			ONLY_ONCE = -1
			BLOCK     = 0
			
		end enum
		
		enum PORT
			
			FTP_DATA    = 20
			FTP_CONTROL = 21
			SSH         = 22
			TELNET      = 23
			GOPHER      = 70
			HTTP        = 80
			SFTP        = 115
			IRC         = 6667
			
		end enum
		
		const as integer LOCALHOST = BUILD_IP( 127, 0, 0, 1 )
		
		declare constructor( )
		declare destructor( )
		
		declare function client _
			( _ 
				byval ip as integer, _
				byval port as integer _
			) as integer
		
		declare function client _
			( _ 
				byref server as string, _
				byval port as integer _
			) as integer
		
		declare function UDP_client _
			( _ 
				byval ip as integer, _
				byval port as integer _
			) as integer
		
		declare function UDP_client _
			( _ 
				byref server as string, _
				byval port as integer _
			) as integer
		
		declare function UDP_client _
			( _ 
			) as integer
		
		declare function server _
			( _ 
				byval port as integer, _
				byval max_queue as integer = 4 _
			) as integer
		
		declare function UDP_server _
			( _ 
				byval port as integer, _
				byval ip as integer = INADDR_ANY _
			) as integer
		
		declare function UDP_connectionless_server _
			( _ 
				byval port as integer _
			) as integer
		
		declare function listen _ 
			( _ 
				byref timeout as double = 0 _ 
			) as integer 
		
		declare function listen_to_new _ 
			( _ 
				byref listener as socket, _ 
				byval timeout as double = 0 _ 
			) as integer
		
		declare function get_data _ 
			( _ 
				byval data_ as any ptr, _
				byval size as integer, _ 
				byval peek_only as integer = FALSE _
			) as integer
		
		declare function get_line _ 
			( _ 
			) as string
		
		declare function get_until _ 
			( _ 
				byref target as string _
			) as string
		
		DECLARE_SOCKET_GET(short)
		DECLARE_SOCKET_GET(integer)
		DECLARE_SOCKET_GET(double )
		DECLARE_SOCKET_GET(ubyte  )
		DECLARE_SOCKET_GET(string )
			
		declare function put_data _ 
			( _ 
				byval data_ as any ptr, _
				byval size as integer   _ 
			) as integer
			
		DECLARE_SOCKET_PUT(short)
		DECLARE_SOCKET_PUT(integer)
		DECLARE_SOCKET_PUT(double )
		DECLARE_SOCKET_PUT(ubyte  )
		DECLARE_SOCKET_PUT(string )
		
		declare function put_line _ 
			( _ 
				byref text as string _ 
			) as integer
		
		declare function put_string _ 
			( _ 
				byref text as string _ 
			) as integer
		
		declare function put_HTTP_request _ 
			( _ 
				byref server_name as string, _ 
				byref method      as string = "GET", _ 
				byref post_data   as string = ""     _ 
			) as integer
		
		declare function put_IRC_auth _ 
			( _ 
				byref nick as string = "undefined", _ 
				byref realname as string = "undefined", _ 
				byref pass as string = "" _
			) as integer
		
		declare function dump_data _ 
			( _ 
				byval size as integer _ 
			) as integer
			
		declare function length _ 
			( _ 
			) as integer
			
		declare function is_closed _ 
			( _ 
			) as integer
		
		declare function close _ 
			( _ 
			) as integer
		
		declare property recv_limit _ 
			( _ 
				byref limit as double _ 
			)
		
		declare property send_limit _ 
			( _ 
				byref limit as double _ 
			)
		
		declare property recv_limit _ 
			( _ 
			) as double
		
		declare property send_limit _ 
			( _ 
			) as double
		
		declare function recv_rate _ 
			( _ 
			) as integer
			
		declare function send_rate _ 
			( _ 
			) as integer
		
		declare function set_destination _ 
			( _
				byval info as socket_info ptr = NULL _
			) as integer
			
		declare function connection_info _ 
			( _
			) as socket_info ptr
			
		declare property hold _ 
			( _ 
				byval as integer _ 
			)
		
		'private:
		
		const as integer BUFF_SIZE = 4096
		
		const as integer BUFF_RATE = 10
		
		enum KINDS
			
			SOCK_TCP
			SOCK_UDP
			SOCK_UDP_CONNECTIONLESS
			
		end enum
		
		declare static sub recv_proc _ 
			( _ 
				byval opaque as any ptr _ 
			)
		
		declare static sub send_proc _ 
			(  _ 
				byval opaque as any ptr _ 
			)
		
		as integer p_hold
		as any ptr p_hold_lock, p_hold_signal
		as any ptr p_go_lock, p_go_signal
		
		p_send_buff_size  as integer = BUFF_SIZE
		p_send_data       as ubyte ptr
		p_send_caret      as integer
		p_send_size       as integer
		p_send_thread     as any ptr
		p_send_lock       as any ptr
		p_send_limit      as integer
		p_send_accum      as integer
		p_send_timer      as double
		p_send_disp_timer as double
		p_send_rate       as integer
		p_send_info       as socket_info ptr 
		
		p_recv_buff_size  as integer = BUFF_SIZE
		p_recv_data       as ubyte ptr
		p_recv_caret      as integer
		p_recv_size       as integer
		p_recv_thread     as any ptr
		p_recv_lock       as any ptr
		p_recv_limit      as integer
		p_recv_accum      as integer
		p_recv_timer      as double
		p_recv_disp_timer as double
		p_recv_rate       as integer
		p_recv_info       as socket_info
		
		as socket_info cnx_info
		
		as integer p_socket, p_listener
		p_dead as integer
		
		p_kind as KINDS
		
	end type
	
end namespace

#define SERIAL_UDT(x) *cast(ubyte ptr, @(x)), len(x)

#inclib "chisock"
