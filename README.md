# graph-calculator
<sup>1</sup> alikhan.baidussenov@nu.edu.kz  
<sup>2</sup> sanzhar.mazhit@nu.edu.kz  
<sup>3</sup> yeldar.kakimbek@nu.edu.kz  

# Introduction

The project was dedicated to construct a tool that draws an inputted
polynomial equation as a graph. The tool consists of a custom keyboard
on a breadboard connected to an FPGA with an MTL2 screen. It took
learning to work with Verilog modules and electronic circuits in regular
weekly lab sessions, as well to organize general-purpose input/output
(GPIO) ports during the sessions of independent work. This project was
important for developing coding skills, especially for hardware.

# Materials and Methods

1.  2 breadboards to serve as the keyboard base.

2.  1 Altera DE1-SOC FPGA Board to serve as the processing unit.

3.  1 Multi-Touch LCD Modules 2nd Edition MTL2 to serve as the screen.

4.  17 Push-Buttons for inputting.

5.  Dupont wires: M-to-M for intra-keyboard connections and M-to-F for
    extra-keyboard connections with the processing unit.

6.  1K Ohm resistors for stabilizing the push-buttons’ voltage.

# Results

Our aim was to construct an interactive graph maker using the push
buttons, FPGA, 7 segment displays and MTL2 screen.

<figure>
<img src="F1.jpg" />
<figcaption>Initial draft-scheme of our hardware
implementation</figcaption>
</figure>

<figure>
<img src="F2.jpg" />
<figcaption>The real implementation of the project from the user
perspective </figcaption>
</figure>

Interaction with the screen goes through the use of buttons on the
breadboard. There are 17 buttons for different purposes. 7 them for sign
change, delete the numbers (backspace button), shift left and shift
right buttons, mode change, zoom in and zoom out buttons. Other 10
buttons for integer input.

<figure>
<img src="F3.jpg" />
<figcaption>Coefficient assigning method for 4th degree
polynomial</figcaption>
</figure>

To assign the coefficient in front of the variable with the respective
degree, the user should choose the digit, which represents the degree of
the variable. Note that initially all the coefficients are equal to 0.

<figure>
<img src="F4.jpg" />
<figcaption>Degree choosing mode. Red colored one is currently chosen
degree of the variable</figcaption>
</figure>

After choosing the right degree, to put the coefficients, the user
should press buttons representing the digits. After pressing them, user
can see the number on the 7 segment displays as shown in Figure 5. User
can change the sign if it is needed.

<figure>
<img src="F5.jpg" />
<figcaption>Chosen number on the 7 segment displays</figcaption>
</figure>

After choosing coefficients for all the variables user can press ‘mode
change’ button to see the result. The result will be displayed on the
MTL2 screen as shown in Figure 6.

<figure>
<img src="F6.jpg" />
<figcaption>The result from the user perspective</figcaption>
</figure>

To see more clear image user can press ‘zoom in’ or ‘zoom out’ buttons.
Also to change the view user can press ‘shift left’ and ‘shift right’
buttons as well.

Link to the user experience video is
[<span style="color: blue">here</span>](https://drive.google.com/file/d/1OOdgRi6XGyOKNpfXB-3CYShodbOHhODp/view?usp=sharing)

## Description of work

The system consists of three main components, which can be separated as
the input unit (keyboard), the processing block (FPGA), and the output
unit (MTL2 screen and 7 segment displays on the FPGA). The output units
were already working devices, so we will describe the other two
components.

### Input

<figure>
<img src="F7.jpg" />
<figcaption>Input buttons on the breadboard</figcaption>
</figure>

The keyboard is simply a circuit with a set of 17 push buttons and
resistors connected in parallel. The potential difference is created by
the 5V and GND (ground) ports among the GPIO ports of the FPGA. Each
button is connected to a corresponding GPIO port, which is always ready
to receive signals.

### Processing unit

The main purpose of the processing unit is sustaining synchronization
between the user’s inputs and the outputting image. Here are the steps
we took for its implementation:

1.  Each port used was stored in a variable in the pin assignment file
    called GraphCalc.qsf. We took a pin provided during our lab sessions
    (\[1\]) for accessing GPIOs, but also included all the LED ports of
    each 7 segment display.

2.  Each value necessary to output a number was handled as a state; each
    value is a variable with allocated memory (up to 36 bits). The
    states are the digits of the currently inputting number and its
    sign.

3.  Each state is synchronized with a corresponding 7 segment display
    via external modules called dec_to_7seg and sign_to_7seg. The
    modules are implemented in .v files with the same names. Executing
    every time the clock pin becomes HIGH, they convert the inputted
    values to 7 bits that are recognized by the 7 segment displays. Then
    the 7 bit values are outputted to the 7 segment display ports
    prepared in the pin assignment in step 1. Thus whenever a state
    changes, the corresponding 7 segment display immediately shows it.

4.  Since GPIO input ports are already constantly in sync with the
    incoming signals, it was enough to store their values in wire
    variables to make states out of them. However, when buttons were
    pressed, bounces occurred. To solve this problem, we used the
    Pushbutton_Debounce module (\[2\]). It denounces and synchronizes
    the inputting signals with the clock pin via double flip-flops.

5.  Now all that was left was to calculate the outputting states’ values
    whenever the inputting states were changed (the user inputs
    anything). For example, whenever the user switches between the
    coefficients (pressing 5th button in Picture 1), change the values
    of the states that are in sync with 7 segment displays to
    corresponding coefficient’s value.

# [<span style="color: blue">Software</span>](https://github.com/tsl-robt/graph-calculator/tree/main)

sign_to_7seg module:  
Converts the given sign state’s value into a 7 bit value that draws the
corresponding sign in the given 7 segment display. dec_to_7seg works
similarly.  
Input: clock and sign (positive or negative).  
Output: hex (encoded LED segments of 7 segment display).

Initialize hex encoding as empty 7 bit binary Set hex = 7’b0111111 Set
hex = 7’b1111111

  
Pushbutton_Debouncer module:  
Debounces the inputting button signal and limits its duration up to 1
clock cycle so that button hold is considered as a single click. The
code simulates a double flip-flop.  
Input: clock and btn (button signal).  
Output: btn_up (single clock signal when button is pressed).

Initialize hex encoding as empty 7 bit binary Set btn_sync_0 = not btn
Set btn_sync_1 = btn_sync_0 Set btn_cnt = empty 16 bit value. Set
btn_idle = btn_state == btn_sync_1. Set btn_cnt_max = & btn_cnt.
Set btn_cnt = 0 Increment btn_cnt Set btn_state = not btn_state. assign
PB_down =  PB_idle & PB_cnt_max &  PB_state; assign PB_up =  PB_idle &
PB_cnt_max & PB_state;

  
poly() function:  
This function calculates the value of a polynomial given the argument
and coefficients. Formula uses a minimal number of operations without
calculating every power of x.  
Input: x, five coefficients of polynomial a4, a3, a2, a1, a0  
Output: value of polynomial at x

Set poly as ((((a4 \* x + a3) \* x) + a2) \* x + a1)\*x + a0

  
inp_handler (MAIN) module:  
Main module. Every block is explained in comments.

Initialize all variables used Set graph = 0 Set curCoef = 0 Set zoom = 1
Set shiftX = 400 Set shiftY = 240 Set plus = 1 Generate
PushButton_Debouncer for every pin in GPIO_0 Set x = (hpos - shiftX) /
zoom Set y = shiftY - vpos Set Color of current pixel to white Save
currently inputted coefficient in coefs Save sign of coefficient by
multiplying Change boolean value of graph Increment shiftX by 10
Decrement shiftX by 10 zoom = zoom \* 2 zoom = zoom / 2 Make current
pixel black Make current pixel black Make current pixel black Make
current pixel red

  

switch boolean value of plus Save coefficient to coefs\[curCoef\] Save
sign by multiplying to either 1 or -1 depending on plus Decrement
curCoef by 1 Update nums\[i\] Save coefficient to coefs\[curCoef\] Save
sign by multiplying to either 1 or -1 depending on plus Increment
curCoef by 1 Update nums\[i\] make current pixel black make current
pixel red delete last digit nums\[0\], shift other nums to the right and
set nums\[4\] as 0 shift nums to the left and set nums\[0\] as pressed
digit assign MTL2_DCLK=clk25; assign MTL2_R=red; assign MTL2_G=green;
assign MTL2_B=blue;

  

# Discussion and Conclusions 

The goal of our project was to write working code on VHDL to display
graphics. Initially, we wanted to implement the working system to build
various graphics, not only for 4th degree polynomials. It took us 2
weeks to research the nuances of VHDL and understand how the FPGA works.
It was a big challenge for us, for Computer Science Major students.
During the build of the code we have faced some problems and we
successfully fixed them. But we could not manage to overcome some
hardware limitations. First of all, we could not increase the degree of
the polynomial function, since the program kept lagging or even cracked
after compilation for higher degree polynomial functions. Nevertheless,
the program builds the precise graphs for 4th degree polynomial
functions. Furthermore, we made our project to look more human friendly
as much as possible. We would like to upgrade our project work to be
able to construct graphs for irrational and trigonometric functions, as
well as make them more simple and understandable for human beings.

# Student Contributions:

Alikhan: connected the keyboard to the FPGA via GPIO ports and wrote the
part of code that turns inputting signals into applicable states and
utilized the debounce module; provided synchronized output to 7 segment
displays and added the custom Verilog modules of dec_to_7seg and
sign_to_7seg. Sanzhar: constructed the keyboard; carried out the
software that simulates the graph and outputs it to the MTL2 screen in a
human-friendly way and provided graph shift functionality (left, right,
zoom in/out); created the GUI layout; did research on button debouncing.
Yeldar: consultations on the algorithm of drawing the graph in
accordance with the posedge clock pin; designed the keyboard; wrote the
report.

Debouncer  
https://www.fpga4fun.com/Debouncer2.html

Pin assignment from lab
https://moodle.nu.edu.kz/mod/resource/view.php?id=248166
