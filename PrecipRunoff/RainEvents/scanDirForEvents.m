function [events] = scanDirForEvents(evtDir)
% Takes in a directory and returns a cell array listing all the events therein.
%   Cell array contains MAT/PAS, Evt #, and TB/LL.

%
% matFigs = dir([matFolder eventFolder '/MAT*.fig']);
% pasFigs = dir([matFolder eventFolder '/PAS*.fig']);
% allFigs = {matFigs, pasFigs};
% sites = {'MAT', 'PAS'};
%
%
%
% % Extract, using parentheses in the regex, the event number and TB or LL.
% pattern = 'event_(\d+)_([L-T][B-L]).fig';
% pattern = '([A-T]{3})_event_(\d+)_([L-T][B-L]).fig';
%
%
%
%
% tokens = regexp({allFigs{j}.name}, pattern, 'tokens');
%
%
% cells = [tokens{:}];




eventFiles = dir([matFolder eventFolder '*.fig']);

for fileNum = 1:length(eventFiles)
    fnTokens = regexp({eventFiles(fileNum).name}, pattern, 'tokens');
    site = fnTokens{1}{1}{1};
    evtIdx = str2double(fnTokens{1}{1}{2});
    type = fnTokens{1}{1}{3};
end


end
