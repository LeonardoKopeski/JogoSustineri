cd ~/Documentos/Projetos/sustineri/server
echo "Building..."
tsc
cp questions.txt ../build/questions.txt
cd ~/Documentos/Projetos/sustineri/build
echo "Starting..."
node index.js