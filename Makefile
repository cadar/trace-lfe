MAIN=trace

LFE_EBIN=${HOME}/lfe/ebin/


all: ${MAIN}.beam

${MAIN}.beam: ${MAIN}.lfe
	@erl -noshell -pa ${LFE_EBIN} -eval 'code:load_file(lfe_comp).' -eval 'lfe_comp:file(hd(init:get_plain_arguments())), halt(0).' -extra ${MAIN}.lfe

start: ${MAIN}.beam
	@erl -noshell -pa ${LFE_EBIN} -eval 'code:load_file(${MAIN}).' -eval '${MAIN}:start().' -s erlang halt

shell:
	@erl -pa ${LFE_EBIN} -noshell -noinput -s lfe_boot start

clean:
	@rm -f *.beam *.dump *.out *.err

# syntax-check works only on main file.
# Solution: Work in main, Iron out to sub files. :(
check-syntax:
	@erl -noshell -pa ${LFE_EBIN} \
	-eval 'code:load_file(lfe_comp).' \
	-eval 'File=hd(init:get_plain_arguments()), try lfe_comp:file(File) of {ok,_Module} -> halt(0); error -> halt(0); All ->  io:format("./~s:1: ~p~n",[File,All]) catch X:Y -> io:format("~p:1: Makefile error: ~p ~p ~n",[File,X,Y]) end, halt(0).' \
	-extra ${MAIN}_flymake.lfe 2> compile.err | tee compile.out
	rm ${MAIN}_flymake.beam

help:
	@echo ";; Copy to .emacs, then restart."
	@echo "(when (load \"flymake\" t)"
	@echo "  (setq flymake-log-level 3)"
	@echo "  (add-hook 'find-file-hook 'flymake-find-file-hook)"
	@echo "  (add-to-list 'flymake-allowed-file-name-masks"
	@echo "	       '(\"\\\\\.lfe\\\\\'\" flymake-simple-make-init)))"
