MAIN=trace

LFE_EBIN=${HOME}/lfe/ebin/


all: ${MAIN}.beam

${MAIN}.beam: ${MAIN}.lfe
	@erl -noshell -pa ${LFE_EBIN} -eval 'code:load_file(lfe_comp).' -eval 'case lfe_comp:file(hd(init:get_plain_arguments())) of {error,X,AR} -> io:format("~p ~p~n",[X,AR]), halt(1) ; {ok,X,AR} -> io:format("~p ~p~n",[X,AR]), halt(0) end.' -extra ${MAIN}.lfe

start: ${MAIN}.beam
	@erl -noshell -pa ${LFE_EBIN} -eval 'code:load_file(${MAIN}).' -eval '${MAIN}:start().' -s erlang halt

shell:
	@erl  -noshell -pa ${LFE_EBIN} -noinput -eval "user_drv:start(['tty_sl -c -e',{lfe_shell,start,[]}])."


clean:
	@rm -f *.beam *.dump *.out

# syntax-check works only on main file.
# Solution: Work in main, Iron out to sub files. :(
check-syntax:
	@erl -noshell -pa ${LFE_EBIN} -eval 'code:load_file(lfe_comp).' -eval 'File=hd(init:get_plain_arguments()), try lfe_comp:file(File) of {error,X,AR} -> lists:foreach(fun(L)-> {Line,B,Error}=L, io:format("~s:~p: ~p ~p~n",[File,Line,B,Error]) end, X),halt(0) ; {ok,X,AR} -> halt(0); {X,Y,Z} ->  io:format("~p:~p:~p:",[X,Y,Z])  catch X:Y -> io:format("~p:1: Compiler crash ~p ~p ~n",[File,X,Y]), halt(0) end.' -extra ${MAIN}_flymake.lfe 2> err.out

help:
	@echo ";; Copy to .emacs, then restart."
	@echo "(when (load \"flymake\" t)"
	@echo "  (setq flymake-log-level 3)"
	@echo "  (add-hook 'find-file-hook 'flymake-find-file-hook)"
	@echo "  (add-to-list 'flymake-allowed-file-name-masks"
	@echo "	       '(\"\\\\\.lfe\\\\\'\" flymake-simple-make-init)))"
