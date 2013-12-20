function Point(x,y) {
	this.x = x;
	this.y = y;
}
function Animal(x){
	this.x = x;
}
function callX(){
	print(this.x);
	print("\n");
}
var p1;
var p2;
var a1;
var a2;
var x;

x = "something";
Point.prototype.printX = callX;
Animal.prototype.noise = callX;
p1 = new Point("p1X","p1Y");
a1 = new Animal("grr");
Animal.prototype = p1;
a2 = new Animal("bark");
print(p1.x);
print("\n");
print(p1.y);
print("\n");
callX();
p1.printX();
a1.noise();
a2.printX();
