function [] = CheckCurrentDir( currentDir, desiredDir )
%CHECKCURRENTDIR Checks that we're in the right directory, returns if not.

%Check if the entire string matches
if ~strcmp(currentDir, desiredDir)
    %
    warning(['Change to the directory: ' shouldBeDir ' in order to run.']);
    return;
end

end

