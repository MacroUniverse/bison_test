bison rpcalc.y
cc -Wno-incompatible-pointer-types rpcalc.tab.c -lm -o rpcalc.x

bison calc.y
cc -Wno-incompatible-pointer-types calc.tab.c -lm -o calc.x

bison mfcalc.y --output=mfcalc.cpp
g++ mfcalc.cpp -lm -o mfcalc.x
