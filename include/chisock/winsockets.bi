#pragma once

#define SOCKET_ERROR (-1)

#define AF_INET 2
#define PF_INET 2

#define SOCK_STREAM 1
#define SOCK_DGRAM 2

#define IPPROTO_IP 0

#define INADDR_ANY	      0

#define MSG_PEEK 2

#define SO_REUSEADDR 4
#define SOL_SOCKET &hffff

#define WSADESCRIPTION_LEN 256
#define WSASYS_STATUS_LEN 128

type WSAData

	wVersion as ushort
	wHighVersion as ushort
	szDescription as zstring * WSADESCRIPTION_LEN + 1
	szSystemStatus as zstring * WSASYS_STATUS_LEN + 1
	iMaxSockets as ushort
	iMaxUdpDg as ushort
	lpVendorInfo as zstring ptr

end type

type hostent

	h_name as zstring ptr
	h_aliases as zstring ptr ptr
	h_addrtype as short
	h_length as short
	h_addr_list as uinteger ptr ptr

	#define h_addr h_addr_list[0]	

end type

type in_addr_S_un_S_un_w

	s_w1 as ushort
	s_w2 as ushort

end type

type in_addr_S_un_S_un_b

	s_b1 as ubyte
	s_b2 as ubyte
	s_b3 as ubyte
	s_b4 as ubyte

end type

union in_addr

	S_addr as uinteger
	S_un_w as in_addr_S_un_S_un_w
	S_un_b as in_addr_S_un_S_un_b

	#define s_host  S_un_b.s_b2
	#define s_net   S_un_b.s_b1
	#define s_imp   S_un_w.s_w2
	#define s_impno S_un_b.s_b4
	#define s_lh    S_un_b.s_b3

end union

type sockaddr_in

	sin_family as short
	sin_port as ushort
	sin_addr as in_addr
	sin_zero(0 to 7) as byte

end type

type sockaddr

	sa_family as ushort
	sa_data(0 to 13) as byte

end type

enum 
	SHUT_RD = 0
	SHUT_WR
	SHUT_RDWR
end enum

declare function WSAStartup alias "WSAStartup" ( byval as ushort, byval as WSAData ptr ) as integer
declare function WSACleanup alias "WSACleanup" () as integer

declare function socket_ alias "socket" (byval as integer, byval as integer, byval as integer) as uinteger

declare function connect alias "connect" (byval as uinteger, byval as sockaddr ptr, byval as integer) as integer

declare function listen alias "listen" (byval as uinteger, byval as integer) as integer
declare function accept alias "accept" (byval as uinteger, byval as sockaddr ptr, byval as integer ptr) as uinteger
declare function bind alias "bind" (byval as uinteger, byval as sockaddr ptr, byval as integer) as integer

declare function recv alias "recv" (byval as uinteger, byval as zstring ptr, byval as integer, byval as integer) as integer
declare function recvfrom alias "recvfrom" (byval as uinteger, byval as zstring ptr, byval as integer, byval as integer, byval as sockaddr ptr, byval as integer ptr) as integer

declare function send alias "send" (byval as uinteger, byval as zstring ptr, byval as integer, byval as integer) as integer
declare function sendto alias "sendto" (byval as uinteger, byval as zstring ptr, byval as integer, byval as integer, byval as sockaddr ptr, byval as integer) as integer

declare function closesocket alias "closesocket" (byval as uinteger) as integer
declare function shutdown alias "shutdown" (byval as uinteger, byval as integer) as integer

#ifndef timeval
	type timeval
		tv_sec as integer
		tv_usec as integer
	end type
	#define timerisset(tvp)	 (tvp->tv_sec or tvp->tv_usec)
	#define timercmp(tvp, uvp, cmp) iif( tvp->tv_sec <> uvp->tv_sec, tvp->tv_sec cmp uvp->tv_sec, tvp->tv_usec cmp uvp->tv_usec)
	#define timerclear(tvp)	 tvp->tv_sec = 0 : tvp->tv_usec = 0
#endif

#ifndef FD_SETSIZE
	#define FD_SETSIZE 64
#endif

#ifndef fd_set
	type fd_set
		fd_count as uinteger
		fd_array(0 to 64-1) as uinteger
	end type
#endif

declare function __WSAFDIsSet alias "__WSAFDIsSet" (byval as uinteger, byval as fd_set ptr) as integer

#ifndef FD_CLR
	private sub FD_CLR(byval fd as integer, byval set as fd_set ptr)
		for i as uinteger = 0 to set->fd_count-1
			if( set->fd_array( i ) = (fd) ) then
				do while( i < set->fd_count-1 )
					set->fd_array(i) = set->fd_array(i+1)
					i += 1
				loop
			end if
			set->fd_count -= 1
		next
	end sub
#endif

#ifndef FD_SET_
	#macro FD_SET_(fd, set) 
		if( cptr(fd_set ptr, set)->fd_count < FD_SETSIZE ) then
			cptr(fd_set ptr, set)->fd_array(cptr(fd_set ptr, set)->fd_count) = (fd)
			cptr(fd_set ptr, set)->fd_count += 1
		end if
	#endmacro
#endif

#ifndef FD_ZERO
	#define FD_ZERO(set) cptr(fd_set ptr, set)->fd_count= 0
#endif

#ifndef FD_ISSET
	#define FD_ISSET(fd, set) __WSAFDIsSet( cuint(fd), cptr(fd_set ptr, set) )
#endif

declare function select_ alias "select" (byval nfds as integer, byval as fd_set ptr, byval as fd_set ptr, byval as fd_set ptr, byval as timeval ptr) as integer
declare function setsockopt alias "setsockopt" (byval as integer, byval as integer, byval as integer, byval as any ptr, byval as integer) as integer

declare function htons alias "htons" (byval as ushort) as ushort
declare function htonl alias "htonl" (byval as ulong) as ulong
declare function ntohs alias "ntohs" (byval as ushort) as ushort

declare function gethostbyname alias "gethostbyname" (byval as zstring ptr) as hostent ptr
declare function getpeername alias "getpeername" (byval as uinteger, byval as sockaddr ptr, byval as integer ptr) as integer
declare function gethostbyaddr alias "gethostbyaddr" (byval as zstring ptr, byval as integer, byval as integer) as hostent ptr
declare function gethostname alias "gethostname" (byval as zstring ptr, byval as integer) as integer

declare function inet_addr alias "inet_addr" (byval as zstring ptr) as uinteger

declare function WSAGetLastError alias "WSAGetLastError" () as integer
declare function inet_ntoa alias "inet_ntoa" (byval as in_addr) as zstring ptr
#define h_errno WSAGetLastError

#inclib "ws2_32"

