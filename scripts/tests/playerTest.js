#!/usr/bin/node

const URL = "https://sustineri.onrender.com"//"http://localhost:3000"
console.log("=".repeat(process.stdout.columns))
console.log("Server URL: "+URL)
console.log("=".repeat(process.stdout.columns))

const keypress = require("keypress")
keypress(process.stdin)

const io = require("socket.io-client")
console.log("Connecting...")
const socket = io(URL);

socket.on("connect", ()=>{
    console.log("Connected!")
    console.log("")
    console.log("Press \x1b[34mS\x1b[m to start room")
    console.log("")
    socket.emit("create_room",(status, {publicID})=>{
        console.log("The public ID is "+publicID)
    })
    socket.on("new_viewer", ({name, userID})=>{
        console.log(`New user connected: ${name}(${userID})`)
    })
    socket.on("user_out", ({name, userID})=>{
        console.log(`User disconnected: ${name}(${userID})`)
    })
    socket.on("update_user_team", ({team, userID})=>{
        console.log(`User ${userID} set team to ${team}`)
    })
    socket.on("update_pontuation", ({team, pontuation})=>{
        console.log(team, pontuation)
    })
})

socket.on("connect_error", (err)=>{
    console.error("\x1b[31mFailed to connect!\x1b[m")
    process.exit(1)
})

process.stdin.on("keypress", (ch, key)=>{
    if(key.name == "s"){
        socket.emit("start_room",(status)=>{
            console.log("Room start response: "+status)
        })
    }
    if(key.ctrl && key.name == "c"){
        process.exit(1)
    }
})

process.stdin.setRawMode(true)
process.stdin.resume()
