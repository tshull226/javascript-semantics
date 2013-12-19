function add (a) {
  s = s + a;
}
function f() {
  function ff() {
    cnt = cnt + 1;
    gcnt = cnt;
  }
  var cnt;
  cnt = 0;
  g = ff;
}
var g;
var gcnt;
var s;

s = 0;
add(1);
add(2);

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
