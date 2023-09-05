"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class Room {
    constructor(publicID, ownerID) {
        this.started = false;
        this.teams = [];
        this.viewers = [];
        this.publicID = publicID;
        this.owner = { socketid: ownerID, name: "", disconnected: false };
    }
    createTeams(amount, questionAmount) {
        for (var c = 0; c < amount; c++) {
            this.teams.push({
                users: [],
                pontuation: 0,
                actualQuestion: Math.floor(Math.random() * questionAmount)
            });
        }
    }
    changeTeam(oldTeam, user, newTeam) {
        if (oldTeam == -1) {
            this.viewers = this.viewers
                .filter(x => x.socketid != user.socketid);
        }
        else {
            this.teams[oldTeam].users = this.teams[oldTeam].users
                .filter(x => x.socketid != user.socketid);
        }
        if (newTeam == -1) {
            this.viewers.push(user);
        }
        else {
            this.teams[newTeam].users.push(user);
        }
    }
}
exports.default = Room;
