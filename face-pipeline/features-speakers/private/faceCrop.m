function crop = faceCrop(img,box)
      extend = 0.1;
      newdim = 224;
  %make square
  width = round(box(3)-box(1));
  height = round(box(4)-box(2));

  length = (width + height)/2;

  centrepoint = [round(box(1)) + width/2 round(box(2)) + height/2];
  x1= centrepoint(1) - round((1+extend)*length/2);
  y1= centrepoint(2) - round((1+extend)*length/2);
  x2= centrepoint(1) + round((1+extend)*length/2);
  y2= centrepoint(2) + round((1+extend)*length/2);


  % prevent going off the page
  x1= max(1,x1);
  y1= max(1,y1);
  x2= min(x2,size(img,2));
  y2= min(y2,size(img,1));


  img = img(y1:y2,x1:x2,:);
  sizeimg = size(img);
  crop = imresize(img,(newdim/sizeimg(1)));

end
