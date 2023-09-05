import express from "express"
import http from "http"
import fs from "fs"
import { Server } from "socket.io"
import * as STATUS from "./util/statuscodes"
import crypto from "crypto"
import Room from "./models/room";
import Session from "./models/session"
import {validator, validatorModels} from "./util/socketValidator"

// Create constants
const app:express.Express = express()
const server:http.Server = http.createServer(app)
const io:Server = new Server(server)
const questions:Array<string> = fs.readFileSync("./questions.txt").toString().split("\n")

// Create variables
var rooms:Array<Room> = []
var sessions:Map<string, Session> = new Map()

// Start express routes
app.use(express.static('web'))

function generateHash(data:string){
    var hash = crypto.createHash("sha512")
    var digest = hash.update(data, "utf-8").digest("hex")
    return digest
}

function getQuestionData(questionId:number){
    var q:string = questions[questionId]
    var answerLength:number = q.match(/\*.+\*/)![0].length - 2
    return {
        questionId: questionId,
        title: q.replace(/\*.+\*/g, "*"),
        answerType: answerLength <= 5? "SHORT":
            answerLength <= 10? "MEDIUM":
            answerLength <= 15? "BIG":
            "SUPER_BIG"
    }
}

io.on("connection", (socket)=>{
    socket.on("search_room", (roomID, ack)=>{
        if(!validator(validatorModels.search_room, [roomID, ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        for(var room of rooms){
            if(room.publicID == roomID){
                ack(STATUS.OK)
                return;
            }
        }
        ack(STATUS.ROOM_NOT_FOUND)
    })
    socket.on("create_room", (ack)=>{
        if(!validator(validatorModels.create_room, [ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var id:string
        while(true){
            id = Math.floor(Math.random() * 1000000).toString()
            let searchResult = rooms.find(x=>x.publicID == id)
            if(searchResult == null) break
        }
        var room:Room = new Room(id, socket.id)
        room.createTeams(4, questions.length)
        rooms.push(room)

        ack(STATUS.OK, {publicID: id})
    })
    socket.on("start_room", (ack)=>{
        if(!validator(validatorModels.start_room, [ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var roomIndex:number = rooms.findIndex((x)=>x.owner.socketid == socket.id)
        if(roomIndex == -1){
            ack(STATUS.ROOM_NOT_FOUND)
            return
        }

        rooms[roomIndex].started = true
        ack(STATUS.OK)

        for(var teamIndex in rooms[roomIndex].teams){
            var team = rooms[roomIndex].teams[teamIndex]
            for(var user of team.users){
                io.to(user.socketid).emit("update_question",{
                    questionData: getQuestionData(team.actualQuestion),
                    cause: STATUS.STARTED_ROOM
                })
            }
        }
        setTimeout(()=>{
            if(!rooms[roomIndex]) return
            rooms[roomIndex].started = false
            for(var team of rooms[roomIndex].teams){
                for(var user of team.users){
                    io.to(user.socketid).emit("room_timeout")
                }
            }
        }, 10*60*1000 + 1)
    })
    socket.on("join_room", (roomID, username, ack)=>{
        if(!validator(validatorModels.join_room, [roomID, username, ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var roomIndex:number = rooms.findIndex((x)=>x.publicID == roomID)
        if(roomIndex == -1){
            ack(STATUS.ROOM_NOT_FOUND)
            return
        }

        if(rooms[roomIndex].started){
            ack(STATUS.STARTED_ROOM)
            return
        }

        rooms[roomIndex].viewers.push({
            name: username,
            socketid: socket.id,
            disconnected: false
        })
        sessions.set(socket.id, {
            room: roomID,
            name: username,
            team: -1
        })

        ack(STATUS.OK)
        io.to(rooms[roomIndex].owner.socketid).emit("new_viewer",{
            name: username,
            userID: generateHash(socket.id),
        })
    })
    socket.on("update_team", (newteam, ack)=>{
        if(!validator(validatorModels.update_team, [newteam, ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var session = sessions.get(socket.id)
        if(!session) {
            ack(STATUS.NOT_JOINED)
            return
        }

        var roomIndex:number = rooms.findIndex((x)=>x.publicID == session!.room)
        if(roomIndex == -1){
            ack(STATUS.ROOM_NOT_FOUND)
            return
        }

        if(rooms[roomIndex].started){
            ack(STATUS.STARTED_ROOM)
            return
        }
        
        newteam = parseInt(newteam)
        if(isNaN(newteam) || newteam < 0 || newteam > rooms[roomIndex].teams.length){
            ack(STATUS.INVALID_TEAM)
            return
        }

        rooms[roomIndex].changeTeam(session.team, {
            name: session.name,
            socketid: socket.id,
            disconnected: false
        }, newteam)
        sessions.set(socket.id, {...session, team: newteam})

        ack(STATUS.OK)
        io.to(rooms[roomIndex].owner.socketid).emit("update_user_team",{
            name: session.name,
            userID: generateHash(socket.id),
            team: newteam
        })
    })

    socket.on("send_answer", (answer, ack)=>{
        if(!validator(validatorModels.send_answer, [answer, ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var session = sessions.get(socket.id)
        if(!session) {
            ack(STATUS.NOT_JOINED)
            return
        }

        var roomIndex:number = rooms.findIndex((x)=>x.publicID == session!.room)
        if(roomIndex == -1){
            ack(STATUS.ROOM_NOT_FOUND)
            return
        }

        if(!rooms[roomIndex].started){
            ack(STATUS.NOT_STARTED_ROOM)
            return
        }

        var userTeam = session.team
        if(userTeam == -1){
            ack(STATUS.NO_TEAM)
            return
        }

        var actualQuestionID = rooms[roomIndex].teams[session.team].actualQuestion
        var rightAnswer = questions[actualQuestionID]
            .toLowerCase()
            .match(/\*.+\*/)![0]
            .replace("*", "")
            .replace("*", "")
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, "")
        var sentAnswer = answer
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, "")
        if(rightAnswer != sentAnswer){
            ack(STATUS.WRONG_QUESTION_ANSWER)
            return
        }

        ack(STATUS.OK)
        var nextQuestion = Math.floor(Math.random()*questions.length)
        rooms[roomIndex].teams[userTeam].actualQuestion = nextQuestion
        for(var user of rooms[roomIndex].teams[userTeam].users){
            io.to(user.socketid).emit("update_question",{
                questionData: getQuestionData(nextQuestion),
                cause: STATUS.ANSWERED_CORRECTLY
            })
        }

        rooms[roomIndex].teams[userTeam].pontuation += 100
        var owner = rooms[roomIndex].owner
        io.to(owner.socketid).emit("update_pontuation", {
            team: userTeam,
            pontuation: rooms[roomIndex].teams[userTeam].pontuation
        })
    })

    socket.on("skip_question", (ack)=>{
        if(!validator(validatorModels.skip_question, [ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var session = sessions.get(socket.id)
        if(!session) {
            ack(STATUS.NOT_JOINED)
            return
        }

        var roomIndex:number = rooms.findIndex((x)=>x.publicID == session!.room)
        if(roomIndex == -1){
            ack(STATUS.ROOM_NOT_FOUND)
            return
        }

        if(!rooms[roomIndex].started){
            ack(STATUS.NOT_STARTED_ROOM)
            return
        }

        var userTeam = session.team
        if(userTeam == -1){
            ack(STATUS.NO_TEAM)
            return
        }

        ack(STATUS.OK)
        var nextQuestion = Math.floor(Math.random()*questions.length)
        rooms[roomIndex].teams[userTeam].actualQuestion = nextQuestion
        for(var user of rooms[roomIndex].teams[userTeam].users){
            io.to(user.socketid).emit("update_question",{
                questionData: getQuestionData(nextQuestion),
                cause: STATUS.SKIPPED_QUESTION
            })
        }

        rooms[roomIndex].teams[userTeam].pontuation -= 50
        var owner = rooms[roomIndex].owner
        io.to(owner.socketid).emit("update_pontuation", {
            team: userTeam,
            pontuation: rooms[roomIndex].teams[userTeam].pontuation
        })
    })

    socket.on("reconnect_user", (lastID, roomID, ack)=>{
        console.log(lastID, roomID)
        if(!validator(validatorModels.reconnect, [lastID, roomID, ack])){
            ack(STATUS.INVALID_REQUEST)
            return
        }

        var roomIndex:number = rooms.findIndex((x)=>x.publicID == roomID)
        if(roomIndex == -1){
            ack(STATUS.ROOM_NOT_FOUND)
            return
        }

        for(var teamIndex in rooms[roomIndex].teams){
            var team = rooms[roomIndex].teams[teamIndex]
            for(var userIndex in team.users){
                var user = team.users[userIndex]
                if(user.socketid != lastID) continue
                if(!user.disconnected){
                    ack(STATUS.RECONNECTION_ON_ONLINE_USER)
                    return 
                }
                rooms[roomIndex].teams[teamIndex].users[userIndex].disconnected = false
                rooms[roomIndex].teams[teamIndex].users[userIndex].socketid = socket.id
                
                sessions.set(socket.id, {
                    team: parseInt(teamIndex),
                    name: user.name,
                    room: roomID
                })
                
                io.to(rooms[roomIndex].owner.socketid).emit("user_reconnected",{
                    oldID: generateHash(lastID),
                    newID: generateHash(socket.id)
                })
                ack(STATUS.OK, {team: parseInt(teamIndex)})
                return
            }
        }
        ack(STATUS.NOT_JOINED)
    })

    socket.on("disconnect_user", ()=>{
        var session = sessions.get(socket.id)
        if(!session) return

        var roomIndex:number = rooms.findIndex((x)=>x.publicID == session!.room)
        if(roomIndex == -1) return
        
        var team = session!.team
        if(team == -1){
            for(var viewerIndex in rooms[roomIndex].viewers){
                var user = rooms[roomIndex].viewers[viewerIndex]
                if(user.socketid != socket.id) continue
                
                io.to(rooms[roomIndex].owner.socketid).emit("user_out",{
                    name: user.name,
                    userID: generateHash(socket.id)
                })
                rooms[roomIndex].viewers[viewerIndex].disconnected = true
            }
        }else{
            for(var userIndex in rooms[roomIndex].teams[team].users){
                var user = rooms[roomIndex].teams[team].users[userIndex]
                if(user.socketid != socket.id) continue
                io.to(rooms[roomIndex].owner.socketid).emit("user_out",{
                    name: user.name,
                    userID: generateHash(socket.id)
                })
                rooms[roomIndex].teams[team].users[userIndex].disconnected = true
            }
        }

        sessions.delete(socket.id)
    })

    socket.on("disconnect", ()=>{
        for(var index in rooms){
            var room = rooms[index]
            var disconnectedOwner = room.owner.socketid == socket.id
            for(var teamIndex in room.teams){
                var team = room.teams[teamIndex]
                for(var userIndex in team.users){
                    var user = team.users[userIndex]
                    if(disconnectedOwner && !user.disconnected){
                        io.to(user.socketid).emit("close_room")
                    }
                    if(user.socketid == socket.id){
                        io.to(room.owner.socketid).emit("user_out",{
                            name: user.name,
                            userID: generateHash(socket.id)
                        })
                        rooms[index].teams[teamIndex].users[userIndex].disconnected = true
                    }
                }
            }
            for(var viewerIndex in room.viewers){
                var user = room.viewers[viewerIndex]
                if(disconnectedOwner){
                    io.to(user.socketid).emit("close_room")
                }
                if(user.socketid == socket.id){
                    io.to(room.owner.socketid).emit("user_out",{
                        name: user.name,
                        userID: generateHash(socket.id)
                    })
                    rooms[index].viewers[viewerIndex].disconnected = true
                }
            }
            if(disconnectedOwner){
                rooms[index].owner.disconnected = true
            }
        }

        rooms = rooms.filter((x)=>!x.owner.disconnected)

        if(sessions.get(socket.id)){
            sessions.delete(socket.id)
        }
    })
})

process.on("uncaughtException", (err, origin)=>{
    console.log("UncaughtException!")
    console.log(err)
    console.log(origin)
})

const port = process.env.PORT || 3000
server.listen(port,()=>{
    console.log(`Running on port ${port}!`)
})