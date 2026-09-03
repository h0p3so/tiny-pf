OTEST = test.o
OTINY = tinypf.o
OXVARGS = xvargs.o
FINAL = tiny-pf
DEBUG_VARS = -g -O0 -fno-omit-frame-pointer
XVARGS_MACROS =

all: $(FINAL)

$(FINAL): $(OXVARGS) $(OTEST) $(OTINY)
	gcc	-g $(OXVARGS) $(OTEST) $(OTINY) -o $(FINAL) -nostartfiles
$(OXVARGS):
	gcc	-c libs/xvargs.S -o $(OXVARGS) $(DEBUG_VARS) $(XVARGS_MACROS)
$(OTEST):
	gcc	-c test.S -o $(OTEST) $(DEBUG_VARS)
$(OTINY):
	gcc	-c tiny-pf.S -o $(OTINY) $(DEBUG_VARS) -DTINY_PF_LONG_BOOL_FMT
clean:
	rm -f $(FINAL) $(OTEST) $(OTINY) $(OXVARGS)
