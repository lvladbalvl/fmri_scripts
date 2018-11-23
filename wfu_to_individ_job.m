%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.write.ref = '<UNDEFINED>';
matlabbatch{1}.spm.spatial.coreg.write.source = '<UNDEFINED>';
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'rmask';
matlabbatch{2}.spm.util.defs.comp{1}.def = '<UNDEFINED>';
matlabbatch{2}.spm.util.defs.ofname = '';
matlabbatch{2}.spm.util.defs.fnames(1) = cfg_dep;
matlabbatch{2}.spm.util.defs.fnames(1).tname = 'Apply to';
matlabbatch{2}.spm.util.defs.fnames(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.util.defs.fnames(1).tgt_spec{1}(1).value = 'image';
matlabbatch{2}.spm.util.defs.fnames(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.util.defs.fnames(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.util.defs.fnames(1).sname = 'Coregister: Reslice: Resliced Images';
matlabbatch{2}.spm.util.defs.fnames(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.util.defs.fnames(1).src_output = substruct('.','rfiles');
matlabbatch{2}.spm.util.defs.savedir.saveusr = '<UNDEFINED>';
matlabbatch{2}.spm.util.defs.interp = 0;
matlabbatch{3}.spm.spatial.coreg.write.ref = '<UNDEFINED>';
matlabbatch{3}.spm.spatial.coreg.write.source(1) = cfg_dep;
matlabbatch{3}.spm.spatial.coreg.write.source(1).tname = 'Images to Reslice';
matlabbatch{3}.spm.spatial.coreg.write.source(1).tgt_spec{1}.name = 'filter';
matlabbatch{3}.spm.spatial.coreg.write.source(1).tgt_spec{1}.value = 'image';
matlabbatch{3}.spm.spatial.coreg.write.source(1).sname = 'Deformations: Warped images';
matlabbatch{3}.spm.spatial.coreg.write.source(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.spm.spatial.coreg.write.source(1).src_output = substruct('.','warped');
matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';
