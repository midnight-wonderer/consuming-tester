# Consuming Tester

## What is it?

Consuming Tester is a one-size-fits-all build system for reusable C components.  
As the name suggested, it is originally developed for consumer testing.

## Why?

Prior to creating consuming tester, I authored a bunch of embedded system software. (e.g. [Button Debounce](https://github.com/the-cave/button-debounce/))  
Most of my libraries are processor and platform agnostic, it can work anywhere as long as C language works,
but I tend to include the build script for the platform that I, at that moments, was working for.  
It would be better to include a build system for Unix-like operating systems so people can test the software right away on their PC,
rather than stock-piling the specific CPU that I used for the software development.  
So, Consuming Tester was born.

## Prerequisites

* [GNU Compiler Collection](https://gcc.gnu.org/)
* [GNU Make](https://www.gnu.org/software/make/)

## Usages

- Include the Makefile of this repository into your Makefile  
(git-submodule is highly recommended)
- Configure some variables
- Profits

Examples
- TODO

## License

Consuming Tester is released under the [MIT License](LICENSE.md). :tada: