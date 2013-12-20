/*
Function.method('curry', function (  ) {
    var args = arguments, that = this;
    return function (  ) {
        return that.apply(null, args.concat(arguments));
    };
});    // Something isn't right...
*/
function curry(b) {
    function specialFunc(c) {
        return that.apply(null,b,c);
    }
    var slice;
	  var args;
	  var that;
	  //slice	= Array.prototype.slice;
	  //slice	= String.prototype.slice;
    //args = slice.apply(arguments);
    that = this;
    return specialFunc;
}
/*
function curry() {
    function specialFunc(  ) {
        return that.apply(null, args.concat(slice.apply(arguments)));
    }
    var slice;
	  var args;
	  var that;
	  //slice	= Array.prototype.slice;
	  slice	= String.prototype.slice;
    args = slice.apply(arguments);
    that = this;
    return specialFunc;
}
*/

function add(a, b) {
    return a + b;

}

var a;
var a1;


Function.prototype.curry =  curry;
a = add;
a1 = a.curry("1");
print(a1("6"));
/*
a1 = a.curry(1);
print(a1(6));
*/

/*
Function.prototype.curry = function () {
    var slice = Array.prototype.slice,
        args = slice.apply(arguments),
        that = this;
    return function (  ) {
        return that.apply(null, args.concat(slice.apply(arguments)));
    };
};

var add = function (a, b) {
    return a + b;
};
var add1 = add.curry(1);
console.log(add1(6));    // 7
*/
