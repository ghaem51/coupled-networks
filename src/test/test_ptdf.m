clear all;
clc

%% get constants that help us to find the data
C = psconstants; % tells me where to find my data

%% set some options
opt = psoptions;
opt.verbose = 1; % set this to false if you don't want stuff on the command line
% Stopping criterion: (set to zero to simulate a complete cascade)
opt.sim.stop_threshold = 0.00; % the fraction of nodes, at which to declare a major separation
opt.sim.fast_ramp_mins = 1;

%% Prepare and run the simulation for the Polish grid
%ps = case300_001_ps;
fprintf('----------------------------------------------------------\n');
disp('loading the data');
tic
if exist('case2383_mod_ps.mat')
    load case2383_mod_ps;
else
    ps = case2383_mod_ps;
end
toc
fprintf('----------------------------------------------------------\n');
tic
ps = updateps(ps);
ps = redispatch(ps);
ps = dcpf(ps);
toc
fprintf('----------------------------------------------------------\n');
m = size(ps.branch,1);
pre_contingency_flows = ps.branch(:,C.br.Pf);
phase_angles_degrees = ps.bus(:,C.bu.Vang);

%% Run an extreme case

%% Run several cases
opt.verbose = false;
load BOpairs
i=4;
n_iters = 1;

disp('Testing DCSIMSEP without control.');
tic

% outage
br_outages = BOpairs(i,:);
% run the simulator
fprintf('Running simulation %d of %d. ',i,n_iters);
[~,relay_outages,MW_lost_1(i),p_out,busessep,flows,times,power_flow] = dcsimsep(ps,br_outages,[],opt);
fprintf(' Result: %.2f MW of load shedding\n',MW_lost_1(i));
%is_blackout = dcsimsep(ps,br_outages,[],opt);

toc