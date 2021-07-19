function BlockName = TagCode_BlockName(TagCode)
persistent TranslateTable
if isempty(TranslateTable)
	TranslateTable=load(fullfile(fileparts(mfilename("fullpath")),"..","TranslateTable.mat")).TranslateTable;
end
BlockName=TranslateTable(TagCode(1),TagCode(2));