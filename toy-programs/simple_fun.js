var s = 0;
function add (a) {
  s = s + a;
}
add(1);
add(2);


var g;
var gcnt;
function f() {
  var cnt = 0;
  function ff() {
    cnt = cnt + 1;
    gcnt = cnt;
  }
  g = ff;
}

f();
g(); // cnt == 1
print(gcnt);
g(); // cnt == 2
print(gcnt);

f();
g(); // cnt == 1
print(gcnt);
g(); // cnt == 2
print(gcnt);
