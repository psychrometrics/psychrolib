## PsychroLib Python example

This is a simple ready-made example showing how to use PsychroLib in a simple program. The purpose of this simple program is to calculate and print to standard output the dew-point temperature from dry-bulb temperature and relative humidity using PsychroLib's `GetTDewPointFromRelHum` function.

### Prerequisites

- [Git](https://git-scm.com/)
- [Python](https://www.python.org/) version 3.6 or above
- The latest version of PsychroLib installed on your system (otherwise install it with `pip install psychrolib`)

### Supported platforms

- Windows
- macOS
- Linux 
- Unix

### How to run this example

From the command prompt, clone [PsychroLib](https://github.com/psychrometrics/psychrolib) and navigate to `examples/python`. Then run the example program:

```
python example.py
```

The output will be:

```
TDewPoint: 21.309397163661785 degree C
```