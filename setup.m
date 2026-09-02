filepath = fileparts(mfilename('fullpath'));
setenv('ENCONT_BASE', [filepath '/src/ManifoldComputing/EnCont']);
setenv('MANIAC_BASE', filepath);
addpath(genpath([getenv('MANIAC_BASE'), '/src/Visualizations']));
addpath(genpath([getenv('MANIAC_BASE'), '/src/ManifoldComputing/Embedding']));
addpath(genpath([getenv('MANIAC_BASE'), '/src/ManifoldComputing/EnCont']));
addpath(genpath([getenv('MANIAC_BASE'), '/src/ManifoldComputing/Meshing']));
%addpath(genpath([getenv('MANIAC_BASE'), '/Robots']));
addpath(genpath([getenv('MANIAC_BASE'), '/demo']));
addpath(genpath([getenv('MANIAC_BASE'), '/utils']));
addpath(getenv('MANIAC_BASE'));
clear filepath;

disp('nEigenmodes ready')