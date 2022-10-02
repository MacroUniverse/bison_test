bison rpcalc.y
cc rpcalc.tab.c -lm -o rpcalc

bison calc.y
cc calc.tab.c -lm -o calc

bison mfcalc.y
cc mfcalc.tab.c -lm -o mfcalc
