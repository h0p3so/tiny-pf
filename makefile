otest = test.o
otiny = tinypf.o
oxvargs = xvargs.o
final = tiny-pf

all: $(final)

$(final): $(oxvargs) $(otest) $(otiny)
	ld	$(oxvargs) $(otest) $(otiny) -o $(final)
$(oxvargs):
	gcc	-c xvargs.S -o $(oxvargs) # -DXVARG_SAFE
$(otest):
	gcc	-c test.S -o $(otest)
$(otiny):
	gcc	-c tiny-pf.S -o $(otiny)
clean:
	rm -f $(final) $(otest) $(otiny) $(oxvargs)
