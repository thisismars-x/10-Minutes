const std = @import("std");

// error traces do not pay the price of unwinding the stack
// error return traces show every where an error occurred on 
// calling some function
//
// this makes calling try more practical and still know
// every point where errors occur
//
// https://ziglang.org/documentation/master/#Error-Return-Traces

const err = error {
    ErrorTrace,
    StackTrace,
};

pub fn main() !void {
    try x();
}

fn x() !void{
    try y();
}

fn y() !void{
    try z();
}

fn z() !void{
    try a();
}

fn a() !void{
    try b();
}

fn b() !void{
    return err.ErrorTrace;
}


