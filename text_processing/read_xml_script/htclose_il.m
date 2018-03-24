function htclose_il(fp)
%HTCLOSE Close a file previously opened by HTOPEN.
%  HTCLOSE(FP) closes the file pointed by FP, inserting the final html 
%  commands to make it an HTML document. 
%
%  It also add the date and time of the creation (or modification) of the page.
%
%  Example: 
%  htclose(fp)

%
%  See also HTOPEN, HTWHR, HTWMATRIX, HTWTEXT, HTWPAR, HTWURL
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
%   $Revision: 1.01 $  $Date: 2000/12/04 $

time = fix(clock);
dat = date;
fprintf(fp,'<hr>\n<i> (c) INRIA, Ivan Laptev <br>\n');
fprintf(fp, 'Last update: %s, %d:%d:%d</i>\n</body>\n</html>', dat, time(4), time(5), time(6));
fclose(fp);
