function calcPositionsDifferent(data, site, combinations)
% calcPositionsDifferent Calculate whether upper, middle and lower RRs are significantly different.
    for combi = combinations
        firstRRName = combi{1}{1};
        secondRRName = combi{1}{2};
        [h,p] = kstest2(data.(site).(firstRRName), data.(site).(secondRRName));
        disp(['KSTest for ' firstRRName ' and ' secondRRName '. P-value: ' num2str(p)]);
    end
  end
