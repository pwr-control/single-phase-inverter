function check_ssc_from_library(model, lib_root)
%CHECK_SSC_FROM_LIBRARY  The Simscape models (.ssc) of the model come from the library, never from a local copy.
%
%   check_ssc_from_library(model, lib_root)
%
%   model    : name of the loaded model (init_model.m calls it right after open_system)
%   lib_root : root folder of the library clone, as returned by library_setup
%
%   The parameters of the model are local first (./private, then the library); the Simscape models are not:
%   they are always those of the library. Every Simscape block of the model, inside library links and in the
%   commented or inactive parts too, names its component as package.component (for instance
%   single_phase_transformer.single_phase_transformer, lithium_ion_cell.lithium_ion_cell), and Simscape takes
%   the first folder +package/component.ssc (or .sscp) found in the current folder and then along the MATLAB
%   path. The components that are not MathWorks ones (under matlabroot) must resolve inside lib_root: a copy in
%   this folder, in another folder on the path or in another clone of the library stops the init with the list
%   of the copies to remove. A package folder put in ./private is never seen by Simscape (private folders are
%   not on the path): do not copy .ssc files there, change them in the library.

    blocks = find_system(model, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'IncludeCommented', 'on', ...
        'MatchFilter', @Simulink.match.allVariants, 'RegExp', 'on', 'ComponentPath', '\w');
    if isempty(blocks)
        return
    end
    components = unique(get_param(blocks, 'ComponentPath'));

    folders = [{pwd}, strsplit(path, pathsep)];
    from_library = {};
    elsewhere = {};
    for k = 1:numel(components)
        file = ssc_file(components{k}, folders);
        if isempty(file) || is_under(file, matlabroot)
            continue                                % MathWorks component, or not found (Simscape reports it)
        end
        if is_under(file, lib_root)
            from_library{end+1} = components{k};    %#ok<AGROW>
        else
            elsewhere{end+1} = sprintf('  %s -> %s', components{k}, file);  %#ok<AGROW>
        end
    end

    if ~isempty(elsewhere)
        error('check_ssc_from_library:local', ['%s: Simscape components not taken from the library (%s):\n%s\n' ...
            'The .ssc models always come from the library: remove (or move out of the path) the copies above, ' ...
            'and change the component in the library.'], model, lib_root, strjoin(elsewhere, newline));
    end
    if isempty(from_library)
        from_library = {'none (MathWorks components only)'};
    end
    fprintf('%s init: Simscape components from the library: %s\n', model, strjoin(from_library, ', '));
end

function file = ssc_file(component, folders)
% first +pkg/.../name.ssc or .sscp along folders (current folder first, then the MATLAB path)
    parts = strsplit(component, '.');
    rel = fullfile(strjoin(strcat('+', parts(1:end-1)), filesep), parts{end});
    file = '';
    for k = 1:numel(folders)
        for ext = {'.ssc', '.sscp'}
            candidate = fullfile(folders{k}, [rel ext{1}]);
            if isfile(candidate)
                file = candidate;
                return
            end
        end
    end
end

function tf = is_under(file, root)
% file inside the folder root (separators and, on Windows, letter case normalized)
    file = strrep(file, '\', '/');
    root = strrep(char(root), '\', '/');
    if ~endsWith(root, '/')
        root = [root '/'];
    end
    if ispc
        tf = startsWith(lower(file), lower(root));
    else
        tf = startsWith(file, root);
    end
end
