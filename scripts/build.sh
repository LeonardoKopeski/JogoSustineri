rm -fr ./build/*
cd ~/Documentos/Projetos/sustineri/server
tsc
cp questions.txt ../build/questions.txt
cd ~/Documentos/Projetos/sustineri/client
flutter build web
cp -r ~/Documentos/Projetos/sustineri/client/build/web ~/Documentos/Projetos/sustineri/build/web
cd ~/Documentos/Projetos/sustineri/build
npm install express socket.io crypto fs http