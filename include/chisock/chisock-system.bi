#pragma once

#include "crt.bi"

#ifdef __fb_win32__

	#define SO_SNDTIMEO &h1005

	#include "winsockets.bi"
	#inclib "user32"

#endif

#ifdef __fb_linux__

	#include "crt/sys/select.bi"
	#include "crt/arpa/inet.bi"
	#include "crt/netdb.bi"
	#include "crt/unistd.bi"

	#define h_addr h_addr_list[0]

#endif

#undef socket
#undef TRUE
#undef FALSE

const as integer TRUE = (0 = 0), FALSE = (0 = 1)

namespace chi
	
	const as integer C_TRUE = 1
	
	enum SOCKET_ERRORS
	
		SOCKET_OK
		FAILED_INIT
		FAILED_RESOLVE
		FAILED_CONNECT
		FAILED_REUSE
		FAILED_BIND
		FAILED_LISTEN
	
	end enum
	
	type socket_info
		
		data as sockaddr_in
		declare property port( ) as ushort
		
		declare operator cast( ) as string
		declare operator cast( ) as sockaddr ptr
		
	end type
	
	declare function translate_error _ 
		( _ 
			byval err_code as integer _
		) as string
	
	declare function resolve _ 
		( _ 
			byref host as string _ 
		) as uinteger
	
	declare function TCP_client overload _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _ 
			byref server as string, _ 
			byval port as integer _ 
		) as integer
	
	declare function TCP_client overload _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _ 
			byval ip as integer, _ 
			byval port as integer _ 
		) as integer
	
	declare function client_core _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _ 
			byval ip as integer, _ 
			byval port as integer, _ 
			byval from_socket as uinteger, _ 
			byval do_connect as integer = TRUE _
		) as integer
	
	declare function TCP_server _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _ 
			byval port as integer, _ 
			byval max_queue as integer = 4 _ 
		) as integer
	
	declare function TCP_server_accept _ 
		( _ 
			byref result as uinteger, _ 
			byref timeout as double, _ 
			byref client_info as sockaddr_in ptr, _ 
			byval listener as uinteger _ 
		) as integer 
		
	declare function server_core _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _ 
			byval port as integer, _ 
			byval ip as integer = INADDR_ANY, _
			byval from_socket as uinteger _
		) as integer
	
	declare function UDP_server _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _ 
			byval port as integer, _
			byval ip as integer = INADDR_ANY _
		) as integer
	
	declare function UDP_client overload _ 
		( _ 
			byref result as uinteger _ 
		) as integer
	
	declare function UDP_client _ 
		( _ 
			byref result as uinteger, _
			byref info as socket_info, _ 
			byref server_ as string, _ 
			byval port_ as integer _ 
		) as integer
		
	declare function UDP_client _ 
		( _ 
			byref result as uinteger, _ 
			byref info as socket_info, _
			byref ip as integer, _ 
			byval port_ as integer _ 
		) as integer
		
	declare function is_readable _ 
		( _ 
			byval socket_ as uinteger _ 
		) as integer
	
	declare function close _
		( _ 
			byval sock_ as uinteger _ 
		) as integer
	
	declare function new_sockaddr overload( byval serv as integer, byval port as short ) as socket_info ptr
	declare function new_sockaddr( byref serv as string, byval port as short ) as socket_info ptr
	
	const as integer NOT_AN_IP = -1
	
	#define new_socket socket_
	
end namespace
