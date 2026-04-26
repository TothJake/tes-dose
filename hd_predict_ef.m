function predicted_EF = hd_predict_ef(montage, sex, age, circumference, cephalic_index, bmi, inter_elec_dist)
%% Predict 95th percentile E-field magnitude for HD tES
%
% USAGE:
%   EF = hd_predict_ef([], 'M', 45, 565, 85, 25, 100);
%   EF = hd_predict_ef('F4', 1, 45, 565, 85, 25); % Using 1 for Male, 0 for
%   Female, for HD montage with anode at F4
%   EF = hd_predict_ef([], [], 45, [], 85, [], 100); % Use [] to skip an input
%
%
% INPUTS:
%    montage         - Electrode montage: [] = montage-agnostic, 'F4',
%    'C3', P3', 'PO8'. 'F4' corresponds to anode F3, cathodes F2, AF4, FC4,
%    F6. See paper for full montage details
%   sex             - Subject sex: 'M'/'F' or 1 (Male) / 0 (Female) [Default: 0.5]
%   age             - Age in years [Default: 52]
%   circumference   - Head circumference in mm [Default: 570 for M, 560 for F, 565 overall]
%   cephalic_index  - Cephalic index [Default: 83.1]
%   bmi             - BMI [Default: 24.05]
%   inter_elec_dist - Inter-electrode distance in mm [Default: 146]
%
% Transcranial Electrical Stimulation (tES) dose standardization
% Toth, J., Brosnan, M., King, RJ. et al.
% Dose standardization for transcranial electrical stimulation: an accessible approach.
% Sci Rep 15, 41791 (2025). https://doi.org/10.1038/s41598-025-25649-2

% Parse montage
if nargin < 1 || isempty(montage)
    montage = [];
end

% Parse sex first to determine conditional defaults
if nargin < 2 || isempty(sex)
    sex_val = 0.5;
    sex_str = 'Unknown';
elseif ischar(sex) || isstring(sex)
    if strcmpi(sex, 'M')
        sex_val = 1;
        sex_str = 'M';
    elseif strcmpi(sex, 'F')
        sex_val = 0;
        sex_str = 'F';
    else
        error('Input for sex incorrect. Please use 1 or ''M'' for male, 0 or ''F'' for female');
    end
else
    sex_val = sex;
    if sex_val == 1
        sex_str = 'M';
    elseif sex_val == 0
        sex_str = 'F';
    else
        error('Input for sex incorrect. Please use 1 or ''M'' for male, 0 or ''F'' for female');
    end
end

% If age is missing assume average age (52 years)
if nargin < 3 || isempty(age)
    age = 52;
end

% If head circumference is missing assume average circumference based on
% sex
if nargin < 4 || isempty(circumference)
    if sex_val == 1 % Male = 583mm
        circumference = 583;
    elseif sex_val == 0 % Female = 552mm
        circumference = 552;
    else
        circumference = 568;
    end
end

% If cephalic index missing, assume 83.1mm
if nargin < 5 || isempty(cephalic_index)
    cephalic_index = 83.1;
end

% If BMI missing assume 24.05
if nargin < 6 || isempty(bmi)
    bmi = 24.05; 
end

% Check if inputs are numeric
if ~isnumeric(age) || ~isnumeric(circumference) || ~isnumeric(cephalic_index) || ~isnumeric(bmi) 
    error('Age, circumference, cephalic index and bmi must be provided as numeric values.');
end

% Montage-agnostic HD model
if isempty(montage) 
    model_name = 'Montage-agnostic HD';
    
    % If inter-electrode distance missing assume 51mm
    if nargin < 7 || isempty(inter_elec_dist)
        fprintf("WARNING: Inter-electrode dist missing, assuming 51mm")
        inter_elec_dist = 51;
    end
    if ~isnumeric(inter_elec_dist)
        error('Inter-electode distance must be a numeric value.');
    end

    % Average montage-agnostic HD model coefficients
    S1_NMA = -1.203673e-03;
    S2_NMA   = 1.601366e-01;
    S3_NMA   = -3.365869e+00;
    B1_age = -0.000140;
    B2_HC  = -0.000086;
    B3_CI  = 0.000048;
    B4_BMI = -0.000315;
    B5_sex = -0.000206;
    B0_int = 0.090820;

    % Calculate Predicted E-Field
    predicted_EF = (S1_NMA*inter_elec_dist^2 + S2_NMA*inter_elec_dist + S3_NMA) * ...
        (B1_age  * age + B2_HC * circumference + B3_CI * cephalic_index +...
        B4_BMI * bmi + B5_sex * sex_val + B0_int);
else
   model_name = sprintf('Specific Montage: %s', montage);
   
   % Select model coefficients
    switch upper(montage)
        case 'F4'
            B0_int = 0.0461364723687334;
            B1_sex = -0.00167143143008014;
            B2_age = -4.7395080827485e-05;
            B3_HC  = -4.77303632942169e-05;
            B4_BMI = 5.896495849036e-06;
            B5_CI  = -2.40641736974436e-05;

        case 'C3'
            B0_int = 0.144850811257712;
            B1_sex = -0.00124822461213031;
            B2_age = -0.000253210042967931;
            B3_HC  = -0.000121714182520174;
            B4_BMI = -0.000588990031830882;
            B5_CI  = 0.000159781767023011;

        case 'P3'
            B0_int = 0.0258869466012188;
            B1_sex = 8.216155214396e-06;
            B2_age = -6.38319442577749e-05;
            B3_HC  = -2.76013074262366e-05;
            B4_BMI = -0.000195003683890504;
            B5_CI  = 0.000121959174704626;

        case 'PO8'
            B0_int = 0.125887571381383;
            B1_sex = 0.00330541011110517;
            B2_age = -0.000211236822816392;
            B3_HC  = -0.000118480417519507;
            B4_BMI = -0.000566206244380602;
            B5_CI  = 1.18658920479827e-05;
            
        otherwise
            error('Unknown montage specified. Please check spelling or leave empty [] for montage-agnostic.');
    end
     predicted_EF = B1_sex * sex_val + B2_age * age +...
        B3_HC * circumference + B4_BMI * bmi + B5_CI * cephalic_index +...
        B0_int;         
   
end

% Print output
fprintf('\nPrediction Results\n');
fprintf('Model: %s\n', model_name);
if isempty(montage)
    fprintf('Inputs: Sex=%s, Age=%.1f yrs, Circ=%.1f mm, L_W=%.1f, BMI=%.1f, ElecDist=%.1f mm\n', ...
        sex_str, age, circumference, cephalic_index, bmi, inter_elec_dist);
else
    fprintf('Inputs: Sex=%s, Age=%.1f yrs, Circ=%.1f mm, L_W=%.1f, BMI=%.1f\n', ...
        sex_str, age, circumference, cephalic_index, bmi);
end
% Warning if inputs are outside training bounds
extrapolating = false;
if age < 18 || age > 87
    fprintf('WARNING: Age (%.1f) is outside training bounds (18 - 87).\n', age);
    extrapolating = true;
end
if circumference < 520 || circumference > 623.2
    fprintf('WARNING: Circumference (%.1f) is outside bounds of training data.\n', circumference);
    extrapolating = true;
end
if cephalic_index < 73.2 || cephalic_index > 96.7
    fprintf('WARNING: Cephalic index (%.1f) is outside bounds of training data.\n', cephalic_index);
    extrapolating = true;
end
if bmi < 16.8 || bmi > 44.2
    fprintf('WARNING: BMI (%.1f) is outside bounds of training data.\n', bmi);
    extrapolating = true;
end
if isempty(montage)
    if inter_elec_dist < 28 || inter_elec_dist > 75
        fprintf('WARNING: inter_elec_dist (%.1f) is outside bounds of training data.\n', inter_elec_dist);
        extrapolating = true;
    end
end
if extrapolating
    fprintf('Note: The model may not be accurate when extrapolating outside the training data.\n');
end

fprintf('Predicted Peak E-field (EF95th): %.4f V/m\n\n', predicted_EF);
end