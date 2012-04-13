function [raw, data] = read_fiff (filename)
%Function to load fiff file into a header and data structure
%   
%   usage: [ header, data ] = read_fiff(filename)
%
%   Last update 10.12.2011, by Kai

raw=fiff_setup_read_raw(filename);
data=fiff_read_raw_segment(raw);