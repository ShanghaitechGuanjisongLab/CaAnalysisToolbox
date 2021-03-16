function TagCode = BlockName_TagCode(BlockName)
persistent TranslateTable
if isempty(TranslateTable)
	TranslateTable=load(fullfile(fileparts(mfilename("fullpath")),"..","TranslateTable.mat")).TranslateTable;
end
[TagCode(1),TagCode(2)]=find(TranslateTable==BlockName);