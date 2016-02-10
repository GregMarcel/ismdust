#! /usr/bin/env isis

%% GC9p9_FeL_wXSPEC.sl -- Fit Fe-L extinction edge with XSPEC model
%%    ismdust
%%
%% 2015.11.28 -- lia@space.mit.edu
%%-------------------------------------------------------------------

_traceback = 1;

%% I need this to pick out my favorite flux value
%% http://cxc.harvard.edu/proposer/threads/binary/lmxb_sim.sl
public define flux (id, e_lo, e_hi)
{
   variable l_lo, l_hi, m, e_avg, pflux, eflux;
   l_hi = _A(e_lo);        % Convert keV to A, or visa versa
   l_lo = _A(e_hi);        % Convert keV to A, or visa versa
   m = get_model_flux(id);
   pflux = rebin (l_lo, l_hi, m.bin_lo, m.bin_hi, m.value)[0];
   e_avg = _A(1.)*(1./m.bin_hi+1./m.bin_lo)/2.*1.602e-9;
   eflux = rebin (l_lo, l_hi, m.bin_lo, m.bin_hi, m.value*e_avg)[0];

   () = printf("\n photons/cm2/sec: %11.3e, ergs/cm2/sec: %11.3e \n \n", pflux, eflux);
   return pflux, eflux;  % Photon flux & ergs flux (per cm^2/sec)
}
%%------------------------------------------------------------

variable DROOT = "tgcat/obs_3407_tgid_3824/";

variable meg, arf_m1, arf_p1, rmf_m1, rmf_p1;

meg = load_data( DROOT+"pha2.gz", [9,10]; with_bkg_updown);

arf_m1 = load_arf( DROOT+"meg_-1.arf");
arf_p1 = load_arf( DROOT+"meg_1.arf");
assign_arf([arf_m1,arf_p1], meg);

rmf_m1 = load_rmf( DROOT+"meg_-1.rmf");
rmf_p1 = load_rmf( DROOT+"meg_1.rmf");
assign_rmf([rmf_m1,rmf_p1], meg);

%% Rebin the data
rebin_data(meg[0], 20); % min number of counts
rebin_data(meg[1], get_data_info(meg[0]).rebin); % rebin to match meg-1 data

%% Plot the region of interest
variable ANGSMIN = 16.0, ANGSMAX = 19.0;
variable pstyle = struct{dsym=0, dcol=1, decol=15, mcol=0};

fancy_plot_unit("Angstrom");
xrange(ANGSMIN, ANGSMAX);
plot_counts( meg, pstyle );
plot_pause;

%% Fit that region only

load_xspec_local_models("/Users/lia/dev/ismdust/");

xnotice( meg, ANGSMIN, ANGSMAX );
fit_fun("powerlaw(1)");
() = fit_counts;
plot_counts( meg, pstyle; mcol=2, res=2);


fit_fun("powerlaw(1)*ismdust(1)");
set_par("ismdust(1).msil", 0.4, 1);
set_par("ismdust(1).mgra", 0.0, 1);
() = fit_counts;

thaw("ismdust(1).msil");
() = fit_counts;

xrange(17,18);
plot_unfold(meg, pstyle; mcol=2, res=4);
plot_pause;


%% What is the flux in the 16-19 Angstrom region?
variable pflux, eflux;
(pflux, eflux) = flux(meg[0], Const_hc/ANGSMAX, Const_hc/ANGSMIN);

variable mdmin, mdmax;
(mdmin, mdmax) = conf_loop( 3, 0 );

variable NHmodel = 1.e-4 / (1.67e-24*1.e22*0.009*0.6); % md to (NH/1.e22)

print("%%--- MD and 1-sigma confidence interval for extinction edge ---%%");
() = printf("Silicate dust mass: %.2f, (%.2f, %.2f)\n", get_par("ismdust(1).msil"), mdmin, mdmax);




