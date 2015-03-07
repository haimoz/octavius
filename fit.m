#! /usr/bin/octave -qf

usage_string = [ ...
	"\n" 'Usage:' ...
	"\n" '	fit <options> <option-values> <img-list>' ...
	"\n" 'options:' ...
	"\n" '	-a :' ...
	"\n" '		followed by a number to specify aspect ration ( width : height ).  Defaults to 4:3.  ' ...
	"\n" '	-wh :' ...
	"\n" '		followed by two numbers, width then height, as alternative specification of aspect ratio.  ' ...
	"\n" '	-q :' ...
	"\n" '		followed by a number between 0 and 100 to specify the compression quality of output images, 100 being best.  Defaults to 75.  ' ...
	"\n" '	-b :' ...
	"\n" '		followed by three integer numbers between 0 and 255, to specify the RGB colors of the background.  Defaults to white.  ' ...
	"\n" '	-d :' ...
	"\n" '		followed by the output directory for the fitted images.  Defaults to the current working directory.  ' ...
	"\n" '	-h, --help :' ...
	"\n" '		show this help message.  ' ...
	"\n" ...
];

function out_img = fit(in_img, asp, bg)
	w = size(in_img, 2);
	h = size(in_img, 1);
	nd = ndims(in_img);
	
	if nd == 2
		ch = 1;
	elseif nd == 3 && size(in_img, 3) == 3
		ch = 3;
	else
		error('Number of color channels can only be 3');
	end
	
	h_fit = floor(w/asp);
	if h_fit > h
		if ch == 1
			out_img = repmat(bg(1), [h_fit,w,1]);
		elseif ch == 3
			out_img = repmat(reshape(bg,[1,1,3]), [h_fit,w,1]);
		else
			error('Wrong number of channels');
		end
		fit_top = floor((h_fit - h) / 2);
		out_img(fit_top+1 : fit_top+h,:,:) = in_img(:,:,:);
	elseif h_fit < h
		w_fit = h * asp;
		if ch == 1
			out_img = repmat(bg(1), [h,w_fit,1]);
		elseif ch == 3
			out_img = repmat(reshape(bg,[1,1,3]), [h,w_fit,1]);
		else
			error('Wrong number of channels');
		end
		fit_left = floor((w_fit - w) / 2);
		out_img(:, fit_left+1 : fit_left+w, :) = in_img(:,:,:);
	else
		out_img = in_img;
	end
	
	out_img = uint8( out_img );
	
	% Work-around for Octave's bug in saving grayscale images 
	% (that, the saved pixels have much lower value of 101 for the original 255) 
	% by saving as RBG image of same RGB values.  
	if ch == 1
		out_img = repmat( out_img, [1,1,3] );
	end
	
end

function n = parse_number(s)
	n = str2num(s);
	if numel(n) != 1
		error(['Cannot parse string "' s '" as a number']);
		return;
	end
end

arg_list = argv();

% process options
asp = 4.0/3.0;
qual = 75;
bg = [255,255,255];
dir = '';
i = 1;
while i <= nargin
	if strcmp(arg_list{i}, '-a')
		% `-a' to specify aspect ratio
		if i+1 > nargin
			error('-a option must be followed by a number');
			return;
		end
		asp = parse_number(arg_list{i+1});
		if asp <= 0
			error(['aspect ratio of ' num2str(asp) ' is not allowed, must be positive']);
			return;
		end
		i = i+2;
	elseif strcmp(arg_list{i}, '-wh')
		% `-wh' to specify aspect ratio with width and height
		if i+2 > nargin
			error('-wh must be followed by two numbers, width then height');
			return;
		end
		w = parse_number(arg_list{i+1});
		if w <= 0
			error(['width of ' num2str(w) ' is not allowed, must be positive']);
			return;
		end
		h = parse_number(arg_list{i+2});
		if w <= 0
			error(['width of ' num2str(w) ' is not allowed, must be positive']);
			return;
		end
		asp = w/h;
		i = i+3;
	elseif strcmp(arg_list{i}, '-q')
		% `-q' to specify quality, default to 75
		if i+1 > nargin
			error('-q option must be followed by an integer number between 0 and 100');
			return;
		end
		qual = parse_number(arg_list{i+1});
		if qual < 0 || qual > 100
			error(['quality of ' num2str(qual) ' is not allowed, must be between 0 and 100']);
			return;
		end
		i = i+2;
	elseif strcmp(arg_list{i}, '-b')
		% `-b' to specify background color in RGB csv string, values range from 0 to 255
		%      default background is white ([255,255,255])
		if i+3 > nargin
			error('-b option must be followed by three integer numbers between 0 and 255 for RGB values');
			return;
		end
		r = parse_number(arg_list{i+1});
		if r < 0 || r > 255
			error(['pixel R value of ' num2str(r) ' is not allowed, must be between 0 and 255']);
			return;
		end
		g = parse_number(arg_list{i+2});
		if g < 0 || g > 255
			error(['pixel G value of ' num2str(g) ' is not allowed, must be between 0 and 255']);
			return;
		end
		b = parse_number(arg_list{i+3});
		if b < 0 || b > 255
			error(['pixel B value of ' num2str(b) ' is not allowed, must be between 0 and 255']);
			return;
		end
		bg = [r,g,b];
		i = i+4;
	elseif strcmp(arg_list{i}, '-d')
		% `-d' to specify output directory
		if i+1 > nargin
			error('-d option must be followed by an output directory path');
			return;
		end
		dir = arg_list{i+1};
		if dir(end) != '/'
			dir = [dir '/'];
		end
		i = i+2;
	elseif strcmp(arg_list{i}, '-h') || strcmp(arg_list{i}, '--help')
		% show usage
		printf('%s', usage_string);
		return;
	else
		break;
	end
end
while i <= nargin
	printf('processing file: %s\n', arg_list{i});
	img = fit(imread(arg_list{i}), asp, bg);
	[ path , name , ext , ver ] = fileparts(arg_list{i});
	imwrite(img, [ dir 'fitted.' name ext ], 'Quality', qual);
	i = i+1;
end

