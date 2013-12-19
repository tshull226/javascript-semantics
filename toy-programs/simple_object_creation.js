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
function Point(){
    this.x = "x";
    this.y = "y";
    }
var g;
var gcnt;
var s;
var p;
/*
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
print(gcnt);*/
p = new Point();
print(p.x);
print(p.y);
