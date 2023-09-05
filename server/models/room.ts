export default class Room{
    publicID:string;
    started:boolean = false;
    teams:Array<Team> = [];
    viewers:Array<User> = [];
    owner:User; 

    constructor(publicID:string, ownerID:string){
        this.publicID = publicID;
        this.owner = {socketid: ownerID, name: "", disconnected: false}
    }

    createTeams(amount:number, questionAmount:number){
        for(var c = 0; c < amount; c++){
            this.teams.push({
                users: [],
                pontuation: 0,
                actualQuestion: Math.floor(Math.random()*questionAmount)
            })
        }
    }

    changeTeam(oldTeam:number, user:User, newTeam:number){
        if(oldTeam == -1){
            this.viewers = this.viewers
                .filter(x=>x.socketid != user.socketid)
        }else{
            this.teams[oldTeam].users = this.teams[oldTeam].users
                .filter(x=>x.socketid != user.socketid)
        }

        if(newTeam == -1){
            this.viewers.push(user)
        }else{
            this.teams[newTeam].users.push(user)
        }
    }
}

interface Team{
    users: Array<User>
    pontuation: number
    actualQuestion: number
}

interface User{
    socketid: string
    name: string
    disconnected: boolean
}