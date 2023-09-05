#!/usr/bin/node

const URL = "http://localhost:3000"
console.log("=".repeat(process.stdout.columns))
console.log("Server URL: "+URL)
console.log("=".repeat(process.stdout.columns))
const io = require("socket.io-client")
const keypress = require("keypress")
keypress(process.stdin)

function join(){
    for(var i = 0; i < 5; i++){
        let userIndex = i+1;
    
        console.log(`[User ${userIndex}] Connecting...`)
        let socket = io(URL);
    
        socket.on("connect", ()=>{
            console.log(`[User ${userIndex}] Connected!`)
            socket.emit("join_room", roomcode, `User ${userIndex}`,(res)=>{
                socket.emit("user.update.team", Math.floor(Math.random() * 4)+1)
            })
        })
    
        socket.on("connect_error", (err)=>{
            console.error("\x1b[31mFailed to connect!\x1b[m")
            process.exit(1)
        })
    }
}

console.log("Type the room code, and press J to start")

var roomcode = ""
process.stdin.on("keypress", (ch, key)=>{
    if(key){
        if(key.name == "j"){
            console.log(roomcode)
            join()
        }
        if(key.ctrl && key.name == "c"){
            process.exit(1)
        }
    }else{
        if(!isNaN(parseInt(ch))){
            roomcode += ch
        }
    }
   
})

process.stdin.setRawMode(true)
process.stdin.resume()