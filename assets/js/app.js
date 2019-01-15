// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import Tone from "tone";
import { Presence } from "phoenix";
import socket from "./socket";
import { Elm } from "../elm/src/Main.elm";

const channel = socket.channel("room:lobby", {}); // connect to chat "room"
const elmDiv = document.getElementById("elm-main");

let app = Elm.Main.init({ node: elmDiv });

channel.on("shout", function({ msg }) {
  console.log("INCOMING", msg);

  app.ports.websocketIn.send(
    JSON.stringify({ data: msg, timeStamp: new Date() })
  );

  var synth = new Tone.Synth().toMaster();

  //play a middle 'C' for the duration of an 8th note
  synth.triggerAttackRelease(msg, "8n");
});

channel.on("join", () => {
  console.log("joined room");
});

channel
  .join() // join the channel.
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
    // app.ports.websocketIn.send(
    //   JSON.stringify({ data: "you joined", timeStamp: new Date() })
    // );
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });

app.ports.websocketOut.subscribe(function(msg) {
  channel.push("shout", {
    msg
    // send the message to the server on "shout" channel
    // name: 'name', // get value of "name" of person sending the message
    // message: 'message', // get message text (value) from msg input field.
  });
});

let presences = {};
channel.on("presence_state", state => {
  presences = Presence.syncState(presences, state);
  console.log("presence state", presences);
  //   renderOnlineUsers(presences);
});

const replaceQuickAndEasyMap = data => {
  return data.map(presence => presence.metas.map(meta => meta.uuid));
};

function flattenDeep(arr1) {
  return arr1.reduce((acc, val) => Array.isArray(val) ? acc.concat(flattenDeep(val)) : acc.concat(val), []);
}

channel.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff);
  console.log("presence diff", presences);

  console.log(Presence.list(presences));

  const transformPresences = replaceQuickAndEasyMap(Presence.list(presences))
  const flattenedPresences = flattenDeep(transformPresences)

  app.ports.websocketIn.send({
    message: "users",
    data: flattenedPresences //users
  });
});
