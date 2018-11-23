% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans [1,2] - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\IHNA\Documents\MATLAB\batch_paired_t_test_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Scans [1,2] - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
