"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
const fs_1 = __importDefault(require("fs"));
const socket_io_1 = require("socket.io");
const STATUS = __importStar(require("./util/statuscodes"));
const crypto_1 = __importDefault(require("crypto"));
const room_1 = __importDefault(require("./models/room"));
const socketValidator_1 = require("./util/socketValidator");
// Create constants
const app = (0, express_1.default)();
const server = http_1.default.createServer(app);
const io = new socket_io_1.Server(server);
const questions = fs_1.default.readFileSync("./questions.txt").toString().split("\n");
// Create variables
var rooms = [];
var sessions = new Map();
// Start express routes
app.use(express_1.default.static('web'));
function generateHash(data) {
    var hash = crypto_1.default.createHash("sha512");
    var digest = hash.update(data, "utf-8").digest("hex");
    return digest;
}
function getQuestionData(questionId) {
    var q = questions[questionId];
    var answerLength = q.match(/\*.+\*/)[0].length - 2;
    return {
        questionId: questionId,
        title: q.replace(/\*.+\*/g, "*"),
        answerType: answerLength <= 5 ? "SHORT" :
            answerLength <= 10 ? "MEDIUM" :
                answerLength <= 15 ? "BIG" :
                    "SUPER_BIG"
    };
}
io.on("connection", (socket) => {
    socket.on("search_room", (roomID, ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.search_room, [roomID, ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        for (var room of rooms) {
            if (room.publicID == roomID) {
                ack(STATUS.OK);
                return;
            }
        }
        ack(STATUS.ROOM_NOT_FOUND);
    });
    socket.on("create_room", (ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.create_room, [ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var id;
        while (true) {
            id = Math.floor(Math.random() * 1000000).toString();
            let searchResult = rooms.find(x => x.publicID == id);
            if (searchResult == null)
                break;
        }
        var room = new room_1.default(id, socket.id);
        room.createTeams(4, questions.length);
        rooms.push(room);
        ack(STATUS.OK, { publicID: id });
    });
    socket.on("start_room", (ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.start_room, [ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var roomIndex = rooms.findIndex((x) => x.owner.socketid == socket.id);
        if (roomIndex == -1) {
            ack(STATUS.ROOM_NOT_FOUND);
            return;
        }
        rooms[roomIndex].started = true;
        ack(STATUS.OK);
        for (var teamIndex in rooms[roomIndex].teams) {
            var team = rooms[roomIndex].teams[teamIndex];
            for (var user of team.users) {
                io.to(user.socketid).emit("update_question", {
                    questionData: getQuestionData(team.actualQuestion),
                    cause: STATUS.STARTED_ROOM
                });
            }
        }
        setTimeout(() => {
            if (!rooms[roomIndex])
                return;
            rooms[roomIndex].started = false;
            for (var team of rooms[roomIndex].teams) {
                for (var user of team.users) {
                    io.to(user.socketid).emit("room_timeout");
                }
            }
        }, 10 * 60 * 1000 + 1);
    });
    socket.on("join_room", (roomID, username, ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.join_room, [roomID, username, ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var roomIndex = rooms.findIndex((x) => x.publicID == roomID);
        if (roomIndex == -1) {
            ack(STATUS.ROOM_NOT_FOUND);
            return;
        }
        if (rooms[roomIndex].started) {
            ack(STATUS.STARTED_ROOM);
            return;
        }
        rooms[roomIndex].viewers.push({
            name: username,
            socketid: socket.id,
            disconnected: false
        });
        sessions.set(socket.id, {
            room: roomID,
            name: username,
            team: -1
        });
        ack(STATUS.OK);
        io.to(rooms[roomIndex].owner.socketid).emit("new_viewer", {
            name: username,
            userID: generateHash(socket.id),
        });
    });
    socket.on("update_team", (newteam, ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.update_team, [newteam, ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var session = sessions.get(socket.id);
        if (!session) {
            ack(STATUS.NOT_JOINED);
            return;
        }
        var roomIndex = rooms.findIndex((x) => x.publicID == session.room);
        if (roomIndex == -1) {
            ack(STATUS.ROOM_NOT_FOUND);
            return;
        }
        if (rooms[roomIndex].started) {
            ack(STATUS.STARTED_ROOM);
            return;
        }
        newteam = parseInt(newteam);
        if (isNaN(newteam) || newteam < 0 || newteam > rooms[roomIndex].teams.length) {
            ack(STATUS.INVALID_TEAM);
            return;
        }
        rooms[roomIndex].changeTeam(session.team, {
            name: session.name,
            socketid: socket.id,
            disconnected: false
        }, newteam);
        sessions.set(socket.id, Object.assign(Object.assign({}, session), { team: newteam }));
        ack(STATUS.OK);
        io.to(rooms[roomIndex].owner.socketid).emit("update_user_team", {
            name: session.name,
            userID: generateHash(socket.id),
            team: newteam
        });
    });
    socket.on("send_answer", (answer, ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.send_answer, [answer, ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var session = sessions.get(socket.id);
        if (!session) {
            ack(STATUS.NOT_JOINED);
            return;
        }
        var roomIndex = rooms.findIndex((x) => x.publicID == session.room);
        if (roomIndex == -1) {
            ack(STATUS.ROOM_NOT_FOUND);
            return;
        }
        if (!rooms[roomIndex].started) {
            ack(STATUS.NOT_STARTED_ROOM);
            return;
        }
        var userTeam = session.team;
        if (userTeam == -1) {
            ack(STATUS.NO_TEAM);
            return;
        }
        var actualQuestionID = rooms[roomIndex].teams[session.team].actualQuestion;
        var rightAnswer = questions[actualQuestionID]
            .toLowerCase()
            .match(/\*.+\*/)[0]
            .replace("*", "")
            .replace("*", "")
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, "");
        var sentAnswer = answer
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, "");
        if (rightAnswer != sentAnswer) {
            ack(STATUS.WRONG_QUESTION_ANSWER);
            return;
        }
        ack(STATUS.OK);
        var nextQuestion = Math.floor(Math.random() * questions.length);
        rooms[roomIndex].teams[userTeam].actualQuestion = nextQuestion;
        for (var user of rooms[roomIndex].teams[userTeam].users) {
            io.to(user.socketid).emit("update_question", {
                questionData: getQuestionData(nextQuestion),
                cause: STATUS.ANSWERED_CORRECTLY
            });
        }
        rooms[roomIndex].teams[userTeam].pontuation += 100;
        var owner = rooms[roomIndex].owner;
        io.to(owner.socketid).emit("update_pontuation", {
            team: userTeam,
            pontuation: rooms[roomIndex].teams[userTeam].pontuation
        });
    });
    socket.on("skip_question", (ack) => {
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.skip_question, [ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var session = sessions.get(socket.id);
        if (!session) {
            ack(STATUS.NOT_JOINED);
            return;
        }
        var roomIndex = rooms.findIndex((x) => x.publicID == session.room);
        if (roomIndex == -1) {
            ack(STATUS.ROOM_NOT_FOUND);
            return;
        }
        if (!rooms[roomIndex].started) {
            ack(STATUS.NOT_STARTED_ROOM);
            return;
        }
        var userTeam = session.team;
        if (userTeam == -1) {
            ack(STATUS.NO_TEAM);
            return;
        }
        ack(STATUS.OK);
        var nextQuestion = Math.floor(Math.random() * questions.length);
        rooms[roomIndex].teams[userTeam].actualQuestion = nextQuestion;
        for (var user of rooms[roomIndex].teams[userTeam].users) {
            io.to(user.socketid).emit("update_question", {
                questionData: getQuestionData(nextQuestion),
                cause: STATUS.SKIPPED_QUESTION
            });
        }
        rooms[roomIndex].teams[userTeam].pontuation -= 50;
        var owner = rooms[roomIndex].owner;
        io.to(owner.socketid).emit("update_pontuation", {
            team: userTeam,
            pontuation: rooms[roomIndex].teams[userTeam].pontuation
        });
    });
    socket.on("reconnect_user", (lastID, roomID, ack) => {
        console.log(lastID, roomID);
        if (!(0, socketValidator_1.validator)(socketValidator_1.validatorModels.reconnect, [lastID, roomID, ack])) {
            ack(STATUS.INVALID_REQUEST);
            return;
        }
        var roomIndex = rooms.findIndex((x) => x.publicID == roomID);
        if (roomIndex == -1) {
            ack(STATUS.ROOM_NOT_FOUND);
            return;
        }
        for (var teamIndex in rooms[roomIndex].teams) {
            var team = rooms[roomIndex].teams[teamIndex];
            for (var userIndex in team.users) {
                var user = team.users[userIndex];
                if (user.socketid != lastID)
                    continue;
                if (!user.disconnected) {
                    ack(STATUS.RECONNECTION_ON_ONLINE_USER);
                    return;
                }
                rooms[roomIndex].teams[teamIndex].users[userIndex].disconnected = false;
                rooms[roomIndex].teams[teamIndex].users[userIndex].socketid = socket.id;
                sessions.set(socket.id, {
                    team: parseInt(teamIndex),
                    name: user.name,
                    room: roomID
                });
                io.to(rooms[roomIndex].owner.socketid).emit("user_reconnected", {
                    oldID: generateHash(lastID),
                    newID: generateHash(socket.id)
                });
                ack(STATUS.OK, { team: parseInt(teamIndex) });
                return;
            }
        }
        ack(STATUS.NOT_JOINED);
    });
    socket.on("disconnect_user", () => {
        var session = sessions.get(socket.id);
        if (!session)
            return;
        var roomIndex = rooms.findIndex((x) => x.publicID == session.room);
        if (roomIndex == -1)
            return;
        var team = session.team;
        if (team == -1) {
            for (var viewerIndex in rooms[roomIndex].viewers) {
                var user = rooms[roomIndex].viewers[viewerIndex];
                if (user.socketid != socket.id)
                    continue;
                io.to(rooms[roomIndex].owner.socketid).emit("user_out", {
                    name: user.name,
                    userID: generateHash(socket.id)
                });
                rooms[roomIndex].viewers[viewerIndex].disconnected = true;
            }
        }
        else {
            for (var userIndex in rooms[roomIndex].teams[team].users) {
                var user = rooms[roomIndex].teams[team].users[userIndex];
                if (user.socketid != socket.id)
                    continue;
                io.to(rooms[roomIndex].owner.socketid).emit("user_out", {
                    name: user.name,
                    userID: generateHash(socket.id)
                });
                rooms[roomIndex].teams[team].users[userIndex].disconnected = true;
            }
        }
        sessions.delete(socket.id);
    });
    socket.on("disconnect", () => {
        for (var index in rooms) {
            var room = rooms[index];
            var disconnectedOwner = room.owner.socketid == socket.id;
            for (var teamIndex in room.teams) {
                var team = room.teams[teamIndex];
                for (var userIndex in team.users) {
                    var user = team.users[userIndex];
                    if (disconnectedOwner && !user.disconnected) {
                        io.to(user.socketid).emit("close_room");
                    }
                    if (user.socketid == socket.id) {
                        io.to(room.owner.socketid).emit("user_out", {
                            name: user.name,
                            userID: generateHash(socket.id)
                        });
                        rooms[index].teams[teamIndex].users[userIndex].disconnected = true;
                    }
                }
            }
            for (var viewerIndex in room.viewers) {
                var user = room.viewers[viewerIndex];
                if (disconnectedOwner) {
                    io.to(user.socketid).emit("close_room");
                }
                if (user.socketid == socket.id) {
                    io.to(room.owner.socketid).emit("user_out", {
                        name: user.name,
                        userID: generateHash(socket.id)
                    });
                    rooms[index].viewers[viewerIndex].disconnected = true;
                }
            }
            if (disconnectedOwner) {
                rooms[index].owner.disconnected = true;
            }
        }
        rooms = rooms.filter((x) => !x.owner.disconnected);
        if (sessions.get(socket.id)) {
            sessions.delete(socket.id);
        }
    });
});
process.on("uncaughtException", (err, origin) => {
    console.log("UncaughtException!");
    console.log(err);
    console.log(origin);
});
const port = process.env.PORT || 3000;
server.listen(port, () => {
    console.log(`Running on port ${port}!`);
});
