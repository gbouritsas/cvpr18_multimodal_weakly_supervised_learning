function [newtext,newtext1]=preprocessing_for_parsing(text)


newtext = regexprep(text,'\(?CONT''D\)?|\(?CONTINUED\)?|\(?Continued\)?|\(?Cont''d\)?|\(?continued\)?|\(?cont''d\)?',cell(1));

%Needs extension if there for other special characters.
newtext=regexprep(newtext,'é','e');
newtext=regexprep(newtext,'É','E');

%In case the script is handwritten, ocr mistakes need to be corrected.
newtext=regexprep(newtext,'(\\)',' ');
newtext=regexprep(newtext,'(-)( )*(-)*',',');
newtext=regexprep(newtext,'(_)',' ');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\;)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\:)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\,)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\?)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\'')','$1');


%remove numbers in the beginning of each line and replace with equal number of spaces
ind=regexp(newtext,'(?m)^([0-9]+(\.)*)( *[A-Z]+)','tokenExtents');
for i=1:length(ind)
	newtext(ind{1,i}(1):ind{1,i}(2))=' ';
end

%remove numbers in the end of each line
newtext = regexprep(newtext,' *[0-9]+(\.)* *\r\n','\r\n');

%add a dot in the end of each capitalized line,i.e scenes or speakers. Important for sentence splitting.
newtext = regexprep(newtext,'(?m)^([^a-z\r\n]+[^a-z\r\n\.])\r\n','$1.\r\n');

%New check for mistakes that might occur after the first preprocessing pass
newtext=regexprep(newtext,'(\\)',' ');
newtext=regexprep(newtext,'(-)( )*(-)*',',');
newtext=regexprep(newtext,'(_)',' ');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\;)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\:)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\,)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\?)','$1');
newtext=regexprep(newtext,'([^a-zA-z0-9 *])(\'')','$1');


%Remove characters in punctuation and number only lines
newtext=regexprep(newtext,'(?m)^([^a-zA-z]+)(\r\n)','$2');


%Convert fully upercase to initial letter uppercase
newtext1 = regexprep(newtext,'([A-Z])([A-Z]*)','$1${lower($2)}');
