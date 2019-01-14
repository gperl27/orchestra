// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.css';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from './socket';
var channel = socket.channel('room:lobby', {}); // connect to chat "room"

// channel.on('shout', function (payload) {
//     // listen to the 'shout' event
//     var li = document.createElement('li'); // creaet new list item DOM element
//     var name = payload.name || 'guest'; // get name from payload or set default
//     li.innerHTML = '<b>' + name + '</b>: ' + payload.message; // set li contents
//     ul.appendChild(li); // append to list
// });


// var ul = document.getElementById('msg-list'); // list of messages.
// var name = document.getElementById('name'); // name of message sender
// var msg = document.getElementById('msg'); // message input field

// // "listen" for the [Enter] keypress event to send a message:
// msg.addEventListener('keypress', function(event) {
//   if (event.keyCode == 13 && msg.value.length > 0) {
//     // don't sent empty msg.
// channel.push('shout', {
//   // send the message to the server on "shout" channel
//   name: name.value, // get value of "name" of person sending the message
//   message: msg.value, // get message text (value) from msg input field.
// });
//     msg.value = ''; // reset the message input field for next message.
//   }
// });
import { Elm } from "../elm/src/Main.elm"

const elmDiv = document.getElementById("elm-main");
let app = Elm.Main.init({ node: elmDiv });

channel.on('shout', function ({ msg }) {
    console.log('INCOMING', msg)

    app.ports.websocketIn.send(JSON.stringify({ data: msg, timeStamp: new Date() }));
})

channel.join() // join the channel.
    .receive("ok", resp => {
        console.log("Joined successfully", resp)
        app.ports.websocketIn.send(JSON.stringify({ data: 'you joined', timeStamp: new Date() }));
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

app.ports.websocketOut.subscribe(function (msg) {
    console.log(msg, 'msg')

    channel.push('shout', {
        msg
        // send the message to the server on "shout" channel
        // name: 'name', // get value of "name" of person sending the message
        // message: 'message', // get message text (value) from msg input field.
    });
})

