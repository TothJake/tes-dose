function predicted_EF = conv_predict_ef(montage, sex, age, circumference, cephalic_index, bmi, inter_elec_dist)
%% Predict 95th percentile E-field magnitude for conventional tES
%
% USAGE:
%   EF = conv_predict_ef([], 'M', 45, 565, 85, 25, 100);
%   EF = conv_predict_ef('FPzOz', 1, 45, 565, 85, 25); % Using 1 for Male, 0 for
%   Female, FPzOz montge
%   EF = conv_predict_ef([], [], 45, [], 85, [], 100); % Use [] to skip an input
%
%
% INPUTS:
%    montage         - Electrode montage: [] = montage-agnostic, 'F4Cz',
%   'C3FP2, 'F3F4', FPzOz', 'C3C4' or 'P3FP2'
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

% Montage-agnostic conventional model
if isempty(montage)
    model_name = 'Montage-agnostic conventional';
    
    % If inter-electrode distance missing assume 146mm
    if nargin < 7 || isempty(inter_elec_dist)
        inter_elec_dist = 146;
    end
    if ~isnumeric(inter_elec_dist)
        error('Inter-electode distance must be a numeric value.');
    end
    
    % Average montage-agnostic model coefficients
    S1_NMA = -4.651959e-05;
    S2_NMA   = 1.621965e-02;
    S3_NMA   = -2.952299e-01;
    B1_age = -0.000207;
    B2_HC  = -0.000331;
    B3_CI  = -0.001905;
    B4_BMI = -0.000601;
    B5_sex = -0.002520;
    B0_int = 0.503934;
    
    % Calculate Predicted E-Field
    predicted_EF = (S1_NMA*inter_elec_dist^2 + S2_NMA*inter_elec_dist + S3_NMA) * ...
        (B1_age  * age + B2_HC * circumference + B3_CI * cephalic_index +...
        B4_BMI * bmi + B5_sex * sex_val + B0_int);
else
    model_name = sprintf('Specific Montage: %s', montage);
    
    % Select model coefficients
    switch upper(montage)
        case 'F4CZ'
                B0_int = 0.399754944693886;
                B1_sex = -0.00747089856574117;
                B2_age = -0.000331755827305648;
                B3_HC  = -0.000388449390605738;
                B4_BMI = -5.58031259375544e-05;
                B5_CI  = -0.000541298342306448;

            case 'C3FP2'
                B0_int = 0.468540220888579;
                B1_sex = -0.00220209680109883;
                B2_age = -0.000426511122747654;
                B3_HC  = -0.000394029497461495;
                B4_BMI = -0.000873578829387184;
                B5_CI  = -0.000619228909000379;

            case 'F3F4'
                B0_int = 0.381641350632083;
                B1_sex = -0.00653535539679695;
                B2_age = -0.000295485966599489;
                B3_HC  = -0.000342444744607508;
                B4_BMI = -0.000398267619296884;
                B5_CI  = -0.000416208632853152;

            case 'P3FP2'
                B0_int = 0.471887505545167;
                B1_sex = -0.000420994260835202;
                B2_age = -0.000388453850874108;
                B3_HC  = -0.000404095415935842;
                B4_BMI = -0.000962776991899219;
                B5_CI  = -0.000583616989939069;

            case 'C3C4'
                B0_int = 0.44750501204692;
                B1_sex = -0.00815385338568549;
                B2_age = -0.000409853168657166;
                B3_HC  = -0.000419422813226706;
                B4_BMI = -0.000704515406787405;
                B5_CI  = -0.000373077763880644;

            case 'FPZOZ'
                B0_int = 0.464885850053167;
                B1_sex = 0.00296337597168954;
                B2_age = -0.000395392830663868;
                B3_HC  = -0.000372396919069926;
                B4_BMI = -0.00101333025745892;
                B5_CI  = -0.000906029343486404;
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
    if inter_elec_dist < 81.9 || inter_elec_dist > 226.5
        fprintf('WARNING: inter_elec_dist (%.1f) is outside bounds of training data.\n', inter_elec_dist);
        extrapolating = true;
    end
end
if extrapolating
    fprintf('Note: The model may not be accurate when extrapolating outside the training data.\n');
end

fprintf('Predicted Peak E-field (EF95th): %.4f V/m\n\n', predicted_EF);
end