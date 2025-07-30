bison calc.y
cc -Wno-incompatible-pointer-types calc.tab.c -lm -o calc.x

bison rpcalc.y --output=rpcalc.c
cc -Wno-incompatible-pointer-types rpcalc.c -lm -o rpcalc.x

bison mfcalc.y --output=mfcalc.cpp

# #line mark will disrup CLion break point
sed -i 's/^#line/\/\/ #line/'  mfcalc.cpp 

g++ -g mfcalc.cpp -lm -o mfcalc.x
