function [p,q,score]=alignwordstrings(wstr1,wstr2,wflag);
  
% [p,q,score]=alignwordstrings(wstr1,wstr2,wflag);
%
%  Dynamic time warping on a pair of word strings with
%  memory-efficient implementation to enable matching
%  long strings with ~10K words. The matching is case
%  insensitive and the words are weighted by their inverted
%  frequences if 'wflag' is true (wflag=0 default)
  
if nargin<3 wflag=0; end
n1=length(wstr1);
n2=length(wstr2);

% convert words to labels (case-insensitive) 
[wordsunique,i1,wordslabel]=unique(cat(2,lower(wstr1),lower(wstr2)));
wlab1=wordslabel(1:n1);
wlab2=wordslabel(n1+1:end);

% assign weights to the words based on the inverse frequency
wordshist=hist(wordslabel,1:length(wordsunique));
wordsfreq=wordshist(wordslabel);
wordsweight=round(10./min(10,wordsfreq));

% compute similarity matrix
smat=zeros(n1+1,n2+1,'uint16');
for i=1:n1
  if ~wflag
    smat(i+1,2:end)=uint16(wlab1(i)==wlab2);
  else
    smat(i+1,2:end)=uint16(double(wlab1(i)==wlab2)*wordsweight(wlab1(i)));
  end
end

% set smat for DTW
smat=max(smat(:))-smat;
smat(:,1)=Inf;
smat(1,:)=Inf;
smat(1,1)=0;

if 1 % in-place DTW
  fprintf('solving DTW for %dx%d matrix...     \n',n1,n2)
  phi = zeros(n1,n2,'uint8');
  tic
  for i = 1:n1; 
    for j = 1:n2;
      [dmin, tb] = min([smat(i, j) smat(i, j+1) smat(i+1, j)]);
      smat(i+1,j+1) = smat(i+1,j+1)+dmin;
      phi(i,j) = tb;
    end
    if toc>5
      fprintf('\b\b\b\b%3d%%',round(100*i/n1))
      tic
    end
  end
  fprintf('b\b\b\b\b\bDone\n')
  % Traceback from top left
  i = n1; j = n2; p = i;  q = j;
  while i > 1 & j > 1
    tb = phi(i,j);
    if (tb == 1)     i = i-1; j = j-1;
    elseif (tb == 2) i = i-1;
    elseif (tb == 3) j = j-1;
    else    
      error;
    end
    p = [i,p];
    q = [j,q];
  end
else % external dynamic programming (for checking)
  tic
  [p1,q1]=dynprog(smat(2:end,2:end));
  toc
end

