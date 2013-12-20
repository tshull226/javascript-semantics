function mkSend(rawSend) {
  var whiteList = {
    "http://cs.illinois.edu"    : true,
    "http://www.kframework.org" : true
  };
  function newSend(target, msg) {
    if (whiteList[target]) {
      rawSend(target, msg);
    } else {
      console.log("Rejected.");
    }
  };
  return newSend;
}

function simpleSend(target, msg) {
  console.log("Sent " + msg + " to " + target);
}

var send = mkSend(simpleSend);

// Expected scenario
send("http://cs.illinois.edu", "msg"); // Sent msg to http://cs.illinois.edu
send("http://www.evil.com", "msg"); // Rejected.

// Atack 2: implicit coercions
var count = 0;
function fakeTarget() {
  if (count == 0) {
    count = count + 1;
    return "http://cs.illinois.edu";
  } else {
    return "http://www.evil.com";
  }
}
var target = {
  toString : fakeTarget
}
send(target, "msg"); // Sent msg to http://www.evil.com

// Atack 1: redefine Object
Object.prototype["http://www.evil.com"] = true;
send("http://www.evil.com","msg"); // Sent msg to http://www.evil.com
