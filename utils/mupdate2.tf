;;; hook to catch separate lines of input loaded from a file and
;;; concatenate them, then send them to the socket when
;;; encountering . on a line by itself.
;;; (mupdate mode) ... /mupdate on and /mupdate off toggle
;;; automatic functionality.
;;; #mupdate on  and #mupdate off  directives in loaded file 
;;; enable/disable mupdate regardless of /mupdate on|off
;;;  -- QBFreak 01/01/2006
;;; Lines beginning with @@ will not be send
;;;  -- QBFreak 3/11/2017
;;; The remainder of the file after #mupdate ignore will be ignored
;;;  -- QBFreak 3/23/2017

;;; Based on Kareila's zwrite macro (08/30/1998)
;;; See the following pages:
;;;   http://www.chaoticmux.org/~kareila/TF/
;;;   http://www.chaoticmux.org/~kareila/TF/zwrite.txt

/def update = \
	/if (muenable) /set mustatus 1 %; /endif %; \
	/quote -S -dsend -w$[world_info()] 'mare/%1.mare %; \
	/if (mustatus) \
		/send -w$[world_info()] %catch_message %; \
		/unset catch_message %; \
	/endif %; \
	/set mustatus 0 %; \
	/set muignore 0

/def -h"SEND *" sendcatch_hook = \
	/if (!muignore) \
		/if (!mustatus) \
			/if ({*} =/ '#mupdate on') \
				/set mustatus=1 %; \
			/elseif ({*} =/ '#mupdate ignore') \
				/set muignore=1 %; \
			/else \
				/if (strstr({*}, "@@") != 0) \
					/send -w$[world_info()] %* %; \
				/endif %; \
			/endif %; \
		/elseif ({*} =/ '#mupdate off') \
			/set mustatus=0 %; \
		/elseif ({*} =/ '.') \
			/send -w$[world_info()] %catch_message %; \
			/unset catch_message %; \
		/elseif (!(strlen(catch_message))) \
			/if (strstr({*}, "@@") != 0) \
				/set catch_message=%* %; \
			/endif %; \
		/else \
			/if (strstr({*}, "@@") != 0) \
				/set catch_message=$[strcat(catch_message, ' ', {*})] %; \
			/endif %; \
		/endif %; \
	/endif

/def mupdate = \
	/if     ({*} =/ 'on')   /mupdate_on %; \
	/elseif ({*} =/ 'off')  /mupdate_off %; \
	/elseif ({*} =/ 'status')  /mupdate_status %; \
	/elseif ({*} =/ 'kill') /mupdate_kill %; \
	/else /echo %% mupdate: invalid option "%*". %; \
		/echo %% valid options are: on off kill %; \
	/endif

/def mupdate_on = \
	/echo -p @{hu}%% Attention: mupdate mode enabled! \
		Type '/mupdate off' to disable.@{n} %; \
	/set muenable 1

/def mupdate_off = \
	/echo -p @{hu}%% Attention: mupdate mode disabled! \
		Type '/mupdate on' to reenable.@{n} %; \
	/set muenable 0

/def mupdate_kill = \
	/echo -p @{huCred}%% Attention: mupdate mode killed! \
		Reload your config files or restart tf to reenable.@{n} %; \
	/unset mustatus %; \
	/unset muenable %; \
	/unset muignore %; \
	/undef sendcatch_hook %; \
	/undef update %; \
	/purge mupdate*

/def mupdate_status = \
	/echo -p @{hu}%% mupdate enabled: %{muenable} @{n} %; \
	/echo -p @{hu}%% mupdate running: %{mustatus} @{n} %; \
	/echo -p @{hu}%% mupdate ignore:  %{muignore} @{n}

/set mustatus 0
/set muenable 0
/set muignore 0
