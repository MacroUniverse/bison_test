bison rpcalc.y
cc -Wno-incompatible-pointer-types rpcalc.tab.c -lm -o rpcalc

bison calc.y
cc -Wno-incompatible-pointer-types calc.tab.c -lm -o calc

bison mfcalc.y
cc -Wno-incompatible-pointer-types mfcalc.tab.c -lm -o mfcalc
