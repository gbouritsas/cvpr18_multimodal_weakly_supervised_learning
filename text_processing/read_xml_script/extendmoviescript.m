function	extendmoviescript(scrfname,extfname,results_folder)
	scrfname=fullfile([results_folder '/' scrfname]);
	extfname=fullfile([results_folder '/' extfname]);
	mscr=loadmoviescript(scrfname);
	for i=1:length(mscr.items)
		if (strcmp(mscr.items(i).tagname,'description') | strcmp(mscr.items(i).tagname,'monologue')) & isequal(mscr.items(i).end_time,[0 0 0]')==0
				mscr.items(mscr.dind(mscr.dind<i))=arrayfun(@(x) setfield(x,'end_time',mscr.items(i).begin_time),mscr.items(mscr.dind(mscr.dind<i)));
				mscr.items(mscr.dind(mscr.dind<i))=arrayfun(@(x) setfield(x,'ascore',mscr.items(i).ascore),mscr.items(mscr.dind(mscr.dind<i)));
			break;
		end
	end

	for i=1:length(mscr.items)
		if strcmp(mscr.items(i).tagname,'speaker')
			for j=i:length(mscr.items)
				if strcmp(mscr.items(j).tagname,'monologue')
						mscr.items(i).begin_time=mscr.items(j).begin_time;
						mscr.items(i).end_time=mscr.items(j).end_time;
						mscr.items(i).ascore=mscr.items(j).ascore;
						break;
				end
			end
		end
		if strcmp(mscr.items(i).tagname,'scene')
			flag_first=0;
			for j=i:length(mscr.items)
				if isequal(mscr.items(j).end_time,[-1 -1 -1])==0 & isequal(mscr.items(j).end_time,[0 0 0]')==0
					if flag_first==0
						mscr.items(i).begin_time=mscr.items(j).begin_time;
						mscr.items(i).ascore=mscr.items(j).ascore;
						flag_first=1;
					end
					mscr.items(i).end_time=mscr.items(j).end_time;
				end
				if flag_first==1 & strcmp(mscr.items(j).tagname,'scene')
					break;
				end
			end
		end
		if strcmp(mscr.items(i).tagname,'unknown')
			for j=i:length(mscr.items)
				if isequal(mscr.items(j).end_time,[-1 -1 -1])==0 & isequal(mscr.items(j).end_time,[0 0 0]')==0
					mscr.items(i).begin_time=mscr.items(j).begin_time;
					mscr.items(i).end_time=mscr.items(j).end_time;
					mscr.items(i).ascore=mscr.items(j).ascore;
					break;
				end
			end
		end
    end
    
    if isequal(mscr.items(end).end_time,[0 0 0]') | isequal(mscr.items(end).end_time,[-1 -1 -1])
        mscr.items(end).begin_time=mscr.items(end-1).begin_time;
        mscr.items(end).end_time=mscr.items(end-1).end_time;
	end
	savemoviescript(mscr,extfname);
end	