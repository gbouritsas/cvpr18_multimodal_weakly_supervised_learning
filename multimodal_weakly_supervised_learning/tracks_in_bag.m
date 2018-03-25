
function [ A,overlap,probabilities ] = tracks_in_bag(f,tracks,extend )

A =zeros(length(tracks), size(f,1)+1);
overlap = zeros(length(tracks), size(f,1)+1);
probabilities=zeros(length(tracks), size(f,1)+1);



g(:,1)=f(:,1)-extend*(f(:,2)-f(:,1)+1);
g(:,2)=f(:,2)+extend*(f(:,2)-f(:,1)+1);
f=g;



for i = 1:length(tracks)
    track_start = tracks(i,1);
    track_end = tracks(i,2);
	frame_idx=[track_start track_end];
    idx =  f(:,2) >= track_start & f(:,2) <= track_end & f(:,1)<=track_start;
	if isempty(find(idx==1))==0
		for j=find(idx==1)
			frame_idx=[frame_idx track_start:f(j,2)];
		end
	end
	overlap(i,idx)=f(idx,2)-track_start+1;
	A(i, idx) = 1;
	idx =  f(:,2) >= track_start & f(:,2) <= track_end & f(:,1)>=track_start;
	if isempty(find(idx==1))==0
		for j=find(idx==1)
			frame_idx=[frame_idx f(j,1):f(j,2)];
		end
	end
	overlap(i,idx)=f(idx,2)-f(idx,1)+1;
	A(i, idx) = 1;
	idx =  f(:,2) >= track_end & f(:,1) <= track_end & f(:,1)>=track_start;
	if isempty(find(idx==1))==0
		for j=find(idx==1)
			frame_idx=[frame_idx f(j,1):track_end];
		end
	end
	overlap(i,idx)=track_end-f(idx,1)+1;
	A(i, idx) = 1;
	idx =  f(:,2) >= track_end &  f(:,1)<=track_start;
	if isempty(find(idx==1))==0
		for j=find(idx==1)
			frame_idx=[frame_idx track_start:track_end];
		end
	end
	overlap(i,idx)=track_end-track_start+1;
	A(i, idx) = 1;
    
	frame_idx=sort(frame_idx);
	none_length=length(track_start:track_end)-length(unique(frame_idx));
	if frame_idx(1)~=frame_idx(2)
		none_length=none_length+1;
	end
	if frame_idx(end)~=frame_idx(end-1)
		none_length=none_length+1;
	end
	overlap(i,end)=none_length;
    A(i,end)=double(overlap(i,end)~=0);
	probabilities(i,:)=overlap(i,:)./(track_end-track_start+1);

end

end


