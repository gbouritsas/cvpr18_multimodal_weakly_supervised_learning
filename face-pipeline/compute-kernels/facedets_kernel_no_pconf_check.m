function facedets_kernel_no_pconf_check(result_dir)

load(fullfile(result_dir, 'facedets.mat'));

track = cat(1, facedets.track);
[a,b]=sort(track);
facedets=facedets(b);
track = cat(1, facedets.track);
utrack = unique(track);

n = length(utrack);

pose = cat(1, facedets.pose);
pconf = cat(1, facedets.pconf);

frontal = pose==1;
profile = pose~=1;

% working on frontal faces
idx = (frontal);%why check pconf???
facedets_f = facedets(idx);
S = cat(2, facedets_f.dSIFT);
d = size(S, 1);
K = d / 128;
dff = inf(n,n,K);

V= cat(2, facedets_f.dVGG);
dffv=inf(n,n,1);
if n~=0
    parfor k = 1:K
		k
        %     fprintf('Profile, channel %d\n', k);
        dim1 = (k-1)*128 + 1;
        dim2 = k*128;
        S_c = S( dim1 : dim2, :)';

        mytempi=inf(n,n);
        for i = 1:length(utrack)
            idxi = track(idx) == utrack(i);
            if sum(idxi)~=0
				%avoid recomputation-speed up calculation
				D = W_dist(S_c(idxi,:), S_c(find(idxi==1,1,'first'):end,:), eye(size(S_c, 2)));
				startf=0;
				mytempj=inf(1,n);
                for j = i:length(utrack)
                    idxj = track(idx) == utrack(j);
					stepf=sum(idxj);
                    if sum(idxj)~=0
                        d = D(:,startf+1:startf+stepf);
						mytempj(j)=min(d(:));
                        %dff(i,j,k) = min(d(:));
                        %dff(j,i,k) = min(d(:));
						startf=startf+stepf;
                    end
                end
				mytempi(i,:)=mytempj;
            end
        end
		b=triu(mytempi);
		mytempi=b+triu(b,1)';
		dff(:,:,k)=mytempi;
    end


	V=V';
	mytempi=inf(n,n);
	parfor i = 1:length(utrack)
		i
        idxi = track(idx) == utrack(i);
        if sum(idxi)~=0
			D = W_dist(V(idxi,:), V(find(idxi==1,1,'first'):end,:), eye(size(V, 2)));
			startf=0;
			mytempj=inf(1,n);
			for j = i:length(utrack)
				idxj = track(idx) == utrack(j);
				stepf=sum(idxj);
				if sum(idxj)~=0
					d = D(:,startf+1:startf+stepf);
					mytempj(j)=min(d(:));
					%dffv(i,j,1) = min(d(:));
					%dffv(j,i,1) = min(d(:));
					startf=startf+stepf;
				end
			end
			mytempi(i,:)=mytempj;
		end
	end
	b=triu(mytempi);
	mytempi=b+triu(b,1)';
	dffv(:,:,1)=mytempi;
end

% working on profile
%first version:30
%second:0
idx = (profile);
facedets_f = facedets(idx);
S = cat(2, facedets_f.dSIFT);
d = size(S, 1);
K = d / 128;
dfp = inf(n,n,K);

V= cat(2, facedets_f.dVGG);
dfpv=inf(n,n,1);

if n~=0
    parfor k = 1:K
		k
        %     fprintf('Profile, channel %d\n', k);
        dim1 = (k-1)*128 + 1;
        dim2 = k*128;
        S_c = S( dim1 : dim2, :)';

        mytempi=inf(n,n);
        for i = 1:length(utrack)
            idxi = track(idx) == utrack(i);
            if sum(idxi)~=0
				D = W_dist(S_c(idxi,:), S_c(find(idxi==1,1,'first'):end,:), eye(size(S_c, 2)));
				startf=0;
				mytempj=inf(1,n);
                for j = i:length(utrack)
                    idxj = track(idx) == utrack(j);
					stepf=sum(idxj);
                    if sum(idxj)~=0
                        d = D(:,startf+1:startf+stepf);
						mytempj(j)=min(d(:));
                        %dfp(i,j,k) = min(d(:));
                        %dfp(j,i,k) = min(d(:));
						startf=startf+stepf;
                    end
                end
				mytempi(i,:)=mytempj;
            end
        end
		b=triu(mytempi);
		mytempi=b+triu(b,1)';
		dfp(:,:,k)=mytempi;
	end


	V=V';
	mytempi=inf(n,n);
	parfor i = 1:length(utrack)
		i
        idxi = track(idx) == utrack(i);
        if sum(idxi)~=0
			D = W_dist(V(idxi,:), V(find(idxi==1,1,'first'):end,:), eye(size(V, 2)));
			startf=0;
			mytempj=inf(1,n);
			for j = i:length(utrack)
				idxj = track(idx) == utrack(j);
				stepf=sum(idxj);
				if sum(idxj)~=0
					d = D(:,startf+1:startf+stepf);
					mytempj(j)=min(d(:));
					%dfpv(i,j,1) = min(d(:));
					%dfpv(j,i,1) = min(d(:));
					startf=startf+stepf;
				end
			end
			mytempi(i,:)=mytempj;
		end
	end
	b=triu(mytempi);
	mytempi=b+triu(b,1)';
	dfpv(:,:,1)=mytempi;
end


idx = (frontal | profile );%why check pconf???
facedets_f = facedets(idx);
V= cat(2, facedets_f.dVGG);
dfav=inf(n,n,1);
if n~=0
	V=V';
	mytempi=inf(n,n);
	parfor i = 1:length(utrack)
		i
        idxi = track(idx) == utrack(i);
        if sum(idxi)~=0
			D = W_dist(V(idxi,:), V(find(idxi==1,1,'first'):end,:), eye(size(V, 2)));
			startf=0;
			mytempj=inf(1,n);
			for j = i:length(utrack)
				idxj = track(idx) == utrack(j);
				stepf=sum(idxj);
				if sum(idxj)~=0
					d = D(:,startf+1:startf+stepf);
					mytempj(j)=min(d(:));
					%dfav(i,j,1) = min(d(:));
					%dfav(j,i,1) = min(d(:));
					startf=startf+stepf;
				end
			end
			mytempi(i,:)=mytempj;
		end
	end
	b=triu(mytempi);
	mytempi=b+triu(b,1)';
	dfav(:,:,1)=mytempi;
end


dff = single(dff);
dfp = single(dfp);

Ks = sum_kernel(cat(3, dff, dfp)	, 1);


dffv = single(dffv);
dfpv = single(dfpv);

Kv = sum_kernel(cat(3, dffv, dfpv)	, 1);

dfav = single(dfav);

Kav = sum_kernel(cat(3, [], dfav)	, 1);

save(fullfile(result_dir, 'kernel_sift_no_pconf.mat'), 'Ks');
save(fullfile(result_dir, 'kernel_vgg_frontal_profile_no_pconf.mat'), 'Kv');
save(fullfile(result_dir, 'kernel_vgg_all_no_pconf.mat'), 'Kav');


end
