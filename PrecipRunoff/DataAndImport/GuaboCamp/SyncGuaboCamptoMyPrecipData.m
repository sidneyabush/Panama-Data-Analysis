function [ synchronizedmm ] = SyncGuaboCamptoMyPrecipData( referencetimestamps, GCtiptimes )
%Sync GC data
%   Take in Guabo Camp Precip. data and return mm data that is synchronized to
%   the MAT/PAS precip. times

% for each referencetimestamp count the number of timestamps in GCtimes
% since the previous timestamp

synchronizedmm=zeros(length(referencetimestamps),1);
synchronizedmm(1)=length(GCtiptimes(GCtiptimes<referencetimestamps(1)));

for i=2: length(referencetimestamps)
    selectedtimestamps=(GCtiptimes>referencetimestamps(i-1)) & (GCtiptimes<referencetimestamps(i));
    synchronizedmm(i)=sum(selectedtimestamps);
    
    
end

end

