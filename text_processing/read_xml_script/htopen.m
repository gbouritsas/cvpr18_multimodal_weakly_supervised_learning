function fp = htopen(filename,title,bg,op,fg)
%HTOPEN Open an HTML file for edit.
%  FP = HTOPEN('filename','title','bg',OP,'fg') open the file 'filename' and
%  begin a new HTML document, inserting the title 'title' in
%  this file. The function defines the background with color 'bg' (in format RRGGBB)
%  if op is not 0 or defines the background with a image file 'bg' if op is 0.
%  'fg' defines the color of the foreground text.
%  The function can optionally be used with only two arguments, assuming that the
%  background color will be white.
%  Example:
%  htopen('myfile.html','Title of my page')
%
%  HTOPEN returns the File Handle for the file opened.     
% 
%  If file 'filename' exists, it will be overwrited.
%
%  Example of a new file with black background:
%  htopen('myfile.html','The title of my page','FFFFFF',1,'000000')
%
%  Example of a new file with the file back.jpg as background:
%  htopen('myfile.html','The title of my page','back.jpg',0,'000000')

%
%  See also HTCLOSE, HTWHR, HTWMATRIX, HTWTEXT, HTWPAR
%
%  Further Information: 
%       http://www.vision.ime.usp.br/~casado/matlab/htmltoolbox/
%
%  This program is free software; you can redistribute it and/or
%  modify it under the terms of the GNU General Public License
%  as published by the Free Software Foundation; either version 2
%  of the License, or (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%
%   Copyright (c) 2000 by Andre Casado Castano.
%   e-mail:casado@vision.ime.usp.br
%   $Revision: 1.1 $  $Date: 2001/05/14 $


fp=fopen(filename,'w');
fprintf(fp,'<html>\n<head>\n<!--This file was created by Matlab HTML Toolbox. More information:\n  http://www.vision.ime.usp.br/~casado/matlab/htmltoolbox/-->\n<title>%s</title>\n</head>\n<body ',title);

if (nargin < 3)
  fprintf(fp,'bgcolor="#FFFFFF">\n');
else
  fprintf(fp,'text="#%s" ',fg); 
  if (op)  fprintf(fp,'bgcolor="#%s">\n',bg);   
  else  fprintf(fp,'background="%s">\n',bg);     
  end
end