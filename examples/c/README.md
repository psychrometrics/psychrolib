## PsychroLib C example

This is a simple ready-made example showing how to use PsychroLib in a simple program. The purpose of this simple program is to calculate and print to standard output the dew-point temperature from dry-bulb temperature and relative humidity using PsychroLib's `GetTDewPointFromRelHum` function.

### Prerequisites

- [Git](https://git-scm.com/)
- [CMake](https://cmake.org/) version 3.1 or above
- A C compiler supported by CMake and your operating system

### Supported platforms

- Windows
- macOS
- Linux 
- Unix

### How to run this example

From the command prompt, clone [PsychroLib](https://github.com/psychrometrics/psychrolib) and navigate to `examples/c`. 

```
mkdir build && cd build
cmake ..
cmake --build .
```

If the compilation is successful, you can now run the example program: `example.exe`, or `example` on Unix/Unix-like systems. The output will be `21.30[...]` where `[...]` indicates extra significant digits.