function MOD = mvs_1_0_1_vapp(uniqID)

    MOD = ee_model();
    MOD = add_to_ee_model (MOD, 'modelname', 'mvs_1_0_1');
    MOD = add_to_ee_model (MOD, 'terminals', {'d', 'g', 's', 'b'});

    % variable info:
    % explicit outputs: 
    % variable name: idb, equation index: 1
    % variable name: igb, equation index: 2
    % variable name: isb, equation index: 3

    % internal unknowns: 
    % variable name: vdib, equation index: 0
    % variable name: vsib, equation index: 0

    MOD = add_to_ee_model (MOD, 'explicit_outs', {'idb', 'igb', 'isb'});
    MOD = add_to_ee_model (MOD, 'internal_unks', {'vdib', 'vsib'});

    MOD = add_to_ee_model (MOD, 'parms', {'parm_CC', 0,...
                                          'parm_CTM_select', 1,...
                                          'parm_Cg', 2.2e-06,...
                                          'parm_Cif', 1e-12,...
                                          'parm_Cof', 2e-13,...
                                          'parm_Lgdr', 8e-06,...
                                          'parm_Rd0', 100,...
                                          'parm_Rs0', 100,...
                                          'parm_Tjun', 298,...
                                          'parm_Vt0', 0.486,...
                                          'parm_W', 0.0001,...
                                          'parm_alpha', 3.5,...
                                          'parm_beta', 1.7,...
                                          'parm_dLg', 1.05e-06,...
                                          'parm_delta', 0.1,...
                                          'parm_etov', 0.0013,...
                                          'parm_gamma', 0,...
                                          'parm_mc', 0.2,...
                                          'parm_mu', 200,...
                                          'parm_n0', 1.5,...
                                          'parm_nd', 0,...
                                          'parm_phib', 1.2,...
                                          'parm_type', 1,...
                                          'parm_version', 1.01,...
                                          'parm_vxo', 7650000});

    MOD = finish_ee_model(MOD);

    MOD.fqeiJ = @fqeiJ;
    MOD.fe = @fe_from_fqeiJ_ModSpec;
    MOD.qe = @qe_from_fqeiJ_ModSpec;
    MOD.fi = @fi_from_fqeiJ_ModSpec;
    MOD.qi = @qi_from_fqeiJ_ModSpec;
    MOD.fqei = @fqei_from_fqeiJ_ModSpec;
    MOD.fqeiJ = @fqeiJ;

    MOD.dfe_dvecX = @dfe_dvecX_from_fqeiJ_ModSpec;
    MOD.dfe_dvecY = @dfe_dvecY_from_fqeiJ_ModSpec;
    MOD.dfe_dvecLim = @dfe_dvecLim_from_fqeiJ_ModSpec;
    MOD.dfe_dvecU = @dfe_dvecU_from_fqeiJ_ModSpec;

    MOD.dqe_dvecX = @dqe_dvecX_from_fqeiJ_ModSpec;
    MOD.dqe_dvecY = @dqe_dvecY_from_fqeiJ_ModSpec;
    MOD.dqe_dvecLim = @dqe_dvecLim_from_fqeiJ_ModSpec;

    MOD.dfi_dvecX = @dfi_dvecX_from_fqeiJ_ModSpec;
    MOD.dfi_dvecY = @dfi_dvecY_from_fqeiJ_ModSpec;
    MOD.dfi_dvecLim = @dfi_dvecLim_from_fqeiJ_ModSpec;
    MOD.dfi_dvecU = @dfi_dvecU_from_fqeiJ_ModSpec;

    MOD.dqi_dvecX = @dqi_dvecX_from_fqeiJ_ModSpec;
    MOD.dqi_dvecY = @dqi_dvecY_from_fqeiJ_ModSpec;
    MOD.dqi_dvecLim = @dqi_dvecLim_from_fqeiJ_ModSpec;
    MOD.dinitGuess_dvecU = @dinitGuess_dvecU;

end

function [fqei_out, J_out] = fqeiJ(vecX, vecY, vecLim, vecU, flag, MOD)
    if nargin < 6
        MOD = flag;
        flag = vecU;
        vecU = vecLim;
    end

    [fe, qe, fi, qi, d_fe_d_X, d_qe_d_X, d_fi_d_X, d_qi_d_X,...
    d_fe_d_Y, d_qe_d_Y, d_fi_d_Y, d_qi_d_Y] = fqei_dfqeidXYU(vecX, vecY, MOD);

    fqei_out.fe = fe;
    fqei_out.qe = qe;
    fqei_out.fi = fi;
    fqei_out.qi = qi;

    nExplicitOut = 3;
    nInternalUnk = 2;

    J_out.Jfe.dfe_dvecX = d_fe_d_X;
    J_out.Jqe.dqe_dvecX = d_qe_d_X;
    J_out.Jfi.dfi_dvecX = d_fi_d_X;
    J_out.Jqi.dqi_dvecX = d_qi_d_X;
    J_out.Jfe.dfe_dvecY = d_fe_d_Y;
    J_out.Jqe.dqe_dvecY = d_qe_d_Y;
    J_out.Jfi.dfi_dvecY = d_fi_d_Y;
    J_out.Jqi.dqi_dvecY = d_qi_d_Y;
    J_out.Jfe.dfe_dvecU = zeros(nExplicitOut,0);
    J_out.Jfi.dfi_dvecU = zeros(nInternalUnk,0);
    J_out.Jfe.dfe_dvecLim = zeros(nExplicitOut, 0);
    J_out.Jqe.dqe_dvecLim = zeros(nExplicitOut, 0);
    J_out.Jfi.dfi_dvecLim = zeros(nInternalUnk, 0);
    J_out.Jqi.dqi_dvecLim = zeros(nInternalUnk, 0);
end

function [fe__, qe__, fi__, qi__,...
          d_fe_d_X__, d_qe_d_X__, d_fi_d_X__, d_qi_d_X__,...
          d_fe_d_Y__, d_qe_d_Y__, d_fi_d_Y__, d_qi_d_Y__] = ...
         fqei_dfqeidXYU(vecX__, vecY__, MOD)
    vdb__ = vecX__(1);
    vgb__ = vecX__(2);
    vsb__ = vecX__(3);
    vdib__ = vecY__(1);
    vsib__ = vecY__(2);
    fe__ = zeros(3,1);
    qe__ = zeros(3,1);
    fi__ = zeros(2,1);
    qi__ = zeros(2,1);
    d_fe_d_X__ = zeros(3,3);
    d_qe_d_X__ = zeros(3,3);
    d_fi_d_X__ = zeros(2,3);
    d_qi_d_X__ = zeros(2,3);
    d_fe_d_Y__ = zeros(3,2);
    d_qe_d_Y__ = zeros(3,2);
    d_fi_d_Y__ = zeros(2,2);
    d_qi_d_Y__ = zeros(2,2);
    % initializing parameters
    parm_CC = MOD.parm_vals{1};
    parm_CTM_select = MOD.parm_vals{2};
    parm_Cg = MOD.parm_vals{3};
    parm_Cif = MOD.parm_vals{4};
    parm_Cof = MOD.parm_vals{5};
    parm_Lgdr = MOD.parm_vals{6};
    parm_Rd0 = MOD.parm_vals{7};
    parm_Rs0 = MOD.parm_vals{8};
    parm_Tjun = MOD.parm_vals{9};
    parm_Vt0 = MOD.parm_vals{10};
    parm_W = MOD.parm_vals{11};
    parm_alpha = MOD.parm_vals{12};
    parm_beta = MOD.parm_vals{13};
    parm_dLg = MOD.parm_vals{14};
    parm_delta = MOD.parm_vals{15};
    parm_etov = MOD.parm_vals{16};
    parm_gamma = MOD.parm_vals{17};
    parm_mc = MOD.parm_vals{18};
    parm_mu = MOD.parm_vals{19};
    parm_n0 = MOD.parm_vals{20};
    parm_nd = MOD.parm_vals{21};
    parm_phib = MOD.parm_vals{22};
    parm_type = MOD.parm_vals{23};
    parm_version = MOD.parm_vals{24};
    parm_vxo = MOD.parm_vals{25};
    % initializing variables
    
    d_Vbs_d_vdb__ = 0;
    d_Vbs_d_vsb__ = 0;
    d_Vbsi_d_vdib__ = 0;
    d_Vbsi_d_vsib__ = 0;
    d_Vds_d_vdb__ = 0;
    d_Vds_d_vsb__ = 0;
    d_Vdsi_d_vdib__ = 0;
    d_Vdsi_d_vsib__ = 0;
    d_Vgs_d_vdb__ = 0;
    d_Vgs_d_vsb__ = 0;
    d_Vgsi_d_vdib__ = 0;
    d_Vgsi_d_vsib__ = 0;
    d_a_d_vdb__ = 0;
    d_a_d_vdib__ = 0;
    d_a_d_vgb__ = 0;
    d_a_d_vsb__ = 0;
    d_a_d_vsib__ = 0;
    
    % printing IO aliases
    vbd__= -vdb__;
    vbs__= -vsb__;
    vbdi__= -vdib__;
    vbsi__= -vsib__;
    vgsi__ = vgb__ - vsib__;
    vgdi__ = vgb__ - vdib__;
    vds__ = vdb__ - vsb__;
    vsd__= -vds__;
    vgs__ = vgb__ - vsb__;
    vdisi__ = vdib__ - vsib__;
    vsidi__= -vdisi__;
    vgd__ = vgb__ - vdb__;
    vddi__ = vdb__ - vdib__;
    vsis__ = vsib__ - vsb__;
    % module body
        d_Vgsraw_d_vgb__ = parm_type*1;
        d_Vgsraw_d_vsib__ = parm_type*-1;
    Vgsraw = parm_type*vgsi__;
        d_Vgdraw_d_vgb__ = parm_type*1;
        d_Vgdraw_d_vdib__ = parm_type*-1;
    Vgdraw = parm_type*vgdi__;
    if Vgsraw>=Vgdraw
            d_Vds_d_vdb__ = parm_type*1;
            d_Vds_d_vsb__ = parm_type*-1;
        Vds = parm_type*vds__;
            d_Vgs_d_vgb__ = parm_type*1;
            d_Vgs_d_vsb__ = parm_type*-1;
        Vgs = parm_type*vgs__;
            d_Vbs_d_vsb__ = parm_type*-1;
        Vbs = parm_type*vbs__;
            d_Vdsi_d_vdib__ = parm_type*1;
            d_Vdsi_d_vsib__ = parm_type*-1;
        Vdsi = parm_type*vdisi__;
            d_Vgsi_d_vgb__ = d_Vgsraw_d_vgb__;
            d_Vgsi_d_vsib__ = d_Vgsraw_d_vsib__;
        Vgsi = Vgsraw;
            d_Vbsi_d_vsib__ = parm_type*-1;
        Vbsi = parm_type*vbsi__;
        dir = 1;
    else
        Vds = parm_type*vsd__;
            d_Vgs_d_vdb__ = parm_type*-1;
            d_Vgs_d_vgb__ = parm_type*1;
        Vgs = parm_type*vgd__;
            d_Vbs_d_vdb__ = parm_type*-1;
        Vbs = parm_type*vbd__;
        Vdsi = parm_type*vsidi__;
            d_Vgsi_d_vgb__ = d_Vgdraw_d_vgb__;
            d_Vgsi_d_vdib__ = d_Vgdraw_d_vdib__;
        Vgsi = Vgdraw;
            d_Vbsi_d_vdib__ = parm_type*-1;
        Vbsi = parm_type*vbdi__;
        dir = -1;
    end
    Rs = (0.0001/parm_W)*parm_Rs0;
    Rd = Rs;
    Cofs = ((3.45e-13/parm_etov)*parm_dLg)/2+parm_Cof;
    Cofd = ((3.45e-13/parm_etov)*parm_dLg)/2+parm_Cof;
    Leff = parm_Lgdr-parm_dLg;
    phit = sim_vt_vapp(parm_Tjun);
    me = 9.1e-31*parm_mc;
        d_n_d_vdb__ = (parm_nd*d_Vds_d_vdb__);
        d_n_d_vsb__ = (parm_nd*d_Vds_d_vsb__);
    n = parm_n0+parm_nd*Vds;
        d_nphit_d_vdb__ = d_n_d_vdb__*phit;
        d_nphit_d_vsb__ = d_n_d_vsb__*phit;
    nphit = n*phit;
    aphit = parm_alpha*phit;
        d_Vtpcorr_d_vdb__ = ((parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbs))*(d_abs_d_arg1__(parm_phib-Vbs)*(-d_Vbs_d_vdb__)))));
        d_Vtpcorr_d_vsb__ = ((parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbs))*(d_abs_d_arg1__(parm_phib-Vbs)*(-d_Vbs_d_vsb__)))));
        d_Vtpcorr_d_vdib__ = -(d_Vdsi_d_vdib__*parm_delta);
        d_Vtpcorr_d_vsib__ = -(d_Vdsi_d_vsib__*parm_delta);
    Vtpcorr = (parm_Vt0+parm_gamma*(sqrt(abs(parm_phib-Vbs))-sqrt(parm_phib)))-Vdsi*parm_delta;
        d_eVgpre_d_vdb__ = d_exp_d_arg1__((Vgs-Vtpcorr)/(aphit*1.5))*(((d_Vgs_d_vdb__-d_Vtpcorr_d_vdb__)*(aphit*1.5))/(aphit*1.5)^2);
        d_eVgpre_d_vgb__ = d_exp_d_arg1__((Vgs-Vtpcorr)/(aphit*1.5))*(((d_Vgs_d_vgb__)*(aphit*1.5))/(aphit*1.5)^2);
        d_eVgpre_d_vsb__ = d_exp_d_arg1__((Vgs-Vtpcorr)/(aphit*1.5))*(((d_Vgs_d_vsb__-d_Vtpcorr_d_vsb__)*(aphit*1.5))/(aphit*1.5)^2);
        d_eVgpre_d_vdib__ = d_exp_d_arg1__((Vgs-Vtpcorr)/(aphit*1.5))*(((-d_Vtpcorr_d_vdib__)*(aphit*1.5))/(aphit*1.5)^2);
        d_eVgpre_d_vsib__ = d_exp_d_arg1__((Vgs-Vtpcorr)/(aphit*1.5))*(((-d_Vtpcorr_d_vsib__)*(aphit*1.5))/(aphit*1.5)^2);
    eVgpre = exp((Vgs-Vtpcorr)/(aphit*1.5));
        d_FFpre_d_vdb__ = (-1*(d_eVgpre_d_vdb__))/(1+eVgpre)^2;
        d_FFpre_d_vgb__ = (-1*(d_eVgpre_d_vgb__))/(1+eVgpre)^2;
        d_FFpre_d_vsb__ = (-1*(d_eVgpre_d_vsb__))/(1+eVgpre)^2;
        d_FFpre_d_vdib__ = (-1*(d_eVgpre_d_vdib__))/(1+eVgpre)^2;
        d_FFpre_d_vsib__ = (-1*(d_eVgpre_d_vsib__))/(1+eVgpre)^2;
    FFpre = 1/(1+eVgpre);
        d_ab_d_vdb__ = (2*(-(0.99*d_FFpre_d_vdb__)))*phit;
        d_ab_d_vgb__ = (2*(-(0.99*d_FFpre_d_vgb__)))*phit;
        d_ab_d_vsb__ = (2*(-(0.99*d_FFpre_d_vsb__)))*phit;
        d_ab_d_vdib__ = (2*(-(0.99*d_FFpre_d_vdib__)))*phit;
        d_ab_d_vsib__ = (2*(-(0.99*d_FFpre_d_vsib__)))*phit;
    ab = (2*(1-0.99*FFpre))*phit;
        d_Vcorr_d_vdb__ = ((1+2*parm_delta)*(ab/2))*(d_exp_d_arg1__(-Vdsi/ab)*((--Vdsi*d_ab_d_vdb__)/ab^2))+((1+2*parm_delta)*((d_ab_d_vdb__*2)/2^2))*exp(-Vdsi/ab);
        d_Vcorr_d_vgb__ = ((1+2*parm_delta)*(ab/2))*(d_exp_d_arg1__(-Vdsi/ab)*((--Vdsi*d_ab_d_vgb__)/ab^2))+((1+2*parm_delta)*((d_ab_d_vgb__*2)/2^2))*exp(-Vdsi/ab);
        d_Vcorr_d_vsb__ = ((1+2*parm_delta)*(ab/2))*(d_exp_d_arg1__(-Vdsi/ab)*((--Vdsi*d_ab_d_vsb__)/ab^2))+((1+2*parm_delta)*((d_ab_d_vsb__*2)/2^2))*exp(-Vdsi/ab);
        d_Vcorr_d_vdib__ = ((1+2*parm_delta)*(ab/2))*(d_exp_d_arg1__(-Vdsi/ab)*((-d_Vdsi_d_vdib__*ab--Vdsi*d_ab_d_vdib__)/ab^2))+((1+2*parm_delta)*((d_ab_d_vdib__*2)/2^2))*exp(-Vdsi/ab);
        d_Vcorr_d_vsib__ = ((1+2*parm_delta)*(ab/2))*(d_exp_d_arg1__(-Vdsi/ab)*((-d_Vdsi_d_vsib__*ab--Vdsi*d_ab_d_vsib__)/ab^2))+((1+2*parm_delta)*((d_ab_d_vsib__*2)/2^2))*exp(-Vdsi/ab);
    Vcorr = ((1+2*parm_delta)*(ab/2))*exp(-Vdsi/ab);
        d_Vgscorr_d_vdb__ = d_Vcorr_d_vdb__;
        d_Vgscorr_d_vgb__ = d_Vgsi_d_vgb__+d_Vcorr_d_vgb__;
        d_Vgscorr_d_vsb__ = d_Vcorr_d_vsb__;
        d_Vgscorr_d_vdib__ = d_Vgsi_d_vdib__+d_Vcorr_d_vdib__;
        d_Vgscorr_d_vsib__ = d_Vgsi_d_vsib__+d_Vcorr_d_vsib__;
    Vgscorr = Vgsi+Vcorr;
        d_Vbscorr_d_vdb__ = d_Vcorr_d_vdb__;
        d_Vbscorr_d_vgb__ = d_Vcorr_d_vgb__;
        d_Vbscorr_d_vsb__ = d_Vcorr_d_vsb__;
        d_Vbscorr_d_vdib__ = d_Vbsi_d_vdib__+d_Vcorr_d_vdib__;
        d_Vbscorr_d_vsib__ = d_Vbsi_d_vsib__+d_Vcorr_d_vsib__;
    Vbscorr = Vbsi+Vcorr;
        d_Vt0bs_d_vdb__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbscorr))*(d_abs_d_arg1__(parm_phib-Vbscorr)*(-d_Vbscorr_d_vdb__))));
        d_Vt0bs_d_vgb__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbscorr))*(d_abs_d_arg1__(parm_phib-Vbscorr)*(-d_Vbscorr_d_vgb__))));
        d_Vt0bs_d_vsb__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbscorr))*(d_abs_d_arg1__(parm_phib-Vbscorr)*(-d_Vbscorr_d_vsb__))));
        d_Vt0bs_d_vdib__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbscorr))*(d_abs_d_arg1__(parm_phib-Vbscorr)*(-d_Vbscorr_d_vdib__))));
        d_Vt0bs_d_vsib__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbscorr))*(d_abs_d_arg1__(parm_phib-Vbscorr)*(-d_Vbscorr_d_vsib__))));
    Vt0bs = parm_Vt0+parm_gamma*(sqrt(abs(parm_phib-Vbscorr))-sqrt(parm_phib));
        d_Vt0bs0_d_vdib__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbsi))*(d_abs_d_arg1__(parm_phib-Vbsi)*(-d_Vbsi_d_vdib__))));
        d_Vt0bs0_d_vsib__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-Vbsi))*(d_abs_d_arg1__(parm_phib-Vbsi)*(-d_Vbsi_d_vsib__))));
    Vt0bs0 = parm_Vt0+parm_gamma*(sqrt(abs(parm_phib-Vbsi))-sqrt(parm_phib));
        d_Vtp_d_vdb__ = (d_Vt0bs_d_vdb__);
        d_Vtp_d_vgb__ = (d_Vt0bs_d_vgb__);
        d_Vtp_d_vsb__ = (d_Vt0bs_d_vsb__);
        d_Vtp_d_vdib__ = (d_Vt0bs_d_vdib__-(d_Vdsi_d_vdib__*parm_delta));
        d_Vtp_d_vsib__ = (d_Vt0bs_d_vsib__-(d_Vdsi_d_vsib__*parm_delta));
    Vtp = (Vt0bs-Vdsi*parm_delta)-0.5*aphit;
        d_Vtp0_d_vdib__ = (d_Vt0bs0_d_vdib__-(d_Vdsi_d_vdib__*parm_delta));
        d_Vtp0_d_vsib__ = (d_Vt0bs0_d_vsib__-(d_Vdsi_d_vsib__*parm_delta));
    Vtp0 = (Vt0bs0-Vdsi*parm_delta)-0.5*aphit;
        d_eVg_d_vdb__ = d_exp_d_arg1__((Vgscorr-Vtp)/aphit)*(((d_Vgscorr_d_vdb__-d_Vtp_d_vdb__)*aphit)/aphit^2);
        d_eVg_d_vgb__ = d_exp_d_arg1__((Vgscorr-Vtp)/aphit)*(((d_Vgscorr_d_vgb__-d_Vtp_d_vgb__)*aphit)/aphit^2);
        d_eVg_d_vsb__ = d_exp_d_arg1__((Vgscorr-Vtp)/aphit)*(((d_Vgscorr_d_vsb__-d_Vtp_d_vsb__)*aphit)/aphit^2);
        d_eVg_d_vdib__ = d_exp_d_arg1__((Vgscorr-Vtp)/aphit)*(((d_Vgscorr_d_vdib__-d_Vtp_d_vdib__)*aphit)/aphit^2);
        d_eVg_d_vsib__ = d_exp_d_arg1__((Vgscorr-Vtp)/aphit)*(((d_Vgscorr_d_vsib__-d_Vtp_d_vsib__)*aphit)/aphit^2);
    eVg = exp((Vgscorr-Vtp)/aphit);
        d_FF_d_vdb__ = (-1*(d_eVg_d_vdb__))/(1+eVg)^2;
        d_FF_d_vgb__ = (-1*(d_eVg_d_vgb__))/(1+eVg)^2;
        d_FF_d_vsb__ = (-1*(d_eVg_d_vsb__))/(1+eVg)^2;
        d_FF_d_vdib__ = (-1*(d_eVg_d_vdib__))/(1+eVg)^2;
        d_FF_d_vsib__ = (-1*(d_eVg_d_vsib__))/(1+eVg)^2;
    FF = 1/(1+eVg);
        d_eVg0_d_vgb__ = d_exp_d_arg1__((Vgsi-Vtp0)/aphit)*(((d_Vgsi_d_vgb__)*aphit)/aphit^2);
        d_eVg0_d_vdib__ = d_exp_d_arg1__((Vgsi-Vtp0)/aphit)*(((d_Vgsi_d_vdib__-d_Vtp0_d_vdib__)*aphit)/aphit^2);
        d_eVg0_d_vsib__ = d_exp_d_arg1__((Vgsi-Vtp0)/aphit)*(((d_Vgsi_d_vsib__-d_Vtp0_d_vsib__)*aphit)/aphit^2);
    eVg0 = exp((Vgsi-Vtp0)/aphit);
        d_FF0_d_vgb__ = (-1*(d_eVg0_d_vgb__))/(1+eVg0)^2;
        d_FF0_d_vdib__ = (-1*(d_eVg0_d_vdib__))/(1+eVg0)^2;
        d_FF0_d_vsib__ = (-1*(d_eVg0_d_vsib__))/(1+eVg0)^2;
    FF0 = 1/(1+eVg0);
        d_Qref_d_vdb__ = parm_Cg*d_nphit_d_vdb__;
        d_Qref_d_vsb__ = parm_Cg*d_nphit_d_vsb__;
    Qref = parm_Cg*nphit;
        d_eta_d_vdb__ = ((d_Vgscorr_d_vdb__-((d_Vt0bs_d_vdb__)-(d_FF_d_vdb__*aphit)))*nphit-(Vgscorr-((Vt0bs-Vdsi*parm_delta)-FF*aphit))*d_nphit_d_vdb__)/nphit^2;
        d_eta_d_vgb__ = ((d_Vgscorr_d_vgb__-((d_Vt0bs_d_vgb__)-(d_FF_d_vgb__*aphit)))*nphit)/nphit^2;
        d_eta_d_vsb__ = ((d_Vgscorr_d_vsb__-((d_Vt0bs_d_vsb__)-(d_FF_d_vsb__*aphit)))*nphit-(Vgscorr-((Vt0bs-Vdsi*parm_delta)-FF*aphit))*d_nphit_d_vsb__)/nphit^2;
        d_eta_d_vdib__ = ((d_Vgscorr_d_vdib__-((d_Vt0bs_d_vdib__-(d_Vdsi_d_vdib__*parm_delta))-(d_FF_d_vdib__*aphit)))*nphit)/nphit^2;
        d_eta_d_vsib__ = ((d_Vgscorr_d_vsib__-((d_Vt0bs_d_vsib__-(d_Vdsi_d_vsib__*parm_delta))-(d_FF_d_vsib__*aphit)))*nphit)/nphit^2;
    eta = (Vgscorr-((Vt0bs-Vdsi*parm_delta)-FF*aphit))/nphit;
        d_eta0_d_vdb__ = ((-(-(d_FFpre_d_vdb__*aphit)))*nphit-(Vgsi-((Vt0bs0-Vdsi*parm_delta)-FFpre*aphit))*d_nphit_d_vdb__)/nphit^2;
        d_eta0_d_vgb__ = ((d_Vgsi_d_vgb__-(-(d_FFpre_d_vgb__*aphit)))*nphit)/nphit^2;
        d_eta0_d_vsb__ = ((-(-(d_FFpre_d_vsb__*aphit)))*nphit-(Vgsi-((Vt0bs0-Vdsi*parm_delta)-FFpre*aphit))*d_nphit_d_vsb__)/nphit^2;
        d_eta0_d_vdib__ = ((d_Vgsi_d_vdib__-((d_Vt0bs0_d_vdib__-(d_Vdsi_d_vdib__*parm_delta))-(d_FFpre_d_vdib__*aphit)))*nphit)/nphit^2;
        d_eta0_d_vsib__ = ((d_Vgsi_d_vsib__-((d_Vt0bs0_d_vsib__-(d_Vdsi_d_vsib__*parm_delta))-(d_FFpre_d_vsib__*aphit)))*nphit)/nphit^2;
    eta0 = (Vgsi-((Vt0bs0-Vdsi*parm_delta)-FFpre*aphit))/nphit;
    if eta<=40
            d_Qinv_corr_d_vdb__ = Qref*(d_log_d_arg1__(1+exp(eta))*(d_exp_d_arg1__(eta)*d_eta_d_vdb__))+d_Qref_d_vdb__*log(1+exp(eta));
            d_Qinv_corr_d_vgb__ = Qref*(d_log_d_arg1__(1+exp(eta))*(d_exp_d_arg1__(eta)*d_eta_d_vgb__));
            d_Qinv_corr_d_vsb__ = Qref*(d_log_d_arg1__(1+exp(eta))*(d_exp_d_arg1__(eta)*d_eta_d_vsb__))+d_Qref_d_vsb__*log(1+exp(eta));
            d_Qinv_corr_d_vdib__ = Qref*(d_log_d_arg1__(1+exp(eta))*(d_exp_d_arg1__(eta)*d_eta_d_vdib__));
            d_Qinv_corr_d_vsib__ = Qref*(d_log_d_arg1__(1+exp(eta))*(d_exp_d_arg1__(eta)*d_eta_d_vsib__));
        Qinv_corr = Qref*log(1+exp(eta));
    else
            d_Qinv_corr_d_vdb__ = Qref*d_eta_d_vdb__+d_Qref_d_vdb__*eta;
            d_Qinv_corr_d_vgb__ = Qref*d_eta_d_vgb__;
            d_Qinv_corr_d_vsb__ = Qref*d_eta_d_vsb__+d_Qref_d_vsb__*eta;
            d_Qinv_corr_d_vdib__ = Qref*d_eta_d_vdib__;
            d_Qinv_corr_d_vsib__ = Qref*d_eta_d_vsib__;
        Qinv_corr = Qref*eta;
    end
    if eta0<=40
            d_Qinv_d_vdb__ = Qref*(d_log_d_arg1__(1+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vdb__))+d_Qref_d_vdb__*log(1+exp(eta0));
            d_Qinv_d_vgb__ = Qref*(d_log_d_arg1__(1+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vgb__));
            d_Qinv_d_vsb__ = Qref*(d_log_d_arg1__(1+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vsb__))+d_Qref_d_vsb__*log(1+exp(eta0));
            d_Qinv_d_vdib__ = Qref*(d_log_d_arg1__(1+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vdib__));
            d_Qinv_d_vsib__ = Qref*(d_log_d_arg1__(1+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vsib__));
        Qinv = Qref*log(1+exp(eta0));
    else
            d_Qinv_d_vdb__ = Qref*d_eta0_d_vdb__+d_Qref_d_vdb__*eta0;
            d_Qinv_d_vgb__ = Qref*d_eta0_d_vgb__;
            d_Qinv_d_vsb__ = Qref*d_eta0_d_vsb__+d_Qref_d_vsb__*eta0;
            d_Qinv_d_vdib__ = Qref*d_eta0_d_vdib__;
            d_Qinv_d_vsib__ = Qref*d_eta0_d_vsib__;
        Qinv = Qref*eta0;
    end
    vx0 = parm_vxo;
    Vdsats = (vx0*Leff)/parm_mu;
        d_Vdsat_d_vdb__ = (Vdsats*(-d_FF_d_vdb__))+(phit*d_FF_d_vdb__);
        d_Vdsat_d_vgb__ = (Vdsats*(-d_FF_d_vgb__))+(phit*d_FF_d_vgb__);
        d_Vdsat_d_vsb__ = (Vdsats*(-d_FF_d_vsb__))+(phit*d_FF_d_vsb__);
        d_Vdsat_d_vdib__ = (Vdsats*(-d_FF_d_vdib__))+(phit*d_FF_d_vdib__);
        d_Vdsat_d_vsib__ = (Vdsats*(-d_FF_d_vsib__))+(phit*d_FF_d_vsib__);
    Vdsat = Vdsats*(1-FF)+phit*FF;
        d_Vdratio_d_vdb__ = d_abs_d_arg1__(Vdsi/Vdsat)*((-Vdsi*d_Vdsat_d_vdb__)/Vdsat^2);
        d_Vdratio_d_vgb__ = d_abs_d_arg1__(Vdsi/Vdsat)*((-Vdsi*d_Vdsat_d_vgb__)/Vdsat^2);
        d_Vdratio_d_vsb__ = d_abs_d_arg1__(Vdsi/Vdsat)*((-Vdsi*d_Vdsat_d_vsb__)/Vdsat^2);
        d_Vdratio_d_vdib__ = d_abs_d_arg1__(Vdsi/Vdsat)*((d_Vdsi_d_vdib__*Vdsat-Vdsi*d_Vdsat_d_vdib__)/Vdsat^2);
        d_Vdratio_d_vsib__ = d_abs_d_arg1__(Vdsi/Vdsat)*((d_Vdsi_d_vsib__*Vdsat-Vdsi*d_Vdsat_d_vsib__)/Vdsat^2);
    Vdratio = abs(Vdsi/Vdsat);
        d_Vdbeta_d_vdb__ = d_pow_vapp_d_arg1__(Vdratio, parm_beta)*d_Vdratio_d_vdb__;
        d_Vdbeta_d_vgb__ = d_pow_vapp_d_arg1__(Vdratio, parm_beta)*d_Vdratio_d_vgb__;
        d_Vdbeta_d_vsb__ = d_pow_vapp_d_arg1__(Vdratio, parm_beta)*d_Vdratio_d_vsb__;
        d_Vdbeta_d_vdib__ = d_pow_vapp_d_arg1__(Vdratio, parm_beta)*d_Vdratio_d_vdib__;
        d_Vdbeta_d_vsib__ = d_pow_vapp_d_arg1__(Vdratio, parm_beta)*d_Vdratio_d_vsib__;
    Vdbeta = pow_vapp(Vdratio, parm_beta);
        d_Vdbetabeta_d_vdb__ = d_pow_vapp_d_arg1__(1+Vdbeta, 1/parm_beta)*(d_Vdbeta_d_vdb__);
        d_Vdbetabeta_d_vgb__ = d_pow_vapp_d_arg1__(1+Vdbeta, 1/parm_beta)*(d_Vdbeta_d_vgb__);
        d_Vdbetabeta_d_vsb__ = d_pow_vapp_d_arg1__(1+Vdbeta, 1/parm_beta)*(d_Vdbeta_d_vsb__);
        d_Vdbetabeta_d_vdib__ = d_pow_vapp_d_arg1__(1+Vdbeta, 1/parm_beta)*(d_Vdbeta_d_vdib__);
        d_Vdbetabeta_d_vsib__ = d_pow_vapp_d_arg1__(1+Vdbeta, 1/parm_beta)*(d_Vdbeta_d_vsib__);
    Vdbetabeta = pow_vapp(1+Vdbeta, 1/parm_beta);
        d_Fsat_d_vdb__ = (d_Vdratio_d_vdb__*Vdbetabeta-Vdratio*d_Vdbetabeta_d_vdb__)/Vdbetabeta^2;
        d_Fsat_d_vgb__ = (d_Vdratio_d_vgb__*Vdbetabeta-Vdratio*d_Vdbetabeta_d_vgb__)/Vdbetabeta^2;
        d_Fsat_d_vsb__ = (d_Vdratio_d_vsb__*Vdbetabeta-Vdratio*d_Vdbetabeta_d_vsb__)/Vdbetabeta^2;
        d_Fsat_d_vdib__ = (d_Vdratio_d_vdib__*Vdbetabeta-Vdratio*d_Vdbetabeta_d_vdib__)/Vdbetabeta^2;
        d_Fsat_d_vsib__ = (d_Vdratio_d_vsib__*Vdbetabeta-Vdratio*d_Vdbetabeta_d_vsib__)/Vdbetabeta^2;
    Fsat = Vdratio/Vdbetabeta;
        d_Id_d_vdb__ = ((Qinv_corr*vx0)*d_Fsat_d_vdb__+(d_Qinv_corr_d_vdb__*vx0)*Fsat)*parm_W;
        d_Id_d_vgb__ = ((Qinv_corr*vx0)*d_Fsat_d_vgb__+(d_Qinv_corr_d_vgb__*vx0)*Fsat)*parm_W;
        d_Id_d_vsb__ = ((Qinv_corr*vx0)*d_Fsat_d_vsb__+(d_Qinv_corr_d_vsb__*vx0)*Fsat)*parm_W;
        d_Id_d_vdib__ = ((Qinv_corr*vx0)*d_Fsat_d_vdib__+(d_Qinv_corr_d_vdib__*vx0)*Fsat)*parm_W;
        d_Id_d_vsib__ = ((Qinv_corr*vx0)*d_Fsat_d_vsib__+(d_Qinv_corr_d_vsib__*vx0)*Fsat)*parm_W;
    Id = ((Qinv_corr*vx0)*Fsat)*parm_W;
        d_Vgt_d_vdb__ = (d_Qinv_d_vdb__*parm_Cg)/parm_Cg^2;
        d_Vgt_d_vgb__ = (d_Qinv_d_vgb__*parm_Cg)/parm_Cg^2;
        d_Vgt_d_vsb__ = (d_Qinv_d_vsb__*parm_Cg)/parm_Cg^2;
        d_Vgt_d_vdib__ = (d_Qinv_d_vdib__*parm_Cg)/parm_Cg^2;
        d_Vgt_d_vsib__ = (d_Qinv_d_vsib__*parm_Cg)/parm_Cg^2;
    Vgt = Qinv/parm_Cg;
    if parm_gamma==0
        a = 1;
        if eta0<=40
                d_psis_d_vdb__ = (phit*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vdb__))));
                d_psis_d_vgb__ = (phit*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vgb__))));
                d_psis_d_vsb__ = (phit*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vsb__))));
                d_psis_d_vdib__ = (phit*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vdib__))));
                d_psis_d_vsib__ = (phit*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vsib__))));
            psis = parm_phib+phit*(1+log(log((1+1e-10)+exp(eta0))));
        else
                d_psis_d_vdb__ = (phit*(d_log_d_arg1__(eta0)*d_eta0_d_vdb__));
                d_psis_d_vgb__ = (phit*(d_log_d_arg1__(eta0)*d_eta0_d_vgb__));
                d_psis_d_vsb__ = (phit*(d_log_d_arg1__(eta0)*d_eta0_d_vsb__));
                d_psis_d_vdib__ = (phit*(d_log_d_arg1__(eta0)*d_eta0_d_vdib__));
                d_psis_d_vsib__ = (phit*(d_log_d_arg1__(eta0)*d_eta0_d_vsib__));
            psis = parm_phib+phit*(1+log(eta0));
        end
    else
        if eta0<=40
                d_psis_d_vdb__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vdb__))));
                d_psis_d_vgb__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vgb__))));
                d_psis_d_vsb__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vsb__))));
                d_psis_d_vdib__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vdib__))));
                d_psis_d_vsib__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(log((1+1e-10)+exp(eta0)))*(d_log_d_arg1__((1+1e-10)+exp(eta0))*(d_exp_d_arg1__(eta0)*d_eta0_d_vsib__))));
            psis = parm_phib+(((1-parm_gamma)/(1+parm_gamma))*phit)*(1+log(log((1+1e-10)+exp(eta0))));
        else
                d_psis_d_vdb__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(eta0)*d_eta0_d_vdb__));
                d_psis_d_vgb__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(eta0)*d_eta0_d_vgb__));
                d_psis_d_vsb__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(eta0)*d_eta0_d_vsb__));
                d_psis_d_vdib__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(eta0)*d_eta0_d_vdib__));
                d_psis_d_vsib__ = ((((1-parm_gamma)/(1+parm_gamma))*phit)*(d_log_d_arg1__(eta0)*d_eta0_d_vsib__));
            psis = parm_phib+(((1-parm_gamma)/(1+parm_gamma))*phit)*(1+log(eta0));
        end
            d_a_d_vdb__ = (-parm_gamma*(2*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vdb__)))))/(2*sqrt(abs(psis-Vbsi)))^2;
            d_a_d_vgb__ = (-parm_gamma*(2*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vgb__)))))/(2*sqrt(abs(psis-Vbsi)))^2;
            d_a_d_vsb__ = (-parm_gamma*(2*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vsb__)))))/(2*sqrt(abs(psis-Vbsi)))^2;
            d_a_d_vdib__ = (-parm_gamma*(2*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vdib__-d_Vbsi_d_vdib__)))))/(2*sqrt(abs(psis-Vbsi)))^2;
            d_a_d_vsib__ = (-parm_gamma*(2*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vsib__-d_Vbsi_d_vsib__)))))/(2*sqrt(abs(psis-Vbsi)))^2;
        a = 1+parm_gamma/(2*sqrt(abs(psis-Vbsi)));
    end
        d_Vgta_d_vdb__ = (d_Vgt_d_vdb__*a-Vgt*d_a_d_vdb__)/a^2;
        d_Vgta_d_vgb__ = (d_Vgt_d_vgb__*a-Vgt*d_a_d_vgb__)/a^2;
        d_Vgta_d_vsb__ = (d_Vgt_d_vsb__*a-Vgt*d_a_d_vsb__)/a^2;
        d_Vgta_d_vdib__ = (d_Vgt_d_vdib__*a-Vgt*d_a_d_vdib__)/a^2;
        d_Vgta_d_vsib__ = (d_Vgt_d_vsib__*a-Vgt*d_a_d_vsib__)/a^2;
    Vgta = Vgt/a;
        d_Vdsatq_d_vdb__ = d_sqrt_d_arg1__((FF0*aphit)*aphit+Vgta*Vgta)*((Vgta*d_Vgta_d_vdb__+d_Vgta_d_vdb__*Vgta));
        d_Vdsatq_d_vgb__ = d_sqrt_d_arg1__((FF0*aphit)*aphit+Vgta*Vgta)*(((d_FF0_d_vgb__*aphit)*aphit)+(Vgta*d_Vgta_d_vgb__+d_Vgta_d_vgb__*Vgta));
        d_Vdsatq_d_vsb__ = d_sqrt_d_arg1__((FF0*aphit)*aphit+Vgta*Vgta)*((Vgta*d_Vgta_d_vsb__+d_Vgta_d_vsb__*Vgta));
        d_Vdsatq_d_vdib__ = d_sqrt_d_arg1__((FF0*aphit)*aphit+Vgta*Vgta)*(((d_FF0_d_vdib__*aphit)*aphit)+(Vgta*d_Vgta_d_vdib__+d_Vgta_d_vdib__*Vgta));
        d_Vdsatq_d_vsib__ = d_sqrt_d_arg1__((FF0*aphit)*aphit+Vgta*Vgta)*(((d_FF0_d_vsib__*aphit)*aphit)+(Vgta*d_Vgta_d_vsib__+d_Vgta_d_vsib__*Vgta));
    Vdsatq = sqrt((FF0*aphit)*aphit+Vgta*Vgta);
        d_Fsatq_d_vdb__ = ((d_abs_d_arg1__(Vdsi/Vdsatq)*((-Vdsi*d_Vdsatq_d_vdb__)/Vdsatq^2))*pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)-abs(Vdsi/Vdsatq)*(d_pow_vapp_d_arg1__(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)*(d_pow_vapp_d_arg1__(abs(Vdsi/Vdsatq), parm_beta)*(d_abs_d_arg1__(Vdsi/Vdsatq)*((-Vdsi*d_Vdsatq_d_vdb__)/Vdsatq^2)))))/pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)^2;
        d_Fsatq_d_vgb__ = ((d_abs_d_arg1__(Vdsi/Vdsatq)*((-Vdsi*d_Vdsatq_d_vgb__)/Vdsatq^2))*pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)-abs(Vdsi/Vdsatq)*(d_pow_vapp_d_arg1__(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)*(d_pow_vapp_d_arg1__(abs(Vdsi/Vdsatq), parm_beta)*(d_abs_d_arg1__(Vdsi/Vdsatq)*((-Vdsi*d_Vdsatq_d_vgb__)/Vdsatq^2)))))/pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)^2;
        d_Fsatq_d_vsb__ = ((d_abs_d_arg1__(Vdsi/Vdsatq)*((-Vdsi*d_Vdsatq_d_vsb__)/Vdsatq^2))*pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)-abs(Vdsi/Vdsatq)*(d_pow_vapp_d_arg1__(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)*(d_pow_vapp_d_arg1__(abs(Vdsi/Vdsatq), parm_beta)*(d_abs_d_arg1__(Vdsi/Vdsatq)*((-Vdsi*d_Vdsatq_d_vsb__)/Vdsatq^2)))))/pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)^2;
        d_Fsatq_d_vdib__ = ((d_abs_d_arg1__(Vdsi/Vdsatq)*((d_Vdsi_d_vdib__*Vdsatq-Vdsi*d_Vdsatq_d_vdib__)/Vdsatq^2))*pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)-abs(Vdsi/Vdsatq)*(d_pow_vapp_d_arg1__(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)*(d_pow_vapp_d_arg1__(abs(Vdsi/Vdsatq), parm_beta)*(d_abs_d_arg1__(Vdsi/Vdsatq)*((d_Vdsi_d_vdib__*Vdsatq-Vdsi*d_Vdsatq_d_vdib__)/Vdsatq^2)))))/pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)^2;
        d_Fsatq_d_vsib__ = ((d_abs_d_arg1__(Vdsi/Vdsatq)*((d_Vdsi_d_vsib__*Vdsatq-Vdsi*d_Vdsatq_d_vsib__)/Vdsatq^2))*pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)-abs(Vdsi/Vdsatq)*(d_pow_vapp_d_arg1__(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)*(d_pow_vapp_d_arg1__(abs(Vdsi/Vdsatq), parm_beta)*(d_abs_d_arg1__(Vdsi/Vdsatq)*((d_Vdsi_d_vsib__*Vdsatq-Vdsi*d_Vdsatq_d_vsib__)/Vdsatq^2)))))/pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta)^2;
    Fsatq = abs(Vdsi/Vdsatq)/pow_vapp(1+pow_vapp(abs(Vdsi/Vdsatq), parm_beta), 1/parm_beta);
        d_x_d_vdb__ = -d_Fsatq_d_vdb__;
        d_x_d_vgb__ = -d_Fsatq_d_vgb__;
        d_x_d_vsb__ = -d_Fsatq_d_vsb__;
        d_x_d_vdib__ = -d_Fsatq_d_vdib__;
        d_x_d_vsib__ = -d_Fsatq_d_vsib__;
    x = 1-Fsatq;
        d_den_d_vdb__ = (15*(1+x))*(d_x_d_vdb__)+(15*(d_x_d_vdb__))*(1+x);
        d_den_d_vgb__ = (15*(1+x))*(d_x_d_vgb__)+(15*(d_x_d_vgb__))*(1+x);
        d_den_d_vsb__ = (15*(1+x))*(d_x_d_vsb__)+(15*(d_x_d_vsb__))*(1+x);
        d_den_d_vdib__ = (15*(1+x))*(d_x_d_vdib__)+(15*(d_x_d_vdib__))*(1+x);
        d_den_d_vsib__ = (15*(1+x))*(d_x_d_vsib__)+(15*(d_x_d_vsib__))*(1+x);
    den = (15*(1+x))*(1+x);
        d_qsc_d_vdb__ = ((Qinv*((((12*d_x_d_vdb__))+((8*x)*d_x_d_vdb__+(8*d_x_d_vdb__)*x))+(((4*x)*x)*d_x_d_vdb__+((4*x)*d_x_d_vdb__+(4*d_x_d_vdb__)*x)*x))+d_Qinv_d_vdb__*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*den-(Qinv*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*d_den_d_vdb__)/den^2;
        d_qsc_d_vgb__ = ((Qinv*((((12*d_x_d_vgb__))+((8*x)*d_x_d_vgb__+(8*d_x_d_vgb__)*x))+(((4*x)*x)*d_x_d_vgb__+((4*x)*d_x_d_vgb__+(4*d_x_d_vgb__)*x)*x))+d_Qinv_d_vgb__*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*den-(Qinv*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*d_den_d_vgb__)/den^2;
        d_qsc_d_vsb__ = ((Qinv*((((12*d_x_d_vsb__))+((8*x)*d_x_d_vsb__+(8*d_x_d_vsb__)*x))+(((4*x)*x)*d_x_d_vsb__+((4*x)*d_x_d_vsb__+(4*d_x_d_vsb__)*x)*x))+d_Qinv_d_vsb__*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*den-(Qinv*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*d_den_d_vsb__)/den^2;
        d_qsc_d_vdib__ = ((Qinv*((((12*d_x_d_vdib__))+((8*x)*d_x_d_vdib__+(8*d_x_d_vdib__)*x))+(((4*x)*x)*d_x_d_vdib__+((4*x)*d_x_d_vdib__+(4*d_x_d_vdib__)*x)*x))+d_Qinv_d_vdib__*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*den-(Qinv*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*d_den_d_vdib__)/den^2;
        d_qsc_d_vsib__ = ((Qinv*((((12*d_x_d_vsib__))+((8*x)*d_x_d_vsib__+(8*d_x_d_vsib__)*x))+(((4*x)*x)*d_x_d_vsib__+((4*x)*d_x_d_vsib__+(4*d_x_d_vsib__)*x)*x))+d_Qinv_d_vsib__*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*den-(Qinv*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))*d_den_d_vsib__)/den^2;
    qsc = (Qinv*(((6+12*x)+(8*x)*x)+((4*x)*x)*x))/den;
        d_qdc_d_vdb__ = ((Qinv*((((8*d_x_d_vdb__))+((12*x)*d_x_d_vdb__+(12*d_x_d_vdb__)*x))+(((6*x)*x)*d_x_d_vdb__+((6*x)*d_x_d_vdb__+(6*d_x_d_vdb__)*x)*x))+d_Qinv_d_vdb__*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*den-(Qinv*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*d_den_d_vdb__)/den^2;
        d_qdc_d_vgb__ = ((Qinv*((((8*d_x_d_vgb__))+((12*x)*d_x_d_vgb__+(12*d_x_d_vgb__)*x))+(((6*x)*x)*d_x_d_vgb__+((6*x)*d_x_d_vgb__+(6*d_x_d_vgb__)*x)*x))+d_Qinv_d_vgb__*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*den-(Qinv*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*d_den_d_vgb__)/den^2;
        d_qdc_d_vsb__ = ((Qinv*((((8*d_x_d_vsb__))+((12*x)*d_x_d_vsb__+(12*d_x_d_vsb__)*x))+(((6*x)*x)*d_x_d_vsb__+((6*x)*d_x_d_vsb__+(6*d_x_d_vsb__)*x)*x))+d_Qinv_d_vsb__*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*den-(Qinv*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*d_den_d_vsb__)/den^2;
        d_qdc_d_vdib__ = ((Qinv*((((8*d_x_d_vdib__))+((12*x)*d_x_d_vdib__+(12*d_x_d_vdib__)*x))+(((6*x)*x)*d_x_d_vdib__+((6*x)*d_x_d_vdib__+(6*d_x_d_vdib__)*x)*x))+d_Qinv_d_vdib__*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*den-(Qinv*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*d_den_d_vdib__)/den^2;
        d_qdc_d_vsib__ = ((Qinv*((((8*d_x_d_vsib__))+((12*x)*d_x_d_vsib__+(12*d_x_d_vsib__)*x))+(((6*x)*x)*d_x_d_vsib__+((6*x)*d_x_d_vsib__+(6*d_x_d_vsib__)*x)*x))+d_Qinv_d_vsib__*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*den-(Qinv*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))*d_den_d_vsib__)/den^2;
    qdc = (Qinv*(((4+8*x)+(12*x)*x)+((6*x)*x)*x))/den;
        d_qi_d_vdb__ = d_qsc_d_vdb__+d_qdc_d_vdb__;
        d_qi_d_vgb__ = d_qsc_d_vgb__+d_qdc_d_vgb__;
        d_qi_d_vsb__ = d_qsc_d_vsb__+d_qdc_d_vsb__;
        d_qi_d_vdib__ = d_qsc_d_vdib__+d_qdc_d_vdib__;
        d_qi_d_vsib__ = d_qsc_d_vsib__+d_qdc_d_vsib__;
    qi = qsc+qdc;
    kq = 0;
    tol = ((((1e-10*parm_vxo)/100)*((1e-10*parm_vxo)/100))*me)/(2*1.6022e-19);
    if Vdsi<=tol
            d_kq2_d_vdib__ = (((((2*1.6022e-19)/me)*d_Vdsi_d_vdib__)*(vx0*vx0))/(vx0*vx0)^2)*10000;
            d_kq2_d_vsib__ = (((((2*1.6022e-19)/me)*d_Vdsi_d_vsib__)*(vx0*vx0))/(vx0*vx0)^2)*10000;
        kq2 = ((((2*1.6022e-19)/me)*Vdsi)/(vx0*vx0))*10000;
            d_kq4_d_vdib__ = kq2*d_kq2_d_vdib__+d_kq2_d_vdib__*kq2;
            d_kq4_d_vsib__ = kq2*d_kq2_d_vsib__+d_kq2_d_vsib__*kq2;
        kq4 = kq2*kq2;
            d_qsb_d_vdb__ = d_Qinv_d_vdb__*((0.5-kq2/24)+kq4/80);
            d_qsb_d_vgb__ = d_Qinv_d_vgb__*((0.5-kq2/24)+kq4/80);
            d_qsb_d_vsb__ = d_Qinv_d_vsb__*((0.5-kq2/24)+kq4/80);
            d_qsb_d_vdib__ = Qinv*((-(d_kq2_d_vdib__*24)/24^2)+(d_kq4_d_vdib__*80)/80^2)+d_Qinv_d_vdib__*((0.5-kq2/24)+kq4/80);
            d_qsb_d_vsib__ = Qinv*((-(d_kq2_d_vsib__*24)/24^2)+(d_kq4_d_vsib__*80)/80^2)+d_Qinv_d_vsib__*((0.5-kq2/24)+kq4/80);
        qsb = Qinv*((0.5-kq2/24)+kq4/80);
            d_qdb_d_vdb__ = d_Qinv_d_vdb__*((0.5-0.125*kq2)+kq4/16);
            d_qdb_d_vgb__ = d_Qinv_d_vgb__*((0.5-0.125*kq2)+kq4/16);
            d_qdb_d_vsb__ = d_Qinv_d_vsb__*((0.5-0.125*kq2)+kq4/16);
            d_qdb_d_vdib__ = Qinv*((-(0.125*d_kq2_d_vdib__))+(d_kq4_d_vdib__*16)/16^2)+d_Qinv_d_vdib__*((0.5-0.125*kq2)+kq4/16);
            d_qdb_d_vsib__ = Qinv*((-(0.125*d_kq2_d_vsib__))+(d_kq4_d_vsib__*16)/16^2)+d_Qinv_d_vsib__*((0.5-0.125*kq2)+kq4/16);
        qdb = Qinv*((0.5-0.125*kq2)+kq4/16);
    else
            d_kq_d_vdib__ = (((d_sqrt_d_arg1__(((2*1.6022e-19)/me)*Vdsi)*(((2*1.6022e-19)/me)*d_Vdsi_d_vdib__))*vx0)/vx0^2)*100;
            d_kq_d_vsib__ = (((d_sqrt_d_arg1__(((2*1.6022e-19)/me)*Vdsi)*(((2*1.6022e-19)/me)*d_Vdsi_d_vsib__))*vx0)/vx0^2)*100;
        kq = (sqrt(((2*1.6022e-19)/me)*Vdsi)/vx0)*100;
            d_kq2_d_vdib__ = kq*d_kq_d_vdib__+d_kq_d_vdib__*kq;
            d_kq2_d_vsib__ = kq*d_kq_d_vsib__+d_kq_d_vsib__*kq;
        kq2 = kq*kq;
            d_qsb_d_vdb__ = d_Qinv_d_vdb__*(asinh(kq)/kq-(sqrt(kq2+1)-1)/kq2);
            d_qsb_d_vgb__ = d_Qinv_d_vgb__*(asinh(kq)/kq-(sqrt(kq2+1)-1)/kq2);
            d_qsb_d_vsb__ = d_Qinv_d_vsb__*(asinh(kq)/kq-(sqrt(kq2+1)-1)/kq2);
            d_qsb_d_vdib__ = Qinv*(((d_asinh_d_arg1__(kq)*d_kq_d_vdib__)*kq-asinh(kq)*d_kq_d_vdib__)/kq^2-((d_sqrt_d_arg1__(kq2+1)*(d_kq2_d_vdib__))*kq2-(sqrt(kq2+1)-1)*d_kq2_d_vdib__)/kq2^2)+d_Qinv_d_vdib__*(asinh(kq)/kq-(sqrt(kq2+1)-1)/kq2);
            d_qsb_d_vsib__ = Qinv*(((d_asinh_d_arg1__(kq)*d_kq_d_vsib__)*kq-asinh(kq)*d_kq_d_vsib__)/kq^2-((d_sqrt_d_arg1__(kq2+1)*(d_kq2_d_vsib__))*kq2-(sqrt(kq2+1)-1)*d_kq2_d_vsib__)/kq2^2)+d_Qinv_d_vsib__*(asinh(kq)/kq-(sqrt(kq2+1)-1)/kq2);
        qsb = Qinv*(asinh(kq)/kq-(sqrt(kq2+1)-1)/kq2);
            d_qdb_d_vdb__ = d_Qinv_d_vdb__*((sqrt(kq2+1)-1)/kq2);
            d_qdb_d_vgb__ = d_Qinv_d_vgb__*((sqrt(kq2+1)-1)/kq2);
            d_qdb_d_vsb__ = d_Qinv_d_vsb__*((sqrt(kq2+1)-1)/kq2);
            d_qdb_d_vdib__ = Qinv*(((d_sqrt_d_arg1__(kq2+1)*(d_kq2_d_vdib__))*kq2-(sqrt(kq2+1)-1)*d_kq2_d_vdib__)/kq2^2)+d_Qinv_d_vdib__*((sqrt(kq2+1)-1)/kq2);
            d_qdb_d_vsib__ = Qinv*(((d_sqrt_d_arg1__(kq2+1)*(d_kq2_d_vsib__))*kq2-(sqrt(kq2+1)-1)*d_kq2_d_vsib__)/kq2^2)+d_Qinv_d_vsib__*((sqrt(kq2+1)-1)/kq2);
        qdb = Qinv*((sqrt(kq2+1)-1)/kq2);
    end
    if parm_CTM_select==1
            d_qs_d_vdb__ = d_qsc_d_vdb__;
            d_qs_d_vgb__ = d_qsc_d_vgb__;
            d_qs_d_vsb__ = d_qsc_d_vsb__;
            d_qs_d_vdib__ = d_qsc_d_vdib__;
            d_qs_d_vsib__ = d_qsc_d_vsib__;
        qs = qsc;
            d_qd_d_vdb__ = d_qdc_d_vdb__;
            d_qd_d_vgb__ = d_qdc_d_vgb__;
            d_qd_d_vsb__ = d_qdc_d_vsb__;
            d_qd_d_vdib__ = d_qdc_d_vdib__;
            d_qd_d_vsib__ = d_qdc_d_vsib__;
        qd = qdc;
    else
            d_qs_d_vdb__ = (qsc*(-(Fsatq*d_Fsatq_d_vdb__+d_Fsatq_d_vdb__*Fsatq))+d_qsc_d_vdb__*(1-Fsatq*Fsatq))+((qsb*Fsatq)*d_Fsatq_d_vdb__+(qsb*d_Fsatq_d_vdb__+d_qsb_d_vdb__*Fsatq)*Fsatq);
            d_qs_d_vgb__ = (qsc*(-(Fsatq*d_Fsatq_d_vgb__+d_Fsatq_d_vgb__*Fsatq))+d_qsc_d_vgb__*(1-Fsatq*Fsatq))+((qsb*Fsatq)*d_Fsatq_d_vgb__+(qsb*d_Fsatq_d_vgb__+d_qsb_d_vgb__*Fsatq)*Fsatq);
            d_qs_d_vsb__ = (qsc*(-(Fsatq*d_Fsatq_d_vsb__+d_Fsatq_d_vsb__*Fsatq))+d_qsc_d_vsb__*(1-Fsatq*Fsatq))+((qsb*Fsatq)*d_Fsatq_d_vsb__+(qsb*d_Fsatq_d_vsb__+d_qsb_d_vsb__*Fsatq)*Fsatq);
            d_qs_d_vdib__ = (qsc*(-(Fsatq*d_Fsatq_d_vdib__+d_Fsatq_d_vdib__*Fsatq))+d_qsc_d_vdib__*(1-Fsatq*Fsatq))+((qsb*Fsatq)*d_Fsatq_d_vdib__+(qsb*d_Fsatq_d_vdib__+d_qsb_d_vdib__*Fsatq)*Fsatq);
            d_qs_d_vsib__ = (qsc*(-(Fsatq*d_Fsatq_d_vsib__+d_Fsatq_d_vsib__*Fsatq))+d_qsc_d_vsib__*(1-Fsatq*Fsatq))+((qsb*Fsatq)*d_Fsatq_d_vsib__+(qsb*d_Fsatq_d_vsib__+d_qsb_d_vsib__*Fsatq)*Fsatq);
        qs = qsc*(1-Fsatq*Fsatq)+(qsb*Fsatq)*Fsatq;
            d_qd_d_vdb__ = (qdc*(-(Fsatq*d_Fsatq_d_vdb__+d_Fsatq_d_vdb__*Fsatq))+d_qdc_d_vdb__*(1-Fsatq*Fsatq))+((qdb*Fsatq)*d_Fsatq_d_vdb__+(qdb*d_Fsatq_d_vdb__+d_qdb_d_vdb__*Fsatq)*Fsatq);
            d_qd_d_vgb__ = (qdc*(-(Fsatq*d_Fsatq_d_vgb__+d_Fsatq_d_vgb__*Fsatq))+d_qdc_d_vgb__*(1-Fsatq*Fsatq))+((qdb*Fsatq)*d_Fsatq_d_vgb__+(qdb*d_Fsatq_d_vgb__+d_qdb_d_vgb__*Fsatq)*Fsatq);
            d_qd_d_vsb__ = (qdc*(-(Fsatq*d_Fsatq_d_vsb__+d_Fsatq_d_vsb__*Fsatq))+d_qdc_d_vsb__*(1-Fsatq*Fsatq))+((qdb*Fsatq)*d_Fsatq_d_vsb__+(qdb*d_Fsatq_d_vsb__+d_qdb_d_vsb__*Fsatq)*Fsatq);
            d_qd_d_vdib__ = (qdc*(-(Fsatq*d_Fsatq_d_vdib__+d_Fsatq_d_vdib__*Fsatq))+d_qdc_d_vdib__*(1-Fsatq*Fsatq))+((qdb*Fsatq)*d_Fsatq_d_vdib__+(qdb*d_Fsatq_d_vdib__+d_qdb_d_vdib__*Fsatq)*Fsatq);
            d_qd_d_vsib__ = (qdc*(-(Fsatq*d_Fsatq_d_vsib__+d_Fsatq_d_vsib__*Fsatq))+d_qdc_d_vsib__*(1-Fsatq*Fsatq))+((qdb*Fsatq)*d_Fsatq_d_vsib__+(qdb*d_Fsatq_d_vsib__+d_qdb_d_vsib__*Fsatq)*Fsatq);
        qd = qdc*(1-Fsatq*Fsatq)+(qdb*Fsatq)*Fsatq;
    end
        d_Qb_d_vdb__ = ((-parm_type*parm_W)*Leff)*(((parm_Cg*parm_gamma)*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vdb__))))+((((a-1)/(1*a))*Qinv)*(-d_qi_d_vdb__)+(((a-1)/(1*a))*d_Qinv_d_vdb__+(((d_a_d_vdb__)*(1*a)-(a-1)*(1*d_a_d_vdb__))/(1*a)^2)*Qinv)*(1-qi)));
        d_Qb_d_vgb__ = ((-parm_type*parm_W)*Leff)*(((parm_Cg*parm_gamma)*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vgb__))))+((((a-1)/(1*a))*Qinv)*(-d_qi_d_vgb__)+(((a-1)/(1*a))*d_Qinv_d_vgb__+(((d_a_d_vgb__)*(1*a)-(a-1)*(1*d_a_d_vgb__))/(1*a)^2)*Qinv)*(1-qi)));
        d_Qb_d_vsb__ = ((-parm_type*parm_W)*Leff)*(((parm_Cg*parm_gamma)*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vsb__))))+((((a-1)/(1*a))*Qinv)*(-d_qi_d_vsb__)+(((a-1)/(1*a))*d_Qinv_d_vsb__+(((d_a_d_vsb__)*(1*a)-(a-1)*(1*d_a_d_vsb__))/(1*a)^2)*Qinv)*(1-qi)));
        d_Qb_d_vdib__ = ((-parm_type*parm_W)*Leff)*(((parm_Cg*parm_gamma)*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vdib__-d_Vbsi_d_vdib__))))+((((a-1)/(1*a))*Qinv)*(-d_qi_d_vdib__)+(((a-1)/(1*a))*d_Qinv_d_vdib__+(((d_a_d_vdib__)*(1*a)-(a-1)*(1*d_a_d_vdib__))/(1*a)^2)*Qinv)*(1-qi)));
        d_Qb_d_vsib__ = ((-parm_type*parm_W)*Leff)*(((parm_Cg*parm_gamma)*(d_sqrt_d_arg1__(abs(psis-Vbsi))*(d_abs_d_arg1__(psis-Vbsi)*(d_psis_d_vsib__-d_Vbsi_d_vsib__))))+((((a-1)/(1*a))*Qinv)*(-d_qi_d_vsib__)+(((a-1)/(1*a))*d_Qinv_d_vsib__+(((d_a_d_vsib__)*(1*a)-(a-1)*(1*d_a_d_vsib__))/(1*a)^2)*Qinv)*(1-qi)));
    Qb = ((-parm_type*parm_W)*Leff)*((parm_Cg*parm_gamma)*sqrt(abs(psis-Vbsi))+(((a-1)/(1*a))*Qinv)*(1-qi));
        d_etai_d_vdb__ = ((-(-(d_FF_d_vdb__*aphit)))*nphit-(Vgsi-(Vt0bs0-FF*aphit))*d_nphit_d_vdb__)/nphit^2;
        d_etai_d_vgb__ = ((d_Vgsi_d_vgb__-(-(d_FF_d_vgb__*aphit)))*nphit)/nphit^2;
        d_etai_d_vsb__ = ((-(-(d_FF_d_vsb__*aphit)))*nphit-(Vgsi-(Vt0bs0-FF*aphit))*d_nphit_d_vsb__)/nphit^2;
        d_etai_d_vdib__ = ((d_Vgsi_d_vdib__-(d_Vt0bs0_d_vdib__-(d_FF_d_vdib__*aphit)))*nphit)/nphit^2;
        d_etai_d_vsib__ = ((d_Vgsi_d_vsib__-(d_Vt0bs0_d_vsib__-(d_FF_d_vsib__*aphit)))*nphit)/nphit^2;
    etai = (Vgsi-(Vt0bs0-FF*aphit))/nphit;
    if etai<=40
            d_Qinvi_d_vdb__ = Qref*(d_log_d_arg1__(1+exp(etai))*(d_exp_d_arg1__(etai)*d_etai_d_vdb__))+d_Qref_d_vdb__*log(1+exp(etai));
            d_Qinvi_d_vgb__ = Qref*(d_log_d_arg1__(1+exp(etai))*(d_exp_d_arg1__(etai)*d_etai_d_vgb__));
            d_Qinvi_d_vsb__ = Qref*(d_log_d_arg1__(1+exp(etai))*(d_exp_d_arg1__(etai)*d_etai_d_vsb__))+d_Qref_d_vsb__*log(1+exp(etai));
            d_Qinvi_d_vdib__ = Qref*(d_log_d_arg1__(1+exp(etai))*(d_exp_d_arg1__(etai)*d_etai_d_vdib__));
            d_Qinvi_d_vsib__ = Qref*(d_log_d_arg1__(1+exp(etai))*(d_exp_d_arg1__(etai)*d_etai_d_vsib__));
        Qinvi = Qref*log(1+exp(etai));
    else
            d_Qinvi_d_vdb__ = Qref*d_etai_d_vdb__+d_Qref_d_vdb__*etai;
            d_Qinvi_d_vgb__ = Qref*d_etai_d_vgb__;
            d_Qinvi_d_vsb__ = Qref*d_etai_d_vsb__+d_Qref_d_vsb__*etai;
            d_Qinvi_d_vdib__ = Qref*d_etai_d_vdib__;
            d_Qinvi_d_vsib__ = Qref*d_etai_d_vsib__;
        Qinvi = Qref*etai;
    end
        d_dQinv_d_vdb__ = d_Qinv_d_vdb__-d_Qinvi_d_vdb__;
        d_dQinv_d_vgb__ = d_Qinv_d_vgb__-d_Qinvi_d_vgb__;
        d_dQinv_d_vsb__ = d_Qinv_d_vsb__-d_Qinvi_d_vsb__;
        d_dQinv_d_vdib__ = d_Qinv_d_vdib__-d_Qinvi_d_vdib__;
        d_dQinv_d_vsib__ = d_Qinv_d_vsib__-d_Qinvi_d_vsib__;
    dQinv = Qinv-Qinvi;
        d_dibl_corr_d_vdb__ = (((1-FF0)*(1-Fsatq))*qi)*d_dQinv_d_vdb__+(((1-FF0)*(1-Fsatq))*d_qi_d_vdb__+((1-FF0)*(-d_Fsatq_d_vdb__))*qi)*dQinv;
        d_dibl_corr_d_vgb__ = (((1-FF0)*(1-Fsatq))*qi)*d_dQinv_d_vgb__+(((1-FF0)*(1-Fsatq))*d_qi_d_vgb__+((1-FF0)*(-d_Fsatq_d_vgb__)+(-d_FF0_d_vgb__)*(1-Fsatq))*qi)*dQinv;
        d_dibl_corr_d_vsb__ = (((1-FF0)*(1-Fsatq))*qi)*d_dQinv_d_vsb__+(((1-FF0)*(1-Fsatq))*d_qi_d_vsb__+((1-FF0)*(-d_Fsatq_d_vsb__))*qi)*dQinv;
        d_dibl_corr_d_vdib__ = (((1-FF0)*(1-Fsatq))*qi)*d_dQinv_d_vdib__+(((1-FF0)*(1-Fsatq))*d_qi_d_vdib__+((1-FF0)*(-d_Fsatq_d_vdib__)+(-d_FF0_d_vdib__)*(1-Fsatq))*qi)*dQinv;
        d_dibl_corr_d_vsib__ = (((1-FF0)*(1-Fsatq))*qi)*d_dQinv_d_vsib__+(((1-FF0)*(1-Fsatq))*d_qi_d_vsib__+((1-FF0)*(-d_Fsatq_d_vsib__)+(-d_FF0_d_vsib__)*(1-Fsatq))*qi)*dQinv;
    dibl_corr = (((1-FF0)*(1-Fsatq))*qi)*dQinv;
        d_qd_d_vdb__ = d_qd_d_vdb__-d_dibl_corr_d_vdb__;
        d_qd_d_vgb__ = d_qd_d_vgb__-d_dibl_corr_d_vgb__;
        d_qd_d_vsb__ = d_qd_d_vsb__-d_dibl_corr_d_vsb__;
        d_qd_d_vdib__ = d_qd_d_vdib__-d_dibl_corr_d_vdib__;
        d_qd_d_vsib__ = d_qd_d_vsib__-d_dibl_corr_d_vsib__;
    qd = qd-dibl_corr;
        d_Qinvs_d_vdb__ = (((parm_type*Leff)*(((1+dir)*d_qs_d_vdb__)+((1-dir)*d_qd_d_vdb__)))*2)/2^2;
        d_Qinvs_d_vgb__ = (((parm_type*Leff)*(((1+dir)*d_qs_d_vgb__)+((1-dir)*d_qd_d_vgb__)))*2)/2^2;
        d_Qinvs_d_vsb__ = (((parm_type*Leff)*(((1+dir)*d_qs_d_vsb__)+((1-dir)*d_qd_d_vsb__)))*2)/2^2;
        d_Qinvs_d_vdib__ = (((parm_type*Leff)*(((1+dir)*d_qs_d_vdib__)+((1-dir)*d_qd_d_vdib__)))*2)/2^2;
        d_Qinvs_d_vsib__ = (((parm_type*Leff)*(((1+dir)*d_qs_d_vsib__)+((1-dir)*d_qd_d_vsib__)))*2)/2^2;
    Qinvs = ((parm_type*Leff)*((1+dir)*qs+(1-dir)*qd))/2;
        d_Qinvd_d_vdb__ = (((parm_type*Leff)*(((1-dir)*d_qs_d_vdb__)+((1+dir)*d_qd_d_vdb__)))*2)/2^2;
        d_Qinvd_d_vgb__ = (((parm_type*Leff)*(((1-dir)*d_qs_d_vgb__)+((1+dir)*d_qd_d_vgb__)))*2)/2^2;
        d_Qinvd_d_vsb__ = (((parm_type*Leff)*(((1-dir)*d_qs_d_vsb__)+((1+dir)*d_qd_d_vsb__)))*2)/2^2;
        d_Qinvd_d_vdib__ = (((parm_type*Leff)*(((1-dir)*d_qs_d_vdib__)+((1+dir)*d_qd_d_vdib__)))*2)/2^2;
        d_Qinvd_d_vsib__ = (((parm_type*Leff)*(((1-dir)*d_qs_d_vsib__)+((1+dir)*d_qd_d_vsib__)))*2)/2^2;
    Qinvd = ((parm_type*Leff)*((1-dir)*qs+(1+dir)*qd))/2;
        d_Qsov_d_vgb__ = Cofs*1;
        d_Qsov_d_vsib__ = Cofs*-1;
    Qsov = Cofs*vgsi__;
        d_Qdov_d_vgb__ = Cofd*1;
        d_Qdov_d_vdib__ = Cofd*-1;
    Qdov = Cofd*vgdi__;
        d_Vt0x_d_vsib__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-parm_type*vbsi__))*(d_abs_d_arg1__(parm_phib-parm_type*vbsi__)*(-(parm_type*-1)))));
    Vt0x = parm_Vt0+parm_gamma*(sqrt(abs(parm_phib-parm_type*vbsi__))-sqrt(parm_phib));
        d_Vt0y_d_vdib__ = (parm_gamma*(d_sqrt_d_arg1__(abs(parm_phib-parm_type*vbdi__))*(d_abs_d_arg1__(parm_phib-parm_type*vbdi__)*(-(parm_type*-1)))));
    Vt0y = parm_Vt0+parm_gamma*(sqrt(abs(parm_phib-parm_type*vbdi__))-sqrt(parm_phib));
        d_Fs_arg_d_vdb__ = (((-(-((Vdsi*parm_delta)*d_Fsat_d_vdb__))))*(1.1*nphit)-((Vgsraw-(Vt0x-(Vdsi*parm_delta)*Fsat))+aphit*0.5)*(1.1*d_nphit_d_vdb__))/(1.1*nphit)^2;
        d_Fs_arg_d_vgb__ = (((d_Vgsraw_d_vgb__-(-((Vdsi*parm_delta)*d_Fsat_d_vgb__))))*(1.1*nphit))/(1.1*nphit)^2;
        d_Fs_arg_d_vsb__ = (((-(-((Vdsi*parm_delta)*d_Fsat_d_vsb__))))*(1.1*nphit)-((Vgsraw-(Vt0x-(Vdsi*parm_delta)*Fsat))+aphit*0.5)*(1.1*d_nphit_d_vsb__))/(1.1*nphit)^2;
        d_Fs_arg_d_vdib__ = (((-(-((Vdsi*parm_delta)*d_Fsat_d_vdib__+(d_Vdsi_d_vdib__*parm_delta)*Fsat))))*(1.1*nphit))/(1.1*nphit)^2;
        d_Fs_arg_d_vsib__ = (((d_Vgsraw_d_vsib__-(d_Vt0x_d_vsib__-((Vdsi*parm_delta)*d_Fsat_d_vsib__+(d_Vdsi_d_vsib__*parm_delta)*Fsat))))*(1.1*nphit))/(1.1*nphit)^2;
    Fs_arg = ((Vgsraw-(Vt0x-(Vdsi*parm_delta)*Fsat))+aphit*0.5)/(1.1*nphit);
    if Fs_arg<=40
            d_Fs_d_vdb__ = d_exp_d_arg1__(Fs_arg)*d_Fs_arg_d_vdb__;
            d_Fs_d_vgb__ = d_exp_d_arg1__(Fs_arg)*d_Fs_arg_d_vgb__;
            d_Fs_d_vsb__ = d_exp_d_arg1__(Fs_arg)*d_Fs_arg_d_vsb__;
            d_Fs_d_vdib__ = d_exp_d_arg1__(Fs_arg)*d_Fs_arg_d_vdib__;
            d_Fs_d_vsib__ = d_exp_d_arg1__(Fs_arg)*d_Fs_arg_d_vsib__;
        Fs = 1+exp(Fs_arg);
            d_FFx_d_vdb__ = -(nphit*(d_log_d_arg1__(Fs)*d_Fs_d_vdb__)+d_nphit_d_vdb__*log(Fs));
            d_FFx_d_vgb__ = d_Vgsraw_d_vgb__-(nphit*(d_log_d_arg1__(Fs)*d_Fs_d_vgb__));
            d_FFx_d_vsb__ = -(nphit*(d_log_d_arg1__(Fs)*d_Fs_d_vsb__)+d_nphit_d_vsb__*log(Fs));
            d_FFx_d_vdib__ = -(nphit*(d_log_d_arg1__(Fs)*d_Fs_d_vdib__));
            d_FFx_d_vsib__ = d_Vgsraw_d_vsib__-(nphit*(d_log_d_arg1__(Fs)*d_Fs_d_vsib__));
        FFx = Vgsraw-nphit*log(Fs);
    else
        Fs = 0;
            d_FFx_d_vdb__ = -(nphit*d_Fs_arg_d_vdb__+d_nphit_d_vdb__*Fs_arg);
            d_FFx_d_vgb__ = d_Vgsraw_d_vgb__-(nphit*d_Fs_arg_d_vgb__);
            d_FFx_d_vsb__ = -(nphit*d_Fs_arg_d_vsb__+d_nphit_d_vsb__*Fs_arg);
            d_FFx_d_vdib__ = -(nphit*d_Fs_arg_d_vdib__);
            d_FFx_d_vsib__ = d_Vgsraw_d_vsib__-(nphit*d_Fs_arg_d_vsib__);
        FFx = Vgsraw-nphit*Fs_arg;
    end
        d_Fd_arg_d_vdb__ = (((-(-((Vdsi*parm_delta)*d_Fsat_d_vdb__))))*(1.1*nphit)-((Vgdraw-(Vt0y-(Vdsi*parm_delta)*Fsat))+aphit*0.5)*(1.1*d_nphit_d_vdb__))/(1.1*nphit)^2;
        d_Fd_arg_d_vgb__ = (((d_Vgdraw_d_vgb__-(-((Vdsi*parm_delta)*d_Fsat_d_vgb__))))*(1.1*nphit))/(1.1*nphit)^2;
        d_Fd_arg_d_vsb__ = (((-(-((Vdsi*parm_delta)*d_Fsat_d_vsb__))))*(1.1*nphit)-((Vgdraw-(Vt0y-(Vdsi*parm_delta)*Fsat))+aphit*0.5)*(1.1*d_nphit_d_vsb__))/(1.1*nphit)^2;
        d_Fd_arg_d_vdib__ = (((d_Vgdraw_d_vdib__-(d_Vt0y_d_vdib__-((Vdsi*parm_delta)*d_Fsat_d_vdib__+(d_Vdsi_d_vdib__*parm_delta)*Fsat))))*(1.1*nphit))/(1.1*nphit)^2;
        d_Fd_arg_d_vsib__ = (((-(-((Vdsi*parm_delta)*d_Fsat_d_vsib__+(d_Vdsi_d_vsib__*parm_delta)*Fsat))))*(1.1*nphit))/(1.1*nphit)^2;
    Fd_arg = ((Vgdraw-(Vt0y-(Vdsi*parm_delta)*Fsat))+aphit*0.5)/(1.1*nphit);
    if Fd_arg<=40
            d_Fd_d_vdb__ = d_exp_d_arg1__(Fd_arg)*d_Fd_arg_d_vdb__;
            d_Fd_d_vgb__ = d_exp_d_arg1__(Fd_arg)*d_Fd_arg_d_vgb__;
            d_Fd_d_vsb__ = d_exp_d_arg1__(Fd_arg)*d_Fd_arg_d_vsb__;
            d_Fd_d_vdib__ = d_exp_d_arg1__(Fd_arg)*d_Fd_arg_d_vdib__;
            d_Fd_d_vsib__ = d_exp_d_arg1__(Fd_arg)*d_Fd_arg_d_vsib__;
        Fd = 1+exp(Fd_arg);
            d_FFy_d_vdb__ = -(nphit*(d_log_d_arg1__(Fd)*d_Fd_d_vdb__)+d_nphit_d_vdb__*log(Fd));
            d_FFy_d_vgb__ = d_Vgdraw_d_vgb__-(nphit*(d_log_d_arg1__(Fd)*d_Fd_d_vgb__));
            d_FFy_d_vsb__ = -(nphit*(d_log_d_arg1__(Fd)*d_Fd_d_vsb__)+d_nphit_d_vsb__*log(Fd));
            d_FFy_d_vdib__ = d_Vgdraw_d_vdib__-(nphit*(d_log_d_arg1__(Fd)*d_Fd_d_vdib__));
            d_FFy_d_vsib__ = -(nphit*(d_log_d_arg1__(Fd)*d_Fd_d_vsib__));
        FFy = Vgdraw-nphit*log(Fd);
    else
        Fd = 0;
            d_FFy_d_vdb__ = -(nphit*d_Fd_arg_d_vdb__+d_nphit_d_vdb__*Fd_arg);
            d_FFy_d_vgb__ = d_Vgdraw_d_vgb__-(nphit*d_Fd_arg_d_vgb__);
            d_FFy_d_vsb__ = -(nphit*d_Fd_arg_d_vsb__+d_nphit_d_vsb__*Fd_arg);
            d_FFy_d_vdib__ = d_Vgdraw_d_vdib__-(nphit*d_Fd_arg_d_vdib__);
            d_FFy_d_vsib__ = -(nphit*d_Fd_arg_d_vsib__);
        FFy = Vgdraw-nphit*Fd_arg;
    end
        d_Qsif_d_vdb__ = (parm_type*(parm_Cif+parm_CC*Vgsraw))*d_FFx_d_vdb__;
        d_Qsif_d_vgb__ = (parm_type*(parm_Cif+parm_CC*Vgsraw))*d_FFx_d_vgb__+(parm_type*((parm_CC*d_Vgsraw_d_vgb__)))*FFx;
        d_Qsif_d_vsb__ = (parm_type*(parm_Cif+parm_CC*Vgsraw))*d_FFx_d_vsb__;
        d_Qsif_d_vdib__ = (parm_type*(parm_Cif+parm_CC*Vgsraw))*d_FFx_d_vdib__;
        d_Qsif_d_vsib__ = (parm_type*(parm_Cif+parm_CC*Vgsraw))*d_FFx_d_vsib__+(parm_type*((parm_CC*d_Vgsraw_d_vsib__)))*FFx;
    Qsif = (parm_type*(parm_Cif+parm_CC*Vgsraw))*FFx;
        d_Qdif_d_vdb__ = (parm_type*(parm_Cif+parm_CC*Vgdraw))*d_FFy_d_vdb__;
        d_Qdif_d_vgb__ = (parm_type*(parm_Cif+parm_CC*Vgdraw))*d_FFy_d_vgb__+(parm_type*((parm_CC*d_Vgdraw_d_vgb__)))*FFy;
        d_Qdif_d_vsb__ = (parm_type*(parm_Cif+parm_CC*Vgdraw))*d_FFy_d_vsb__;
        d_Qdif_d_vdib__ = (parm_type*(parm_Cif+parm_CC*Vgdraw))*d_FFy_d_vdib__+(parm_type*((parm_CC*d_Vgdraw_d_vdib__)))*FFy;
        d_Qdif_d_vsib__ = (parm_type*(parm_Cif+parm_CC*Vgdraw))*d_FFy_d_vsib__;
    Qdif = (parm_type*(parm_Cif+parm_CC*Vgdraw))*FFy;
        d_Qs_d_vdb__ = -parm_W*((d_Qinvs_d_vdb__)+d_Qsif_d_vdb__);
        d_Qs_d_vgb__ = -parm_W*((d_Qinvs_d_vgb__+d_Qsov_d_vgb__)+d_Qsif_d_vgb__);
        d_Qs_d_vsb__ = -parm_W*((d_Qinvs_d_vsb__)+d_Qsif_d_vsb__);
        d_Qs_d_vdib__ = -parm_W*((d_Qinvs_d_vdib__)+d_Qsif_d_vdib__);
        d_Qs_d_vsib__ = -parm_W*((d_Qinvs_d_vsib__+d_Qsov_d_vsib__)+d_Qsif_d_vsib__);
    Qs = -parm_W*((Qinvs+Qsov)+Qsif);
        d_Qd_d_vdb__ = -parm_W*((d_Qinvd_d_vdb__)+d_Qdif_d_vdb__);
        d_Qd_d_vgb__ = -parm_W*((d_Qinvd_d_vgb__+d_Qdov_d_vgb__)+d_Qdif_d_vgb__);
        d_Qd_d_vsb__ = -parm_W*((d_Qinvd_d_vsb__)+d_Qdif_d_vsb__);
        d_Qd_d_vdib__ = -parm_W*((d_Qinvd_d_vdib__+d_Qdov_d_vdib__)+d_Qdif_d_vdib__);
        d_Qd_d_vsib__ = -parm_W*((d_Qinvd_d_vsib__)+d_Qdif_d_vsib__);
    Qd = -parm_W*((Qinvd+Qdov)+Qdif);
        d_Qg_d_vdb__ = -((d_Qs_d_vdb__+d_Qd_d_vdb__)+d_Qb_d_vdb__);
        d_Qg_d_vgb__ = -((d_Qs_d_vgb__+d_Qd_d_vgb__)+d_Qb_d_vgb__);
        d_Qg_d_vsb__ = -((d_Qs_d_vsb__+d_Qd_d_vsb__)+d_Qb_d_vsb__);
        d_Qg_d_vdib__ = -((d_Qs_d_vdib__+d_Qd_d_vdib__)+d_Qb_d_vdib__);
        d_Qg_d_vsib__ = -((d_Qs_d_vsib__+d_Qd_d_vsib__)+d_Qb_d_vsib__);
    Qg = -((Qs+Qd)+Qb);
        d_fi_d_X__(1,1) = d_fi_d_X__(1,1) + (parm_type*dir)*d_Id_d_vdb__;
        d_fi_d_X__(2,1) = d_fi_d_X__(2,1) + -((parm_type*dir)*d_Id_d_vdb__);
        d_fi_d_X__(1,2) = d_fi_d_X__(1,2) + (parm_type*dir)*d_Id_d_vgb__;
        d_fi_d_X__(2,2) = d_fi_d_X__(2,2) + -((parm_type*dir)*d_Id_d_vgb__);
        d_fi_d_X__(1,3) = d_fi_d_X__(1,3) + (parm_type*dir)*d_Id_d_vsb__;
        d_fi_d_X__(2,3) = d_fi_d_X__(2,3) + -((parm_type*dir)*d_Id_d_vsb__);
        d_fi_d_Y__(1,1) = d_fi_d_Y__(1,1) + (parm_type*dir)*d_Id_d_vdib__;
        d_fi_d_Y__(2,1) = d_fi_d_Y__(2,1) + -((parm_type*dir)*d_Id_d_vdib__);
        d_fi_d_Y__(1,2) = d_fi_d_Y__(1,2) + (parm_type*dir)*d_Id_d_vsib__;
        d_fi_d_Y__(2,2) = d_fi_d_Y__(2,2) + -((parm_type*dir)*d_Id_d_vsib__);
    % contribution for idisi
    idisi_f__ = (parm_type*dir)*Id;
    fi__(1,1) = fi__(1,1) + idisi_f__;
    fi__(2,1) = fi__(2,1) + -idisi_f__;
        d_fe_d_X__(1,1) = d_fe_d_X__(1,1) + (1*Rd)/Rd^2;
        d_fi_d_X__(1,1) = d_fi_d_X__(1,1) + -((1*Rd)/Rd^2);
        d_fe_d_Y__(1,1) = d_fe_d_Y__(1,1) + (-1*Rd)/Rd^2;
        d_fi_d_Y__(1,1) = d_fi_d_Y__(1,1) + -((-1*Rd)/Rd^2);
    % contribution for iddi
    iddi_f__ = vddi__/Rd;
    fe__(1,1) = fe__(1,1) + iddi_f__;
    fi__(1,1) = fi__(1,1) + -iddi_f__;
        d_fi_d_X__(2,3) = d_fi_d_X__(2,3) + (-1*Rs)/Rs^2;
        d_fe_d_X__(3,3) = d_fe_d_X__(3,3) + -((-1*Rs)/Rs^2);
        d_fi_d_Y__(2,2) = d_fi_d_Y__(2,2) + (1*Rs)/Rs^2;
        d_fe_d_Y__(3,2) = d_fe_d_Y__(3,2) + -((1*Rs)/Rs^2);
    % contribution for isis
    isis_f__ = vsis__/Rs;
    fi__(2,1) = fi__(2,1) + isis_f__;
    fe__(3,1) = fe__(3,1) + -isis_f__;
        d_qi_d_X__(2,1) = d_qi_d_X__(2,1) + d_Qs_d_vdb__;
        d_qi_d_X__(2,2) = d_qi_d_X__(2,2) + d_Qs_d_vgb__;
        d_qi_d_X__(2,3) = d_qi_d_X__(2,3) + d_Qs_d_vsb__;
        d_qi_d_Y__(2,1) = d_qi_d_Y__(2,1) + d_Qs_d_vdib__;
        d_qi_d_Y__(2,2) = d_qi_d_Y__(2,2) + d_Qs_d_vsib__;
    % contribution for isib
    qi__(2,1) = qi__(2,1) + Qs;
        d_qi_d_X__(1,1) = d_qi_d_X__(1,1) + d_Qd_d_vdb__;
        d_qi_d_X__(1,2) = d_qi_d_X__(1,2) + d_Qd_d_vgb__;
        d_qi_d_X__(1,3) = d_qi_d_X__(1,3) + d_Qd_d_vsb__;
        d_qi_d_Y__(1,1) = d_qi_d_Y__(1,1) + d_Qd_d_vdib__;
        d_qi_d_Y__(1,2) = d_qi_d_Y__(1,2) + d_Qd_d_vsib__;
    % contribution for idib
    qi__(1,1) = qi__(1,1) + Qd;
        d_qe_d_X__(2,1) = d_qe_d_X__(2,1) + d_Qg_d_vdb__;
        d_qe_d_X__(2,2) = d_qe_d_X__(2,2) + d_Qg_d_vgb__;
        d_qe_d_X__(2,3) = d_qe_d_X__(2,3) + d_Qg_d_vsb__;
        d_qe_d_Y__(2,1) = d_qe_d_Y__(2,1) + d_Qg_d_vdib__;
        d_qe_d_Y__(2,2) = d_qe_d_Y__(2,2) + d_Qg_d_vsib__;
    % contribution for igb
    qe__(2,1) = qe__(2,1) + Qg;
end
