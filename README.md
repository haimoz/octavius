# octavius
[Octave](https://www.gnu.org/software/octave/) scripts that performs various batch processing tasks

Compatibility with MATLAB is not intended or tested.  

# Contents

[`fit.m`](#fit) -- fits images to a frame with fixed aspect ratio

<div id="fit"/>
# Fit

The `fit.m` script fits input images to a frame with fixed aspect ratio, saving the fitted image in the same format as the input.  

## Usage

	fit <options> <option-values> <img-list>

## Options

`-a` :  
	followed by a number to specify aspect ration ( width : height ).
	Defaults to 4:3.

`-wh` :  
	followed by two numbers, width then height,
	as alternative specification of aspect ratio.

`-q` :  
	followed by a number between 0 and 100 to specify the compression quality of output images,
	100 being best. Defaults to 75.

`-b` :  
	followed by three integer numbers between 0 and 255,
	to specify the RGB colors of the background.  Defaults to white.

`-d` :  
	followed by the output directory for the fitted images.
	Defaults to the current working directory.

`-h` or `--help` :  
	show the help message.

## Example

To fit all jpeg images in the current folder to 
a 2x3 frame, 
with 75% quality, and 
light yellow background, 
then save the results to 
the directory named 'fitted' (must exist before calling `fit.m`) in the current working directory:

	ls *.jpg *.jpeg | xargs ./fit.m -wh 2 3 -q 75 -b 255 255 200 -d ./fitted



