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

channel.on("playNote", function({ data }) {
  console.log("PLAY NOTE", data);

  var synth = new Tone.Synth().toMaster();

  //play a middle 'C' for the duration of an 8th note
  synth.triggerAttackRelease(data, "8n");
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
  const { message, data } = JSON.parse(msg);

  switch (message) {
    case "playNote":
      channel.push("playNote", { data });
  }
});

let presence = new Presence(channel);

const transform = (id, ...rest) => {
  console.log(id, "id");
  console.log(rest, "rest");

  return id;
};

presence.onSync(() => {
  const transformedPresences = presence.list(transform);

  app.ports.websocketIn.send({
    message: "users",
    data: transformedPresences
  });
});
