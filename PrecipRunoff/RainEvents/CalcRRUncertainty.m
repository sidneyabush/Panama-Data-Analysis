function [uncert] = CalcRRUncertainty(MATEvts, PASEvts)
% CalcRRUncertainty: Calculates the cumulative uncertainty (in percent) of the
% Runoff Ratio equation for a given set of events.

numEvts = length(MATEvts) + length(PASEvts);
if numEvts < 1
    warning(['CalcRRUncertainty called with no events.']);
    uncert = nan;
    return
end
allEvts = [MATEvts PASEvts];





% Calculate the compound uncertainty for each runoff LL.
ucEachRunLL = 0.5; % Uncertainty for an individual LL reading (in mm).
ucRunLL = zeros(1, 3); % One for each LL.
LLNames = {'lowLLRunoff', 'midLLRunoff', 'upLLRunoff'};
% For each event:
for evtIdx = 1:length(allEvts)
    % For each of the three LLs
    for LLIdx = 1:length(ucRunLL)
        % Get our modified runoff values and remove 0s.
        LLVals = C_RainEvent.shiftVals(...
                              allEvts(evtIdx).(LLNames{LLIdx}).valsModified, ...
                              allEvts(evtIdx).(LLNames{LLIdx}).valsShift);
        LLVals(LLVals == 0) = [];
        % Calc the % error for each reading and add to the total.
        sumOfLLUncert = sum(ucEachRunLL ./ LLVals);
        if ~isempty(sumOfLLUncert)
            ucRunLL(LLIdx) = ucRunLL(LLIdx) + sumOfLLUncert;
        end
    end
end





% Calculate the compound uncertainty for each runoff TB.
ucEachRunTB = 0.01; % Uncertainty for an individual TB reading (1%).
ucRunTB = zeros(1, 3); % One for each TB.
TBNames = {'lowTBRunoff', 'midTBRunoff', 'upTBRunoff'};
% For each event:
for evtIdx = 1:length(allEvts)
    % For each of the three TBs, count the number of readings and add to total.
    % Only interested in the number of readings, so don't need to take into
    % account whether the readings were modified or not.
    for TBIdx = 1:length(ucRunTB)
        ucRunTB(TBIdx) = ucRunTB(TBIdx) + length(allEvts(evtIdx).(TBNames{TBIdx}).vals);
    end
    % ucRunTB(1) = ucRunTB(1) + length(allEvts(evtIdx).lowTBRunoff.vals);
    % ucRunTB(2) = ucRunTB(2) + length(allEvts(evtIdx).midTBRunoff.vals);
    % ucRunTB(3) = ucRunTB(3) + length(allEvts(evtIdx).upTBRunoff.vals);
end
% The compound uncertainty for a Runoff TB is equal to the number of
% readings times the uncertainty of an individual reading.
ucRunTB = ucRunTB .* ucEachRunTB;





% Calculate the compound uncertainty for the precip TB.
ucEachPreTB = 0.01; % Uncertainty for an individual TB reading (1%).
ucPreTB = 0;
PreTot = 0;
% For each event:
for evtIdx = 1:length(allEvts)
    % Add up the number of readings taken by the precip TB.
    ucPreTB = ucPreTB + length(allEvts(evtIdx).getTotal());
    PreTot = PreTot + allEvts(evtIdx).getTotal();
end
% The compound uncertainty for the precip TB is equal to the number of
% readings times the uncertainty of an individual reading.
ucPreTB = ucPreTB * ucEachPreTB;





% Calculate the cumulative uncertainty for the entire RR equation.
% Each runoff uncertainty term is divided by a factor, then squared.
ucAllRun = [ucRunTB ucRunLL];
ucAllRun = (ucAllRun ./ (PreTot * 6)) .^2;
% The precip uncertainty is multiplied by a different term, then squared.
ucAllPre = (-1/6 * PreTot^-2 * ucPreTB)^2;
% Add both runoff and precip uncertainties, then take sqrt for final uncert.
uncert = sqrt(sum(ucAllRun) + ucAllPre);
