bison calc.y
cc -Wno-incompatible-pointer-types calc.tab.c -lm -o calc

bison rpcalc.y --output=rpcalc.c
cc -Wno-incompatible-pointer-types rpcalc.c -lm -o rpcalc

bison mfcalc.y --output=mfcalc.cpp
g++ mfcalc.cpp -lm -o mfcalc
