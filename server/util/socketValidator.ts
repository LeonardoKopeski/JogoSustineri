export function validator(expected:Array<any>, given:Array<any>){
    for(var key in expected){
        if(expected[key] instanceof RegExp){
            if(!expected[key].test(given[key])) return false
        }else{
            if(typeof given[key] != expected[key]) return false
        }
    }
    return true
}

export const validatorModels = {
    "search_room": [/^\d{0,6}$/, "function"],
    "create_room": ["function"],
    "start_room": ["function"],
    "join_room": [/^\d{0,6}$/, /^\S+$/, "function"],
    "update_team": [/^\d+$/, "function"],
    "send_answer": [/^.+$/, "function"],
    "skip_question": ["function"],
    "reconnect": [/.*/, /^\d{0,6}$/, "function"]
}