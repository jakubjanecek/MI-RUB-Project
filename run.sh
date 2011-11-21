#!/bin/bash

echo "Parsing&running Program1.pas"
ruby ./bin/pascalparser.rb ./test/Program1.pas ./out/Program1.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program1.jasmin
cd out
java Program1
cd ..
echo
echo

echo "Parsing&running Program2.pas"
ruby ./bin/pascalparser.rb ./test/Program2.pas ./out/Program2.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program2.jasmin
cd out
java Program2
cd ..
echo
echo

echo "Parsing&running Program3.pas"
ruby ./bin/pascalparser.rb ./test/Program3.pas ./out/Program3.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program3.jasmin
cd out
java Program3
cd ..
echo
echo

echo "Parsing&running Program4.pas"
ruby ./bin/pascalparser.rb ./test/Program4.pas ./out/Program4.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program4.jasmin
cd out
java Program4
cd ..
echo
echo

echo "Parsing&running Program5.pas"
ruby ./bin/pascalparser.rb ./test/Program5.pas ./out/Program5.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program5.jasmin
cd out
java Program5
cd ..
echo
echo

echo "Parsing&running Program6.pas"
ruby ./bin/pascalparser.rb ./test/Program6.pas ./out/Program6.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program6.jasmin
cd out
java Program6
cd ..
echo
echo

echo "Parsing&running Program7.pas"
ruby ./bin/pascalparser.rb ./test/Program7.pas ./out/Program7.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program7.jasmin
cd out
java Program7
cd ..
echo
echo

echo "Parsing&running Program8.pas"
ruby ./bin/pascalparser.rb ./test/Program8.pas ./out/Program8.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program8.jasmin
cd out
java Program8
cd ..
echo
echo

echo "Parsing&running Program9.pas"
ruby ./bin/pascalparser.rb ./test/Program9.pas ./out/Program9.jasmin
java -jar ./lib/jasmin.jar -d ./out/ ./out/Program9.jasmin
cd out
java Program9
cd ..
echo
echo