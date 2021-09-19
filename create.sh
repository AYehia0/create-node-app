#!/bin/bash

# a simple script to create a NodeJS working dir for creating backend apps

# creating the dirs
rootdir_list=("models/db.js" "models/user.js" "routes/userRoutes.js" "controller/userController.js")
rootfile_list=("app.js" "server.js" ".env")
packages=("dotenv" "express" "mongoose" "bcryptjs" "cors" "validator")

# env content
env_contents='PORT=8080\nDBURL=mongodb://localhost:27017/dbname'

# Main app.js
app='
const express = require("express")\n
const app = express()\n
const userRouter = require("./routes/userRoutes")\n

// to get a process running at a port\n
// npx kill-port PORT\n
// middlewares for accepting json response\n
app.use(express.json())\n
app.use(express.urlencoded({extended: true}))\n

// using the routes\n
app.use(userRouter)\n
module.exports = app\n'

user_route="
// the controller for the routes\n
const router = require('express').Router()\n
const con = require('../controller/userController')\n

// the main route for testing only\n
router.get('/', con.main)\n

module.exports = router\n"

server='
require("dotenv").config()\n
const app = require("./app")\n
const PORT = process.env.PORT || 8080\n

// listening to the port\n
app.listen(PORT, () => console.log(`Listening on port : ${PORT}`))\n
'

controller='
// the user model\n
const User = require("../models/user")\n

// the main route GET; for testing only\n
const main = (req, res, err) => {\n
    res.status(200).json("hello server")\n
}\n

// exporting the callbacks\n
module.exports = {\n
    main\n
}\n
'

model='
require("./db")\n
const mongoose = require("mongoose")\n
const Schema = mongoose.Schema\n
const validator = require("validator")\n
'

db='
// serving the database by creating the connection\n
const mongoose = require("mongoose")\n

// creating the connection \n
mongoose.connect(process.env.DBURL, {\n
    useNewUrlParser: true, \n
    useUnifiedTopology: true,\n
    autoIndex: true\n
}).catch(e => {\n
    console.log(e.message)\n
})\n
'

# Installing the packages
function install_npm () {
    npm install ${packages[*]}
}

# looping through the list and perform a command
function loop () {
    # looping through the list and create dirs
    local comd="${1}"

    # removing the first param from the list
    shift 1 

    list=$@
    for item in ${list[*]}
        do
            # getting the file name
            eval $comd $item
        done
}

# thanks to askubuntu : https://askubuntu.com/a/1025160
# no splitting is needed : echo "something/shit" | cut -d '/'
mkfile() { 
    mkdir -p "$(dirname "$1")" && touch "$1";  
}   

# looping through the list and perform a command
function create_dirs () {

    list=$@
    for item in ${list[*]}
        do
            # getting the file name
            mkfile $item
        done
}

# installing the packages
#install_npm

# creating the root files 
loop $"touch" ${rootfile_list[@]} 

# creating the dirs
create_dirs ${rootdir_list[@]} 

# there must be a better way like 2 arrays or something idk i wanna sleep :(
# adding to files
echo -e $app > "app.js"
echo -e $env_contents > ".env"
echo -e $server > "server.js"

# adding to files
echo -e $db > "models/db.js"
echo -e $model > "models/user.js"
echo -e $controller > "controller/userController.js"
echo -e $user_route > "routes/userRoutes.js"

