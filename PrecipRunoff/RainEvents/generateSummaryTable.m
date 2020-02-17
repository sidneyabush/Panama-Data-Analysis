% This script generates summary information to be copied into the summary table for publication.

% First run plotGoodRR to create the structures and objects this script depends on.
plotGoodRR;

% Then run this script, and when it's done, look at the variables below which will have all the values grouped together for easy copying into excel.

eventsArray = {MAT_Events, PAS_Events};
sitesArray = {'MAT', 'PAS'};
summaryValues = struct();

for siteIdx = 1:length(eventsArray)
    events = eventsArray{siteIdx};
    site = sitesArray{siteIdx};

    eventNumbers = data.(site).evtIdx';
    dates = [events(data.(site).evtIdx).startTime]';
    rainfallStartTimes = dates;
    rainfallDuration = data.(site).duration';
    rainfallTotal = data.(site).PreTot';
    peakPrecip = data.(site).PI';
    meanPrecipIntensity = data.(site).AvgI';
    lowRR = data.(site).lowRR';
    midRR = data.(site).midRR';
    upRR = data.(site).upRR';

    initialVWC10cm = [];
    initialVWC30cm = [];
    initialVWC50cm = [];
    initialVWC100cm = [];

    finalVWC10cm = [];
    finalVWC30cm = [];
    finalVWC50cm = [];
    finalVWC100cm = [];

    peakPrecipTime = [];

    firstRunTimeLow = [];
    firstRunTimeMid = [];
    firstRunTimeUp = [];

    runoffTotalLow = [];
    runoffTotalMid = [];
    runoffTotalUp = [];

    peakRunTimeLow = [];
    peakRunTimeMid = [];
    peakRunTimeUp = [];

    peakRunRateLow_MMperHr = [];
    peakRunRateMid_MMperHr = [];
    peakRunRateUp_MMperHr = [];

    for whichEvt = 1:length(data.(site).evtIdx)
        thisEvt = events(data.(site).evtIdx(whichEvt));

        initialVWC10cm = [initialVWC10cm; thisEvt.SM.avg1.vals(1)];
        initialVWC30cm = [initialVWC30cm; thisEvt.SM.avg2.vals(1)];
        initialVWC50cm = [initialVWC50cm; thisEvt.SM.avg3.vals(1)];
        initialVWC100cm = [initialVWC100cm; thisEvt.SM.avg4.vals(1)];

        finalVWC10cm = [finalVWC10cm; thisEvt.SM.avg1.vals(end)];
        finalVWC30cm = [finalVWC30cm; thisEvt.SM.avg2.vals(end)];
        finalVWC50cm = [finalVWC50cm; thisEvt.SM.avg3.vals(end)];
        finalVWC100cm = [finalVWC100cm; thisEvt.SM.avg4.vals(end)];

        % Time of peak intensity
        [~, maxIdx] = max(thisEvt.precipValsModified);
        peakPrecipTime = [peakPrecipTime; thisEvt.precipTimes(maxIdx)];

        % Runoff Start Time
        firstRunTimeLow = [firstRunTimeLow; thisEvt.lowLLRunoff.getFirstRunoffTime(thisEvt.startTime, thisEvt.endTime)];
        if length(firstRunTimeLow) ~= whichEvt
            warning('Lost an event');
        end
        firstRunTimeMid = [firstRunTimeMid; thisEvt.midLLRunoff.getFirstRunoffTime(thisEvt.startTime, thisEvt.endTime)];
        firstRunTimeUp = [firstRunTimeUp; thisEvt.upLLRunoff.getFirstRunoffTime(thisEvt.startTime, thisEvt.endTime)];

        % Runoff totals
        runoffTotalLow = [runoffTotalLow; thisEvt.lowLLRunoff.getTotal('mod')];
        runoffTotalMid = [runoffTotalMid; thisEvt.midLLRunoff.getTotal('mod')];
        runoffTotalUp = [runoffTotalUp; thisEvt.upLLRunoff.getTotal('mod')];

        % Peak runoff rate and time of occurrence
        [peakRunTime, peakRunRate_MMperHr] = thisEvt.lowLLRunoff.getPeakRunTimeAndRate(thisEvt.startTime, thisEvt.endTime);
        peakRunTimeLow = [peakRunTimeLow; peakRunTime];
        peakRunRateLow_MMperHr = [peakRunRateLow_MMperHr; peakRunRate_MMperHr];
        [peakRunTime, peakRunRate_MMperHr] = thisEvt.midLLRunoff.getPeakRunTimeAndRate(thisEvt.startTime, thisEvt.endTime);
        peakRunTimeMid = [peakRunTimeMid; peakRunTime];
        peakRunRateMid_MMperHr = [peakRunRateMid_MMperHr; peakRunRate_MMperHr];
        [peakRunTime, peakRunRate_MMperHr] = thisEvt.upLLRunoff.getPeakRunTimeAndRate(thisEvt.startTime, thisEvt.endTime);
        peakRunTimeUp = [peakRunTimeUp; peakRunTime];
        peakRunRateUp_MMperHr = [peakRunRateUp_MMperHr; peakRunRate_MMperHr];
    end

    % Create a table out of all these vectors.
    summaryTable = table(eventNumbers, dates, initialVWC10cm, initialVWC30cm, initialVWC50cm, initialVWC100cm, finalVWC10cm, finalVWC30cm, finalVWC50cm, finalVWC100cm, rainfallStartTimes, rainfallDuration, rainfallTotal, peakPrecipTime, peakPrecip, meanPrecipIntensity, firstRunTimeLow, firstRunTimeMid, firstRunTimeUp, runoffTotalLow, runoffTotalMid, runoffTotalUp, peakRunTimeLow, peakRunTimeMid, peakRunTimeUp, peakRunRateLow_MMperHr, peakRunRateMid_MMperHr, peakRunRateUp_MMperHr, lowRR, midRR, upRR);


    % Store that table in the struct.
    summaryValues.(site) = summaryTable;
end
