rm -fr ./build/*
cd server
tsc
cp questions.txt ../build/questions.txt
cd ../client
flutter build web
cp -r ./build/web ../build/web
cd ../build
npm install express socket.io crypto fs http
cd ..
echo "change URL!!!!!!"