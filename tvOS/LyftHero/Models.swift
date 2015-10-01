enum LevelError: ErrorType {
    case InvalidInput(String)
}

/**
This structs represents a registered user and the scores for each level.
*/
struct User {
    /// Unique userID, used for logging in/out
    let id: Int

    /// The entered nickname of the user
    let name: String

    /// A map key'ed by level that holds the scores of every level.
    var levelScores: [Int: Int] = [:]

    /// The sum of every level's score
    var score: Int {
        return self.levelScores.values.reduce(0, combine: +)
    }

    init(id: Int, name: String, levelScores: [Int: Int]) {
        self.id = id
        self.name = name
        self.levelScores = levelScores
    }
}

/**
This structs represents the users'ranking. It holds the user array and can be persisted / restored.
*/
struct Scoreboard {

    /// All users participating in the challenge (at least finished level 1).
    var users: [User] = []

    /**
    Inserts a new user into the scoreboard with the given name and scores.
    
    - named: The nickname of the new user
    - scores: The initial user's scores

    - returns: The newly created user.
    */
    mutating func addUser(named nickname: String, scores: [Int: Int]) throws -> User {
        if self.users.contains({ $0.name == nickname }) {
            throw LevelError.InvalidInput("Existing username!, try another one.")
        }

        if nickname.characters.count < 2 {
            throw LevelError.InvalidInput("Nickname \(nickname) is too short.")
        }

        let nextUserID = self.users.reduce(0) { max($0, $1.id) } + 1
        let user = User(id: nextUserID, name: nickname, levelScores: scores)
        self.users.append(user)
        return user
    }
}

/**
Holds the information that the user is currently entering to resolve a level.
*/
struct Session {
    /// The level where this session is being associated.
    let level: UInt?

    /// The last user that made any activity on this session.
    var user: User?

    /// This array is controlled by the level logic itself.
    var data: [Int] = []

    init(level: UInt? = nil, user: User? = nil) {
        self.level = level
        self.user = user
    }
}
